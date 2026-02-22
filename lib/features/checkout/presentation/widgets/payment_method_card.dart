import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/payment_method.dart';
import '../../../../core/theme/app_fonts.dart';
import '../constants/checkout_constants.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shadowAlpha = theme.brightness == Brightness.dark ? 0.2 : 0.06;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? CheckoutConstants.primaryColor : colorScheme.outline.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: shadowAlpha),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? CheckoutConstants.primaryColor : colorScheme.outline,
                  width: 2,
                ),
                color: isSelected ? CheckoutConstants.primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: colorScheme.onPrimary,
                      size: 12.w,
                    )
                  : null,
            ),
            SizedBox(width: ResponsiveConstants.mdSpacing),
            _buildPaymentIcon(),
            SizedBox(width: ResponsiveConstants.mdSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    method.displayName,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.smFontSize,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (method.isDefault)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: CheckoutConstants.primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'افتراضي',
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentIcon() {
    switch (method.type) {
      case PaymentType.creditCard:
        return Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.credit_card,
            color: Colors.blue.shade600,
            size: 24.w,
          ),
        );
      case PaymentType.paypal:
        return Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.payment,
            color: Colors.blue.shade600,
            size: 24.w,
          ),
        );
      case PaymentType.applePay:
        return Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.phone_iphone,
            color: Colors.white,
            size: 24.w,
          ),
        );
      case PaymentType.googlePay:
        return Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.phone_android,
            color: Colors.green.shade600,
            size: 24.w,
          ),
        );
      case PaymentType.cashOnDelivery:
        return Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.money,
            color: Colors.orange.shade600,
            size: 24.w,
          ),
        );
      case PaymentType.bankTransfer:
        return Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.account_balance,
            color: Colors.purple.shade600,
            size: 24.w,
          ),
        );
      case PaymentType.alQaseh:
        return Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image.asset(
                'assets/images/alqaseh.png',
                width: 32.w,
                height: 32.w,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.payment,
                    color: Colors.grey.shade600,
                    size: 24.w,
                  );
                },
              ),
            ),
          ),
        );
    }
  }
}
