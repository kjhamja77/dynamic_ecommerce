import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/order.dart';
import '../../core/constants/order_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../core/utils/order_date_utils.dart';

class OrderStatusHeader extends StatelessWidget {
  final Order order;

  const OrderStatusHeader({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          _buildStatusRow(context),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          _buildPaymentStatusRow(context),
          if (order.deliveryStatus != null && order.deliveryStatus!.isNotEmpty) ...[
            SizedBox(height: ResponsiveConstants.mdSpacing),
            _buildDeliveryStatusRow(context),
          ],
          SizedBox(height: ResponsiveConstants.mdSpacing),
          _buildOrderDateRow(context),
        ],
      ),
    );
  }

  Widget _buildDeliveryStatusRow(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final deliveryStatus = order.deliveryStatus!;
    final color = OrderConstants.getDeliveryStatusColor(deliveryStatus);
    final icon = OrderConstants.getDeliveryStatusIcon(deliveryStatus);
    final translatedStatus = OrderConstants.localizedDeliveryStatusString(context, deliveryStatus);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveConstants.smPadding),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          ),
          child: Icon(
            icon,
            color: color,
            size: ResponsiveConstants.mdIconSize,
          ),
        ),
        SizedBox(width: ResponsiveConstants.mdSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.deliveryStatus,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                translatedStatus,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final statusKey = order.status.name;
    final color = OrderConstants.statusColors[statusKey] ?? Colors.grey;
    final icon = OrderConstants.statusIcons[statusKey] ?? Icons.info_outline;
    // Always use localized status for translation
    final text = OrderConstants.localizedStatus(context, order.status);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveConstants.smPadding),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          ),
          child: Icon(
            icon,
            color: color,
            size: ResponsiveConstants.mdIconSize,
          ),
        ),
        SizedBox(width: ResponsiveConstants.mdSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.orderStatus,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                text,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatusRow(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final paymentStatusKey = order.paymentStatus.name;
    final color = OrderConstants.paymentStatusColors[paymentStatusKey] ?? Colors.grey;
    final icon = OrderConstants.paymentStatusIcons[paymentStatusKey] ?? Icons.info_outline;
    final text = OrderConstants.localizedPaymentStatus(context, order.paymentStatus);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveConstants.smPadding),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          ),
          child: Icon(
            icon,
            color: color,
            size: ResponsiveConstants.mdIconSize,
          ),
        ),
        SizedBox(width: ResponsiveConstants.mdSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.paymentStatus,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                text,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDateRow(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final formatted = OrderDateUtils.formatDate(context, order.orderDate);

    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          color: Colors.grey.shade600,
          size: ResponsiveConstants.smIconSize,
        ),
        SizedBox(width: ResponsiveConstants.smSpacing),
        Expanded(
          child: Text(
            loc.orderPlacedOn(formatted),
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
