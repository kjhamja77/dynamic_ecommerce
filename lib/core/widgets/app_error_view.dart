import 'package:flutter/material.dart';

import '../constants/responsive_constants.dart';
import '../theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';

/// Enhanced error view for exception/API failures.
/// Shows a user-friendly title and short message, with optional expandable
/// technical details and a Try Again action.
class AppErrorView extends StatelessWidget {
  /// Raw error message (e.g. DioException toString or failure.message).
  final String message;

  /// Called when the user taps Try Again.
  final VoidCallback? onRetry;

  /// Optional custom title. If null, uses [AppLocalizations.somethingWentWrong].
  final String? title;

  /// Optional product/screen ID for retry (e.g. productId for product details).
  /// Not used by this widget; callers may use it in [onRetry].
  final String? retryContextId;

  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.retryContextId,
  });

  /// Returns a short, user-friendly message for the given raw error.
  static String userFriendlyMessage(BuildContext context, String rawMessage) {
    final lower = rawMessage.toLowerCase();
    final loc = AppLocalizations.of(context);
    if (loc == null) return rawMessage;

    if (lower.contains('502') || lower.contains('bad gateway')) {
      return '${loc.serverError}. ${loc.tryAgain}';
    }
    if (lower.contains('503') || lower.contains('service unavailable')) {
      return '${loc.serverError}. ${loc.tryAgain}';
    }
    if (lower.contains('500') || lower.contains('internal server error')) {
      return '${loc.serverError}. ${loc.tryAgain}';
    }
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return '${loc.somethingWentWrong}. ${loc.tryAgain}';
    }
    if (lower.contains('connection') || lower.contains('network') || lower.contains('socket')) {
      return '${loc.somethingWentWrong}. ${loc.tryAgain}';
    }
    // Keep message short: if it looks like a long exception, show generic line
    if (rawMessage.length > 120 || lower.contains('exception') || lower.contains('dioexception')) {
      return '${loc.somethingWentWrong}. ${loc.tryAgain}';
    }
    return rawMessage;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final displayTitle = title ?? loc.somethingWentWrong;
    final shortMessage = userFriendlyMessage(context, message);
    final showTechnicalDetails = message.length > 80 || message.contains('Exception') || message.contains('status code');

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.lgPadding,
          vertical: ResponsiveConstants.xlSpacing,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon in a soft container
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: ResponsiveConstants.errorIconSize,
                color: colorScheme.error,
              ),
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),

            // Title
            Text(
              displayTitle,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.xlFontSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),

            // Short user-facing message
            Text(
              shortMessage,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Expandable technical details
            if (showTechnicalDetails) ...[
              SizedBox(height: ResponsiveConstants.lgSpacing),
              _ExpandableDetails(technicalMessage: message),
            ],

            SizedBox(height: ResponsiveConstants.xlSpacing),

            // Try Again button
            if (onRetry != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 22),
                  label: Text(
                    loc.tryAgain,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveConstants.mdPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                    ),
                    elevation: isDark ? 0 : 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableDetails extends StatefulWidget {
  final String technicalMessage;

  const _ExpandableDetails({required this.technicalMessage});

  @override
  State<_ExpandableDetails> createState() => _ExpandableDetailsState();
}

class _ExpandableDetailsState extends State<_ExpandableDetails> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveConstants.smPadding,
            vertical: ResponsiveConstants.smSpacing,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  SizedBox(width: ResponsiveConstants.xsSpacing),
                  Text(
                    loc.viewDetails,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.smFontSize,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (_expanded) ...[
                SizedBox(height: ResponsiveConstants.smSpacing),
                SelectableText(
                  widget.technicalMessage,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.xsFontSize,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
