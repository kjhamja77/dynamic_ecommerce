import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/order.dart';
import '../../core/utils/order_date_utils.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../core/constants/order_constants.dart';

class ShippingDeliveryInfo extends StatelessWidget {
  final Order order;

  const ShippingDeliveryInfo({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.all(ResponsiveConstants.mdPadding),
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.2 : 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isRTL) Icon(
                Icons.local_shipping_outlined,
                color: colorScheme.onSurface,
                size: ResponsiveConstants.mdIconSize,
              ),
              if (!isRTL) SizedBox(width: ResponsiveConstants.smSpacing),
              Text(
                loc.shippingAndDelivery,
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (isRTL) SizedBox(width: ResponsiveConstants.smSpacing),
              if (isRTL) Icon(
                Icons.local_shipping_outlined,
                color: colorScheme.onSurface,
                size: ResponsiveConstants.mdIconSize,
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.mdSpacing),
          
          // Show detailed shipping partner info if available
          if (order.partnerShipping != null && order.partnerShipping!.isNotEmpty) ...[
            if (order.partnerShipping!['name'] != null && order.partnerShipping!['name'].toString().isNotEmpty)
              _buildInfoRow(context, loc.recipientName, order.partnerShipping!['name'].toString()),
            if (order.partnerShipping!['phone'] != null && order.partnerShipping!['phone'].toString().isNotEmpty) ...[
              SizedBox(height: ResponsiveConstants.xsSpacing),
              _buildInfoRow(context, loc.phoneNumber, order.partnerShipping!['phone'].toString()),
            ],
            if (order.partnerShipping!['mobile'] != null && order.partnerShipping!['mobile'].toString().isNotEmpty) ...[
              SizedBox(height: ResponsiveConstants.xsSpacing),
              _buildInfoRow(context, loc.mobileNumber, order.partnerShipping!['mobile'].toString()),
            ],
            SizedBox(height: ResponsiveConstants.smSpacing),
          ],
          
          _buildInfoRow(context, loc.deliveryAddress, order.shippingAddress),
          
          // Show detailed address components if available
          if (order.partnerShipping != null && order.partnerShipping!.isNotEmpty) ...[
            if (order.partnerShipping!['street'] != null && order.partnerShipping!['street'].toString().isNotEmpty) ...[
              SizedBox(height: ResponsiveConstants.xsSpacing),
              _buildInfoRow(context, loc.street, order.partnerShipping!['street'].toString()),
            ],
            if (order.partnerShipping!['street2'] != null && order.partnerShipping!['street2'].toString().isNotEmpty) ...[
              SizedBox(height: ResponsiveConstants.xsSpacing),
              _buildInfoRow(context, loc.street2, order.partnerShipping!['street2'].toString()),
            ],
            if (order.partnerShipping!['city'] != null && order.partnerShipping!['city'].toString().isNotEmpty) ...[
              SizedBox(height: ResponsiveConstants.xsSpacing),
              _buildInfoRow(context, loc.city, order.partnerShipping!['city'].toString()),
            ],
            if (order.partnerShipping!['state'] != null && order.partnerShipping!['state'].toString().isNotEmpty) ...[
              SizedBox(height: ResponsiveConstants.xsSpacing),
              _buildInfoRow(context, loc.state, order.partnerShipping!['state'].toString()),
            ],
            if (order.partnerShipping!['zip'] != null && order.partnerShipping!['zip'].toString().isNotEmpty) ...[
              SizedBox(height: ResponsiveConstants.xsSpacing),
              _buildInfoRow(context, loc.zipCode, order.partnerShipping!['zip'].toString()),
            ],
            if (order.partnerShipping!['country'] != null && order.partnerShipping!['country'].toString().isNotEmpty) ...[
              SizedBox(height: ResponsiveConstants.xsSpacing),
              _buildInfoRow(context, loc.country, order.partnerShipping!['country'].toString()),
            ],
            SizedBox(height: ResponsiveConstants.smSpacing),
          ],
          
          if (order.deliveredDate != null) ...[
            SizedBox(height: ResponsiveConstants.smSpacing),
            _buildInfoRow(
              context,
              loc.deliveredOn,
              OrderDateUtils.formatDate(context, order.deliveredDate!),
            ),
          ],
          
          if (order.status.name == 'shipped') ...[
            SizedBox(height: ResponsiveConstants.smSpacing),
              Container(
              padding: EdgeInsets.all(ResponsiveConstants.smPadding),
              decoration: BoxDecoration(
                color: OrderConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                border: Border.all(color: OrderConstants.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  if (!isRTL) Icon(Icons.info_outline, color: OrderConstants.primaryColor, size: 16),
                  if (!isRTL) SizedBox(width: ResponsiveConstants.xsSpacing),
                  Expanded(
                    child: Text(
                      loc.orderOnWayMessage,
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                        color: OrderConstants.primaryColorDark,
                      ),
                    ),
                  ),
                  if (isRTL) SizedBox(width: ResponsiveConstants.xsSpacing),
                  if (isRTL) Icon(Icons.info_outline, color: OrderConstants.primaryColor, size: 16),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final loc = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final colorScheme = Theme.of(context).colorScheme;
    final isPhoneField = label == loc.phoneNumber || label == loc.mobileNumber;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.xsSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Expanded(
            child: isPhoneField
                ? Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      value,
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  )
                : Text(
                    value,
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
