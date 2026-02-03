import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/order.dart';
import '../../core/utils/order_date_utils.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../core/constants/order_constants.dart';

class OrderTimeline extends StatelessWidget {
  final Order order;
  final VoidCallback? onTrackOrder;

  const OrderTimeline({
    super.key,
    required this.order,
    this.onTrackOrder,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
          // Header with icon and title
          Row(
            children: [
              Icon(
                Icons.timeline_outlined,
                color: Colors.black87,
                size: ResponsiveConstants.mdIconSize,
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Text(
                loc.orderProgress,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.mdSpacing),

          // Order Placed - Always shown
          _buildTimelineItem(
            context,
            loc.orderPlaced,
            OrderDateUtils.formatTimelineDate(context, order.orderDate),
            Icons.shopping_cart_outlined,
            Colors.green,
            isCompleted: true,
          ),

          // Order Confirmed - Show if order is not pending
          if (order.status != OrderStatus.pending)
            _buildTimelineItem(
              context,
              loc.orderConfirmed,
              OrderDateUtils.formatTimelineDate(context, order.orderDate),
              Icons.check_circle_outlined,
              Colors.blue,
              isCompleted: true,
            ),

          // Processing / Preparing
          if (order.deliveryState == DeliveryState.preparing ||
              order.deliveryState == DeliveryState.readyToShip)
            _buildTimelineItem(
              context,
              OrderConstants.localizedStatus(context, OrderStatus.processing),
              OrderDateUtils.formatTimelineDate(
                context,
                order.shippedDate ?? order.orderDate,
              ),
              Icons.build_outlined,
              Colors.orange,
              isCompleted: true,
            ),

          // Shipped
          if (order.shippedDate != null)
            _buildTimelineItem(
              context,
              OrderConstants.localizedStatus(context, OrderStatus.shipped),
              OrderDateUtils.formatTimelineDate(context, order.shippedDate!),
              Icons.local_shipping_outlined,
              Colors.indigo,
              isCompleted: true,
            ),

          // Delivered
          if (order.deliveredDate != null)
            _buildTimelineItem(
              context,
              OrderConstants.localizedStatus(context, OrderStatus.delivered),
              OrderDateUtils.formatTimelineDate(context, order.deliveredDate!),
              Icons.done_all_outlined,
              Colors.green,
              isCompleted: true,
            ),

          // Track Your Order button
          if (order.canBeTracked || order.trackingNumber != null) ...[
            SizedBox(height: ResponsiveConstants.lgSpacing),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTrackOrder ?? () {
                  // Navigate to tracking tab or external tracking page
                  if (order.trackingPage != null) {
                    // Open external tracking page if available
                  } else {
                    // Navigate to tracking tab in order details
                    DefaultTabController.of(context).animateTo(2);
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveConstants.mdPadding,
                  ),
                  side: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                  ),
                ),
                child: Text(
                  loc.trackYourOrder,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String title,
    String date,
    IconData icon,
    Color color, {
    required bool isCompleted,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container with circular background
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
          ),
          
          SizedBox(width: ResponsiveConstants.mdSpacing),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                Text(
                  date,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.smFontSize,
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
}
