import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/user_order.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../core/widgets/authenticated_cached_image.dart';

class OrderCard extends StatelessWidget {
  final UserOrder order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                _buildStatusChip(order.status, context),
              ],
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Text(
              'Ordered on ${_formatDate(order.orderDate)}',
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Text(
              'Total: ${order.currency} ${order.totalAmount.toStringAsFixed(2)}',
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Text(
              '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                color: Colors.grey.shade600,
              ),
            ),
            if (order.trackingNumber != null) ...[
              SizedBox(height: ResponsiveConstants.smSpacing),
              Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: ResponsiveConstants.xsSpacing),
                  Text(
                    'Tracking: ${order.trackingNumber}',
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
            if (order.estimatedDelivery != null) ...[
              SizedBox(height: ResponsiveConstants.xsSpacing),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: ResponsiveConstants.xsSpacing),
                  Text(
                    'Estimated delivery: ${_formatDate(order.estimatedDelivery!)}',
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: ResponsiveConstants.mdSpacing),
            const Divider(),
            SizedBox(height: ResponsiveConstants.smSpacing),
            // Order items preview
            ...order.items.take(2).map((item) => _buildOrderItem(item)),
            if (order.items.length > 2) ...[
              SizedBox(height: ResponsiveConstants.smSpacing),
              Text(
                '... and ${order.items.length - 2} more items',
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            SizedBox(height: ResponsiveConstants.mdSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
          await HapticService.buttonClick();
          // Navigate to order details
        },
                  child: Text(
                    AppLocalizations.of(context)!.viewDetails,
                    style: AppFonts.getTextStyle(color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (order.status == OrderStatus.shipped)
                  ElevatedButton(
                    onPressed: () async {
          await HapticService.buttonClick();
          // Track order
        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveConstants.mdPadding,
                        vertical: ResponsiveConstants.smPadding,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.trackOrder,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status, BuildContext context) {
    Color color;
    String text;
    
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = AppLocalizations.of(context)!.pending;
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        text = AppLocalizations.of(context)!.confirmed;
        break;
      case OrderStatus.processing:
        color = Colors.purple;
        text = AppLocalizations.of(context)!.processing;
        break;
      case OrderStatus.shipped:
        color = Colors.indigo;
        text = AppLocalizations.of(context)!.shipped;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = AppLocalizations.of(context)!.delivered;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = AppLocalizations.of(context)!.cancelled;
        break;
      case OrderStatus.returned:
        color = Colors.grey;
        text = AppLocalizations.of(context)!.returned;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.smPadding,
        vertical: ResponsiveConstants.xsPadding,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.xsSpacing),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.productImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AuthenticatedCachedImage(
                      imageUrl: item.productImage!,
                      fit: BoxFit.contain,
                      errorWidget: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                : Icon(
                    Icons.image_not_supported,
                    color: Colors.grey.shade400,
                  ),
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Qty: ${item.quantity} • ${order.currency} ${item.unitPrice.toStringAsFixed(2)}',
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
