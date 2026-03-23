import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../l10n/app_localizations.dart';

class CheckoutSummaryCard extends StatelessWidget {
  final CheckoutSummary summary;

  const CheckoutSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Colors.black,
                size: ResponsiveConstants.mdIconSize,
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Text(
                AppLocalizations.of(context)!.orderSummary,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.mdSpacing),
          
          // Summary details
          _buildSummaryRow(AppLocalizations.of(context)!.subtotal, summary.subtotal, context),
          _buildSummaryRow(AppLocalizations.of(context)!.shipping, summary.shipping, context),
          if (summary.discount > 0)
            _buildSummaryRow(AppLocalizations.of(context)!.discount, -summary.discount, context, isDiscount: true),
          
          SizedBox(height: ResponsiveConstants.smSpacing),
          
          // Divider
          Divider(color: Colors.grey.shade200),
          SizedBox(height: ResponsiveConstants.smSpacing),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.total,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                context.read<CurrencyProvider>().formatPrice(summary.total, locale: Localizations.localeOf(context)),
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.smSpacing),
          
          // Total items
          Text(
            '${AppLocalizations.of(context)!.totalItems} ${summary.totalItems}',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, BuildContext context, {bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${context.read<CurrencyProvider>().formatPrice(amount.abs(), locale: Localizations.localeOf(context))}',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              fontWeight: FontWeight.w500,
              color: isDiscount ? Colors.green.shade600 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
