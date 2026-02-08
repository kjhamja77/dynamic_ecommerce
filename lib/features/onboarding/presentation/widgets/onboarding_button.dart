import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';

class OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;
  /// When true, icon is shown after the text (e.g. Next in RTL: "التالي ←").
  final bool iconAtEnd;

  const OnboardingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.iconAtEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = ResponsiveConstants.smIconSize;
    return SizedBox(
      width: double.infinity,
      height: ResponsiveConstants.mdButtonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.black : Colors.transparent,
          foregroundColor: isPrimary ? Colors.white : Colors.black,
          elevation: isPrimary ? ResponsiveConstants.smElevation : 0,
          side: isPrimary ? null : BorderSide(color: Colors.black, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: ResponsiveConstants.loadingIndicatorStrokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? Colors.white : Colors.black,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!iconAtEnd && icon != null) ...[
                    Icon(icon, size: iconSize),
                    if (text.isNotEmpty) SizedBox(width: ResponsiveConstants.smSpacing),
                  ],
                  if (text.isNotEmpty)
                    Flexible(
                      child: Text(
                        text,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (iconAtEnd && icon != null) ...[
                    if (text.isNotEmpty) SizedBox(width: ResponsiveConstants.smSpacing),
                    Icon(icon, size: iconSize),
                  ],
                ],
              ),
      ),
    );
  }
}
