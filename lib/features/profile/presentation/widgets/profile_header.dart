import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/authenticated_cached_image.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../pages/edit_profile_page.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/utils/country_code_detector.dart';

class ProfileHeader extends StatefulWidget {
  final UserProfile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  /// Shows user mobile as: saved country code + saved phone number (e.g. "+964 7901234567").
  /// Accepts country_code from API as ISO ("IQ") or dial code ("964").
  String? _displayPhone(UserProfile profile) {
    final national = profile.phoneNumber?.trim();
    final code = profile.countryCode?.trim();
    if (national == null || national.isEmpty) return null;
    if (code != null && code.isNotEmpty) {
      final String? isoCode = RegExp(r'^\d+$').hasMatch(code)
          ? CountryCodeDetector.detectCountryCode(code)
          : code;
      final country = isoCode != null ? CountryCodeDetector.getCountryFromCode(isoCode) : null;
      if (country != null) return '+${country.phoneCode} $national';
    }
    return national;
  }

  @override
  Widget build(BuildContext context) {
    // Always reflect the latest profile from the bloc if available
    final blocState = context.watch<ProfileBloc>().state;
    UserProfile displayProfile = widget.profile;
    if (blocState is ProfileUpdated) {
      displayProfile = blocState.profile;
      debugPrint('ProfileHeader: Using ProfileUpdated profile');
      debugPrint('ProfileHeader: Avatar URL: ${displayProfile.avatarUrl}');
      debugPrint('ProfileHeader: Country Code: ${displayProfile.countryCode}');
    } else if (blocState is ProfileLoaded) {
      displayProfile = blocState.profile;
      debugPrint('ProfileHeader: Using ProfileLoaded profile');
    }

    // Resolve avatar: network URL, base64 from API, or local file path
    String? _resolveAvatarUrl(String? avatarUrl) {
      if (avatarUrl == null || avatarUrl.isEmpty) return null;
      if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) return avatarUrl;
      if (avatarUrl.startsWith('/')) {
        final base = AppConstants.baseUrl;
        final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
        return '$cleanBase$avatarUrl';
      }
      return avatarUrl;
    }

    /// Returns decoded bytes if [avatarUrl] is base64 image data (e.g. from get user profile API). Otherwise null.
    Uint8List? _avatarUrlAsBase64Bytes(String? avatarUrl) {
      if (avatarUrl == null || avatarUrl.length < 50) return null;
      final trimmed = avatarUrl.trim();
      if (trimmed.startsWith('data:image/') && trimmed.contains(',')) {
        final payload = trimmed.split(',').last.trim();
        if (payload.isEmpty) return null;
        try {
          return base64Decode(payload);
        } catch (_) {
          return null;
        }
      }
      if (!RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(trimmed.replaceAll(RegExp(r'\s'), ''))) return null;
      try {
        return base64Decode(trimmed);
      } catch (_) {
        return null;
      }
    }

    final resolvedAvatarUrl = _resolveAvatarUrl(displayProfile.avatarUrl);
    final avatarBase64Bytes = _avatarUrlAsBase64Bytes(displayProfile.avatarUrl);
    final isNetworkUrl = resolvedAvatarUrl != null &&
        (resolvedAvatarUrl.startsWith('http://') || resolvedAvatarUrl.startsWith('https://'));
    final isLocalFilePath = resolvedAvatarUrl != null && !isNetworkUrl && avatarBase64Bytes == null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Avatar with proper image handling
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surface.withValues(alpha: 0.5),
            ),
            child: ClipOval(
              child: resolvedAvatarUrl == null && avatarBase64Bytes == null
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    )
                  : avatarBase64Bytes != null
                      ? Image.memory(
                          avatarBase64Bytes,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('ProfileHeader: Error decoding base64 image: $error');
                            return Icon(
                              Icons.person,
                              size: 40,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            );
                          },
                        )
                      : isLocalFilePath
                          ? Image.file(
                              File(resolvedAvatarUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('ProfileHeader: Error loading local image: $error');
                                return Icon(
                                  Icons.person,
                                  size: 40,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                );
                              },
                            )
                          : AuthenticatedCachedImage(
                              imageUrl: resolvedAvatarUrl!,
                              fit: BoxFit.cover,
                              useCacheBuster: true,
                              placeholder: Container(
                                color: colorScheme.surface,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: Icon(
                                Icons.person,
                                size: 40,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
            ),
          ),
          SizedBox(width: ResponsiveConstants.mdSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayProfile.name,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                Text(
                  displayProfile.email,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (displayProfile.phoneNumber != null || displayProfile.countryCode != null) ...[
                  SizedBox(height: ResponsiveConstants.xsSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Builder(
                          builder: (context) {
                            final displayPhone = _displayPhone(displayProfile);
                            if (displayPhone == null || displayPhone.isEmpty) return const SizedBox.shrink();
                            return Text(
                              displayPhone,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.smFontSize,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: EditProfilePage(profile: displayProfile),
                  ),
                ),
              );
              
              // Handle the returned profile data
              if (result != null && result is UserProfile) {
                // Check if the widget is still mounted before accessing context
                if (mounted) {
                  // Update the local state by dispatching a local update event
                  context.read<ProfileBloc>().add(UpdateUserProfile(result));
                  
                  // After successful update, reload the profile to get orders back
                  Future.delayed(Duration(milliseconds: 500), () {
                    if (mounted) {
                      context.read<ProfileBloc>().add(LoadUserProfile());
                    }
                  });
                }
              }
            },
            icon: Icon(
              Icons.edit_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
