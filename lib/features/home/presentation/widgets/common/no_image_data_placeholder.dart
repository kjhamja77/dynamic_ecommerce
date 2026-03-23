import 'package:flutter/material.dart';
import '../../../../../core/constants/responsive_constants.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../l10n/app_localizations.dart';

class NoImageDataPlaceholder extends StatelessWidget {
  final bool compact;
  final BorderRadius? borderRadius;

  const NoImageDataPlaceholder({
    super.key,
    this.compact = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(ResponsiveConstants.mdRadius);
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerHigh,
            colorScheme.surfaceContainerLowest,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: compact ? -14 : -18,
            bottom: compact ? -10 : -12,
            child: Icon(
              Icons.image_outlined,
              size: compact ? 52 : 72,
              color: colorScheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: compact ? ResponsiveConstants.mdIconSize : ResponsiveConstants.lgIconSize,
                ),
                SizedBox(height: compact ? 4 : ResponsiveConstants.xsSpacing),
                Text(
                  loc.noImageData,
                  style: AppFonts.getTextStyle(
                    fontSize: compact
                        ? ResponsiveConstants.xsFontSize
                        : ResponsiveConstants.smFontSize,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
