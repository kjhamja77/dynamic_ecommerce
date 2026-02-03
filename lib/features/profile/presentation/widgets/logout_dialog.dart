import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              // Close the dialog only when auth is complete
              Navigator.of(context).pop();
            } else if (state is AuthError) {
              // Show auth error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              // Show loading if either bloc is processing logout
              final isLoading = profileState is LoggingOut || authState is AuthLoading;
          
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          
          return AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.logout,
                  style: AppFonts.getTextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            content: Text(
              AppLocalizations.of(context)!.areYouSureYouWantToLogout,
              style: AppFonts.getTextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            actions: [
              // Cancel button
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: AppFonts.getTextStyle(
                    color: isLoading 
                        ? colorScheme.onSurface.withValues(alpha: 0.3)
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              // Logout button
              ElevatedButton(
                onPressed: isLoading ? null : () {
                  debugPrint('LogoutDialog: Confirm pressed, dispatching ProfileBloc.Logout + AuthBloc.LogoutRequested');
                  context.read<AuthBloc>().add(LogoutRequested());
                  context.read<ProfileBloc>().add(Logout());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  disabledBackgroundColor: colorScheme.surface.withValues(alpha: 0.5),
                  disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onError),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.logout,
                        style: AppFonts.getTextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onError,
                        ),
                      ),
              ),
            ],
          );
            },
          );
        },
      ),
    );
  }
}
