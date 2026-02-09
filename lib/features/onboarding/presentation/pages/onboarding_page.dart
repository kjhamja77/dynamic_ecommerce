import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_content.dart';
import '../widgets/page_indicator.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/onboarding_shimmer.dart';
import '../widgets/onboarding_empty_state.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<OnboardingBloc>().add(LoadOnboardingPages());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _animateTo(int index) async {
    if (_isAnimating) return;
    _isAnimating = true;
    try {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } finally {
      _isAnimating = false;
    }
  }

  void _nextPage(int currentIndex, int total) {
    final next = currentIndex + 1;
    if (next < total) _animateTo(next);
  }

  void _previousPage(int currentIndex) {
    final prev = currentIndex - 1;
    if (prev >= 0) _animateTo(prev);
  }

  void _completeOnboarding() {
    context.read<OnboardingBloc>().add(CompleteOnboardingEvent());
  }

  void _skipOnboarding() {
    print('Skip button pressed, calling SkipOnboarding event...');
    // Mark onboarding as completed and navigate directly
    context.read<OnboardingBloc>().add(SkipOnboarding());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingLoaded) {
            // Keep PageController synced if state changes elsewhere
            final page = _pageController.hasClients ? _pageController.page?.round() : null;
            if (page != null && page != state.currentPageIndex && !_isAnimating) {
              _pageController.jumpToPage(state.currentPageIndex);
            }
          }
          if (state is OnboardingCompleted) {
            print('Onboarding completed, navigating to sign in page...');
            Navigator.of(context).pushReplacementNamed('/sign-in');
          }
        },
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            if (state is OnboardingLoading) {
              return const OnboardingShimmer();
            }

            if (state is OnboardingError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: ResponsiveConstants.xlIconSize,
                      color: Colors.red.shade400,
                    ),
                    SizedBox(height: ResponsiveConstants.mdSpacing),
                    Text(
                      '${AppLocalizations.of(context)!.onboardingError}: ${state.message}',
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                        color: Colors.red.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveConstants.lgSpacing),
                    ElevatedButton(
                      onPressed: () async {
          await HapticService.buttonClick();
          context.read<OnboardingBloc>().add(LoadOnboardingPages());
        },
                      child: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is OnboardingLoaded) {
              // Check if onboarding pages are empty
              if (state.pages.isEmpty) {
                return const OnboardingEmptyState();
              }
              return SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                        child: TextButton(
                          onPressed: _skipOnboarding,
                          child: Text(
                            AppLocalizations.of(context)!.skip,
                            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          context.read<OnboardingBloc>().add(SetPageIndex(index));
                        },
                        itemCount: state.pages.length,
                        itemBuilder: (context, index) {
                          return OnboardingContent(
                            page: state.pages[index],
                            pageIndex: index,
                            isLastPage: index == state.pages.length - 1,
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
                      child: PageIndicator(
                        currentPage: state.currentPageIndex,
                        totalPages: state.pages.length,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
                      child: Row(
                        children: [
                          if (state.currentPageIndex > 0) ...[
                            Expanded(
                              child: OnboardingButton(
                                text: AppLocalizations.of(context)!.previous,
                                onPressed: () async {
          await HapticService.buttonClick();
          _previousPage(state.currentPageIndex);
        },
                                isPrimary: false,
                                icon: Icons.arrow_back,
                              ),
                            ),
                            SizedBox(width: ResponsiveConstants.mdSpacing),
                          ],
                          Expanded(
                            child: OnboardingButton(
                              text: state.isLastPage ? AppLocalizations.of(context)!.getStarted : AppLocalizations.of(context)!.next,
                              onPressed: state.isLastPage
                                  ? _completeOnboarding
                                  : () => _nextPage(state.currentPageIndex, state.pages.length),
                              icon: Icons.arrow_forward,
                              iconAtEnd: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
