import 'package:flutter/material.dart';
import '../constants/checkout_constants.dart';
import '../../../../core/theme/app_fonts.dart';

class CheckoutHeaderWidget extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final String title;
  final String? subtitle;

  const CheckoutHeaderWidget({
    super.key,
    this.onBackPressed,
    this.title = 'Checkout',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(CheckoutConstants.cardPadding),
      decoration: BoxDecoration(
        color: CheckoutConstants.cardBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(CheckoutConstants.cardBorderRadius),
          bottomRight: Radius.circular(CheckoutConstants.cardBorderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: CheckoutConstants.shadowColor,
            blurRadius: CheckoutConstants.cardShadowBlur,
            offset: Offset(0, CheckoutConstants.cardShadowOffset),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title row
          Row(
            children: [
              if (onBackPressed != null) ...[
                IconButton(
                  onPressed: onBackPressed,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: CheckoutConstants.primaryColor,
                    size: CheckoutConstants.iconSize,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: CheckoutConstants.smallSpacing),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.getTextStyle(fontSize: CheckoutConstants.titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: CheckoutConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          
          // Subtitle if provided
          if (subtitle != null) ...[
            SizedBox(height: CheckoutConstants.smallSpacing),
            Text(
              subtitle!,
              style: AppFonts.getTextStyle(fontSize: CheckoutConstants.captionFontSize,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
