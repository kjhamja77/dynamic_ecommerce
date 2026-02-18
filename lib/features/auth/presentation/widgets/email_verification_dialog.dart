import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../constants/auth_color_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';

/// Reusable email verification required dialog.
/// Shows when login or register returns [EmailVerificationRequired].
/// Resend button calls resend email verification API with [userId] and [apiToken].
class EmailVerificationDialog extends StatelessWidget {
  final String email;
  final int? userId;
  final String? apiToken;
  final VoidCallback onOkPressed;

  const EmailVerificationDialog({
    super.key,
    required this.email,
    required this.onOkPressed,
    this.userId,
    this.apiToken,
  });

  bool get _canResend => email.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    debugPrint('EmailVerificationDialog: build email=$email, userId=$userId, apiToken present=${apiToken != null && apiToken!.isNotEmpty}, canResend=$_canResend');
    final dialogTheme = Theme.of(context);
    final dialogColorScheme = dialogTheme.colorScheme;

    return AlertDialog(
      backgroundColor: dialogColorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AuthColorConstants.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_unread,
              color: AuthColorConstants.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              AppLocalizations.of(context)!.emailVerificationRequired,
              style: AppFonts.getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: dialogColorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.emailNotVerifiedMessage,
            style: AppFonts.getTextStyle(
              fontSize: 14,
              color: dialogColorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AuthColorConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AuthColorConstants.primaryColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email,
                  color: AuthColorConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    email,
                    style: AppFonts.getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: dialogColorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_canResend) ...[
            const SizedBox(height: 12),
            Text(
              'Unable to send verification email. Please try logging in again.',
              style: AppFonts.getTextStyle(
                fontSize: 12,
                color: dialogColorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onOkPressed,
          child: Text(
            AppLocalizations.of(context)!.ok,
            style: AppFonts.getTextStyle(
              color: dialogColorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (prev, curr) =>
              curr is ResendingEmailVerification ||
              curr is EmailVerificationResent ||
              curr is AuthError ||
              prev is ResendingEmailVerification,
          builder: (context, state) {
            final isResending = _canResend &&
                state is ResendingEmailVerification;
            final enabled = _canResend && !isResending;
            return Tooltip(
              message: _canResend
                  ? ''
                  : 'Send email not available for this session. Try logging in again.',
              child: ElevatedButton(
                onPressed: enabled
                    ? () {
                        debugPrint('EmailVerificationDialog: Send verification email tapped, email=$email');
                        context.read<AuthBloc>().add(
                              ResendEmailVerificationRequested(
                                email: email,
                              ),
                            );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: enabled
                      ? AuthColorConstants.primaryColor
                      : AuthColorConstants.primaryColor.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isResending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.resendEmail,
                        style: AppFonts.getTextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
