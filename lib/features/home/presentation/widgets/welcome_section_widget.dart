import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/welcome_bloc.dart';
import '../constants/home_constants.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/services/app_localization_service.dart';

class WelcomeSectionWidget extends StatefulWidget {
	const WelcomeSectionWidget({super.key});

	@override
	State<WelcomeSectionWidget> createState() => _WelcomeSectionWidgetState();
}

class _WelcomeSectionWidgetState extends State<WelcomeSectionWidget> {
	late final Timer _timer;
	final AppLocalizationService _localizationService = AppLocalizationService();

	@override
	void initState() {
		super.initState();
		
		// Load welcome texts and profile sequentially with small delays
		// to avoid overwhelming the server with simultaneous requests
		WidgetsBinding.instance.addPostFrameCallback((_) async {
			// Load welcome texts first
		context.read<WelcomeBloc>().add(LoadWelcomeTexts());
			
			// Wait a bit before loading profile
			await Future.delayed(const Duration(milliseconds: 150));
		
		// Load user profile if not already loaded
		final profileState = context.read<ProfileBloc>().state;
		if (profileState is! ProfileLoaded) {
			context.read<ProfileBloc>().add(LoadUserProfile());
		}
		});
		
		_timer = Timer.periodic(const Duration(seconds: 2), (_) {
			final welcomeState = context.read<WelcomeBloc>().state;
			if (welcomeState is WelcomeLoaded && welcomeState.messages.length > 1) {
				final nextIndex = (welcomeState.currentIndex + 1) % welcomeState.messages.length;
				context.read<WelcomeBloc>().updateCurrentIndex(nextIndex);
			}
		});
	}

