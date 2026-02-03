import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/payment_method.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';

class PaymentMethodTypeGrid extends StatelessWidget {
  final PaymentMethodType selected;
  final ValueChanged<PaymentMethodType> onChanged;

  const PaymentMethodTypeGrid({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PaymentMethodType>(
      value: selected,
      onChanged: (PaymentMethodType? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.paymentMethodType,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          borderSide: BorderSide(color: Colors.black87, width: 2),
        ),
        prefixIcon: Icon(Icons.payment, color: Colors.black87),
        labelStyle: AppFonts.getTextStyle(color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      dropdownColor: Colors.white,
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.black87),
      items: [
        PaymentMethodType.zainCash,
        PaymentMethodType.qiCard,
        PaymentMethodType.alQaseh,
      ].map((PaymentMethodType type) {
        final isComingSoon = type == PaymentMethodType.zainCash || type == PaymentMethodType.qiCard;
        return DropdownMenuItem<PaymentMethodType>(
          value: type,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _label(type, context),
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isComingSoon)
                Padding(
                  padding: EdgeInsets.only(left: ResponsiveConstants.smSpacing),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.comingSoon,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _label(PaymentMethodType type, BuildContext context) {
    switch (type) {
      case PaymentMethodType.creditCard:
        return AppLocalizations.of(context)!.creditCard;
      case PaymentMethodType.debitCard:
        return AppLocalizations.of(context)!.debitCard;
      case PaymentMethodType.paypal:
        return AppLocalizations.of(context)!.paypal;
      case PaymentMethodType.applePay:
        return AppLocalizations.of(context)!.applePay;
      case PaymentMethodType.googlePay:
        return AppLocalizations.of(context)!.googlePay;
      case PaymentMethodType.bankTransfer:
        return AppLocalizations.of(context)!.bankTransfer;
      case PaymentMethodType.cashOnDelivery:
        return AppLocalizations.of(context)!.cashOnDelivery;
      case PaymentMethodType.cash:
        return AppLocalizations.of(context)!.cashPayment;
      case PaymentMethodType.zainCash:
        return AppLocalizations.of(context)!.zainCash;
      case PaymentMethodType.qiCard:
        return AppLocalizations.of(context)!.qiCard;
      case PaymentMethodType.alQaseh:
        return AppLocalizations.of(context)!.alQaseh;
    }
  }
}
