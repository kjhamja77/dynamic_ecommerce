import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../pages/edit_profile_page.dart';
import '../../../../core/theme/app_fonts.dart';

class ProfileHeader extends StatefulWidget {
  final UserProfile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  Widget build(BuildContext context) {
    // Always reflect the latest profile from the bloc if available
    final blocState = context.watch<ProfileBloc>().state;
    UserProfile displayProfile = widget.profile;
    if (blocState is ProfileUpdated) {
      displayProfile = blocState.profile;
    } else if (blocState is ProfileLoaded) {
      displayProfile = blocState.profile;
    }

    ImageProvider? _resolveAvatar(String? avatarUrl) {
      if (avatarUrl == null || avatarUrl.isEmpty) return null;
      if (avatarUrl.startsWith('http')) {
        // Use disk/memory cache instead of re-downloading each time.
        return CachedNetworkImageProvider(avatarUrl);
      }
      // Treat as local file path
      final file = File(avatarUrl);
      if (file.existsSync()) {
        return FileImage(file);
      }
      return null;
    }

    final avatarImage = _resolveAvatar(displayProfile.avatarUrl);
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
          CircleAvatar(
            radius: 40,
            backgroundColor: colorScheme.surface.withValues(alpha: 0.5),
            backgroundImage: avatarImage,
            child: avatarImage == null
                ? Icon(
                    Icons.person,
                    size: 40,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  )
                : null,
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
                if (displayProfile.phoneNumber != null) ...[
                  SizedBox(height: ResponsiveConstants.xsSpacing),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      displayProfile.phoneNumber!,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.left,
                    ),
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
