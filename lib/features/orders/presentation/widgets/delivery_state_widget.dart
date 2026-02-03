import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/order.dart';
import '../../core/constants/order_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../core/utils/order_date_utils.dart';

/// Widget to display the current delivery state of an order
class DeliveryStateWidget extends StatelessWidget {
  final Order order;

  const DeliveryStateWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    // If no delivery state, don't show the widget
    if (order.deliveryState == null) {
      return const SizedBox.shrink();
    }

    final deliveryState = order.deliveryState!;
    final stateName = deliveryState.name;
    final stateColor = OrderConstants.deliveryStateColors[stateName] ?? Colors.grey;
    final stateIcon = OrderConstants.deliveryStateIcons[stateName] ?? Icons.info_outline;
    final stateText = OrderConstants.localizedDeliveryState(context, deliveryState);

    return Container(
      margin: EdgeInsets.all(ResponsiveConstants.mdPadding),
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
        border: Border.all(
          color: stateColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: stateColor.withValues(alpha: 0.1),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                ),
                child: Icon(
                  stateIcon,
                  color: stateColor,
                  size: ResponsiveConstants.lgIconSize,
                ),
              ),
              SizedBox(width: ResponsiveConstants.mdSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.deliveryStatus,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.smFontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.xsSpacing),
                    Text(
                      stateText,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.lgFontSize,
                        fontWeight: FontWeight.w700,
                        color: stateColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Additional delivery information
          if (order.currentLocation != null && order.currentLocation!.isNotEmpty) ...[
            SizedBox(height: ResponsiveConstants.mdSpacing),
            _buildInfoRow(
              context,
              loc.currentLocation,
              order.currentLocation!,
              Icons.location_on_outlined,
            ),
          ],

          if (order.deliveryCarrier != null && order.deliveryCarrier!.isNotEmpty) ...[
            SizedBox(height: ResponsiveConstants.smSpacing),
            _buildInfoRow(
              context,
              loc.carrier,
              order.deliveryCarrier!,
              Icons.local_shipping_outlined,
            ),
          ],

          if (order.shippedDate != null) ...[
            SizedBox(height: ResponsiveConstants.smSpacing),
            _buildInfoRow(
              context,
              loc.shippedOn,
              OrderDateUtils.formatDate(context, order.shippedDate!),
              Icons.send_outlined,
            ),
          ],

          if (order.outForDeliveryDate != null) ...[
            SizedBox(height: ResponsiveConstants.smSpacing),
            _buildInfoRow(
              context,
              loc.outForDeliveryOn,
              OrderDateUtils.formatDate(context, order.outForDeliveryDate!),
              Icons.delivery_dining_outlined,
            ),
          ],

          if (order.trackingPage != null && order.trackingPage!.isNotEmpty) ...[
            SizedBox(height: ResponsiveConstants.mdSpacing),
            InkWell(
              onTap: () async {
                final uri = Uri.parse(order.trackingPage!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: EdgeInsets.all(ResponsiveConstants.smPadding),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.track_changes_outlined,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.trackYourOrder,
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.smFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(height: ResponsiveConstants.xsSpacing),
                          Text(
                            loc.viewTrackingDetails,
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.xsFontSize,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (order.deliveryNotes != null && order.deliveryNotes!.isNotEmpty) ...[
            SizedBox(height: ResponsiveConstants.mdSpacing),
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.smPadding),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: ResponsiveConstants.xsSpacing),
                  Expanded(
                    child: Text(
                      order.deliveryNotes!,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.smFontSize,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        SizedBox(width: ResponsiveConstants.xsSpacing),
        Text(
          '$label: ',
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.smFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

