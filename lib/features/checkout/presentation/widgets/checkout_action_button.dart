import 'package:flutter/material.dart';
import '../constants/checkout_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/services/haptic_service.dart';

class CheckoutActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CheckoutActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? () async {
          await HapticService.buttonClick();
          onPressed?.call();
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? CheckoutConstants.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CheckoutConstants.cardBorderRadius),
          ),
          elevation: 0,
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? Colors.white,
              ),
            ),
          ),
          SizedBox(width: CheckoutConstants.smallSpacing),
          Text(
            'Processing...',
            style: AppFonts.getTextStyle(fontSize: CheckoutConstants.bodyFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: CheckoutConstants.iconSize,
          ),
          SizedBox(width: CheckoutConstants.smallSpacing),
        ],
        Text(
          text,
          style: AppFonts.getTextStyle(fontSize: CheckoutConstants.bodyFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
