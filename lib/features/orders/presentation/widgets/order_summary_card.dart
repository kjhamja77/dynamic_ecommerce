import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/order.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../l10n/app_localizations.dart';

class OrderSummaryCard extends StatelessWidget {
  final Order order;

  const OrderSummaryCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currency = context.watch<CurrencyProvider>();
    final locale = Localizations.localeOf(context);

    return Container(
      margin: EdgeInsets.all(ResponsiveConstants.mdPadding),
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
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
                Icons.receipt_long_outlined,
                color: Colors.black87,
                size: ResponsiveConstants.mdIconSize,
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Text(
                loc.orderSummary,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.mdSpacing),
          
          // Show currency if available
          if (order.currency != null && order.currency!.isNotEmpty) ...[
            _buildInfoRow(
              'Currency',
              order.currency!,
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
          ],
          
          // Summary rows
          _buildSummaryRow(
            loc.itemsCount(order.itemCount),
            currency.formatPrice(order.subtotal, locale: locale),
          ),
          if (order.orderLineCount != null && order.orderLineCount! > 0) ...[
            _buildInfoRow(
              'Order Lines',
              order.orderLineCount.toString(),
            ),
            SizedBox(height: ResponsiveConstants.xsSpacing),
          ],
          _buildSummaryRow(
            loc.shipping,
            currency.formatPrice(order.shippingCost, locale: locale),
          ),
          _buildSummaryRow(
            loc.tax,
            currency.formatPrice(order.taxAmount, locale: locale),
          ),
          
          SizedBox(height: ResponsiveConstants.mdSpacing),
          
          _buildSummaryRow(
            loc.totalAmount,
            currency.formatPrice(order.totalAmount, locale: locale),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.xsSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.xsSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.getTextStyle(fontSize: isTotal ? ResponsiveConstants.mdFontSize : ResponsiveConstants.smFontSize,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: AppFonts.getTextStyle(fontSize: isTotal ? ResponsiveConstants.mdFontSize : ResponsiveConstants.smFontSize,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