	@override
	void dispose() {
		_timer.cancel();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return BlocBuilder<ProfileBloc, ProfileState>(
			builder: (context, profileState) {
				// Get user's name from profile
				String userName = AppLocalizations.of(context)!.user; // Default fallback
				if (profileState is ProfileLoaded) {
					// Extract first name from full name
					final fullName = profileState.profile.name.trim();
					print('🔍 WelcomeSection: Profile loaded - Full name: "$fullName"');
					if (fullName.isNotEmpty) {
						final nameParts = fullName.split(' ');
						userName = nameParts.first; // Get first name
						print('🔍 WelcomeSection: Extracted first name: "$userName"');
					}
				} else {
					print('🔍 WelcomeSection: Profile not loaded yet - State: ${profileState.runtimeType}');
				}

				return BlocBuilder<WelcomeBloc, WelcomeState>(
					builder: (context, welcomeState) {
						// Loading: shimmer
						if (welcomeState is WelcomeLoading) {
							return Container(
								padding: EdgeInsets.symmetric(
									horizontal: HomeConstants.defaultPadding * 0.75,
									vertical: HomeConstants.defaultPadding * 0.5,
								),
								alignment: _localizationService.isRTL ? Alignment.centerRight : Alignment.centerLeft,
								child: const _ShimmerLine(height: 14),
							);
						}

						// Error state - show fallback welcome message instead of error
						if (welcomeState is WelcomeError) {
							return Container(
								padding: EdgeInsets.symmetric(
									horizontal: HomeConstants.defaultPadding * 0.75,
									vertical: HomeConstants.defaultPadding * 0.5,
								),
								alignment: _localizationService.isRTL ? Alignment.centerRight : Alignment.centerLeft,
								child: Row(
									crossAxisAlignment: CrossAxisAlignment.center,
									textDirection: _localizationService.isRTL ? TextDirection.rtl : TextDirection.ltr,
									children: [
										Expanded(
											child: Text(
												AppLocalizations.of(context)!.welcomeUser(userName),
												style: AppFonts.getTextStyle(fontSize: HomeConstants.subtitleFontSize * 0.95,
													fontWeight: FontWeight.w600,
													color: Colors.grey.shade700,
												),
												maxLines: 2,
												overflow: TextOverflow.ellipsis,
												textAlign: _localizationService.isRTL ? TextAlign.right : TextAlign.left,
											),
										),
										const SizedBox(width: 8),
										// Retry button
										GestureDetector(
											onTap: () {
												context.read<WelcomeBloc>().add(LoadWelcomeTexts());
											},
											child: Container(
												padding: const EdgeInsets.all(4),
												decoration: BoxDecoration(
													color: Colors.grey.shade100,
													borderRadius: BorderRadius.circular(4),
												),
												child: Icon(
													Icons.refresh,
													size: 16,
													color: Colors.grey.shade600,
												),
											),
										),
									],
								),
							);
						}

						// Loaded state
						if (welcomeState is WelcomeLoaded) {
							final bool hasMessages = welcomeState.messages.isNotEmpty;

							// Empty: instruction only
							if (!hasMessages) {
								return Container(
									padding: EdgeInsets.symmetric(
										horizontal: HomeConstants.defaultPadding * 0.9,
										vertical: HomeConstants.defaultPadding * 1.0,
									),
									alignment: _localizationService.isRTL ? Alignment.centerRight : Alignment.centerLeft,
									child: Row(
										crossAxisAlignment: CrossAxisAlignment.center,
										textDirection: _localizationService.isRTL ? TextDirection.rtl : TextDirection.ltr,
										children: [
											Icon(
												Icons.info_outline,
												size: 22,
												color: Colors.grey.shade600,
											),
											const SizedBox(width: 10),
											Expanded(
												child: Text(
													AppLocalizations.of(context)!.welcomeUser(userName),
													style: AppFonts.getTextStyle(fontSize: HomeConstants.subtitleFontSize * 0.95,
														fontWeight: FontWeight.w600,
														color: Colors.grey.shade700,
													),
													maxLines: 2,
													overflow: TextOverflow.ellipsis,
													textAlign: _localizationService.isRTL ? TextAlign.right : TextAlign.left,
												),
											),
										],
									),
								);
							}

							// Show original design with "Welcome [UserName], " and rotating messages
							return Container(
								padding: EdgeInsets.symmetric(
									horizontal: HomeConstants.defaultPadding * 0.75,
									vertical: HomeConstants.defaultPadding * 0.5,
								),
								child: Row(
									crossAxisAlignment: CrossAxisAlignment.center,
									textDirection: _localizationService.isRTL ? TextDirection.rtl : TextDirection.ltr,
									children: [
										// Use Flexible instead of SizedBox to prevent layout issues
										Flexible(
											flex: 0,
											child: Text(
												AppLocalizations.of(context)!.welcomeUserComma(userName),
												style: AppFonts.getTextStyle(fontSize: HomeConstants.subtitleFontSize * 0.8,
													color: Colors.grey.shade700,
												),
												textAlign: _localizationService.isRTL ? TextAlign.right : TextAlign.left,
											),
										),
										const SizedBox(width: 6),
										// Container for rotating messages with consistent height and width
										Expanded(
											child: SizedBox(
												height: 20, // Fixed height to prevent size changes
												child: Align(
													alignment: _localizationService.isRTL ? Alignment.centerRight : Alignment.centerLeft,
													child: AnimatedSwitcher(
														duration: const Duration(milliseconds: 400),
														switchInCurve: Curves.easeInOut,
														switchOutCurve: Curves.easeInOut,
														transitionBuilder: (child, animation) {
															// Use only FadeTransition to prevent left movement
															return FadeTransition(
																opacity: animation,
																child: child,
															);
														},
														child: Text(
															welcomeState.messages[welcomeState.currentIndex],
															key: ValueKey<int>(welcomeState.currentIndex),
															style: AppFonts.getTextStyle(fontSize: HomeConstants.subtitleFontSize * 0.8,
																fontWeight: FontWeight.w600,
																color: Colors.purple.shade600,
															),
															maxLines: 1,
															overflow: TextOverflow.ellipsis,
															textAlign: _localizationService.isRTL ? TextAlign.right : TextAlign.left,
														),
													),
												),
											),
										),
									],
								),
							);
						}

						// Default fallback
						return Container(
							padding: EdgeInsets.symmetric(
								horizontal: HomeConstants.defaultPadding * 0.75,
								vertical: HomeConstants.defaultPadding * 0.5,
							),
							alignment: Alignment.centerLeft,
							child: const _ShimmerLine(height: 14),
						);
					},
				);
			},
		);
	}
}

class _ShimmerLine extends StatefulWidget {
	final double height;
	const _ShimmerLine({required this.height});

	@override
	State<_ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<_ShimmerLine>
	with SingleTickerProviderStateMixin {
	late final AnimationController _controller;

	@override
	void initState() {
		super.initState();
		_controller = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 1200),
		)..repeat();
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: _controller,
			builder: (context, child) {
				return ShaderMask(
					shaderCallback: (rect) {
						return LinearGradient(
							begin: Alignment.centerLeft,
							end: Alignment.centerRight,
							colors: [
								Colors.grey.shade300,
								Colors.grey.shade100,
								Colors.grey.shade300,
							],
							stops: const [0.1, 0.3, 0.6],
						).createShader(rect);
					},
					blendMode: BlendMode.srcATop,
					child: Container(color: Colors.grey.shade300),
				);
			},
		);
	}
}