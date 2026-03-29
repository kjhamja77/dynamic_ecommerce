import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../core/utils/order_date_utils.dart';
import '../../core/constants/order_constants.dart';

/// Widget to display comprehensive delivery details from the delivery status API
class DeliveryDetailsWidget extends StatelessWidget {
  final DeliveryStatusDto? deliveryStatus;

  const DeliveryDetailsWidget({
    super.key,
    this.deliveryStatus,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    if (deliveryStatus == null) {
      return const SizedBox.shrink();
    }

    final status = deliveryStatus!;
    final statusColor = _getStatusColor(status.status);
    final statusIcon = _getStatusIcon(status.status);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: EdgeInsets.all(ResponsiveConstants.mdPadding),
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            children: [
              if (!isRTL) Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: ResponsiveConstants.lgIconSize,
                ),
              ),
              if (!isRTL) SizedBox(width: ResponsiveConstants.mdSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.deliveryStatus,
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.smFontSize,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.xsSpacing),
                    Text(
                      status.status.trim(),
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.lgFontSize,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isRTL) SizedBox(width: ResponsiveConstants.mdSpacing),
              if (isRTL) Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: ResponsiveConstants.lgIconSize,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveConstants.lgSpacing),

          // Tracking Page Link
          if (status.trackingPage != null && status.trackingPage!.isNotEmpty) ...[
            Builder(
              builder: (context) {
                final cs = Theme.of(context).colorScheme;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final trackBg = isDark ? cs.primaryContainer : cs.primaryContainer;
                final trackFg = cs.onPrimaryContainer;
                return InkWell(
                  onTap: () async {
                    final uri = Uri.parse(status.trackingPage!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                    decoration: BoxDecoration(
                      color: trackBg.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                      border: Border.all(color: trackFg.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        if (!isRTL) Icon(Icons.track_changes_outlined, size: 20, color: trackFg),
                        if (!isRTL) SizedBox(width: ResponsiveConstants.smSpacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.trackYourOrder,
                                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                                style: AppFonts.getTextStyle(
                                  fontSize: ResponsiveConstants.smFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: trackFg,
                                ),
                              ),
                              SizedBox(height: ResponsiveConstants.xsSpacing),
                              Text(
                                loc.viewDetailedTrackingInformation,
                                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                                style: AppFonts.getTextStyle(
                                  fontSize: ResponsiveConstants.xsFontSize,
                                  color: trackFg.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isRTL) SizedBox(width: ResponsiveConstants.smSpacing),
                        if (isRTL) Icon(Icons.track_changes_outlined, size: 20, color: trackFg),
                        Icon(Icons.arrow_forward_ios, size: 16, color: trackFg),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
          ],

          // Status History Timeline
          if (status.lastStatuses.isNotEmpty) ...[
            Divider(height: ResponsiveConstants.lgSpacing),
            Align(
              alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                loc.statusHistory,
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),
            ...status.lastStatuses.asMap().entries.map((entry) {
              final index = entry.key;
              final statusHistory = entry.value;
              final isLast = index == status.lastStatuses.length - 1;
              
              return _buildStatusHistoryItem(
                context,
                statusHistory,
                isLast: isLast,
                isFirst: index == 0,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusHistoryItem(
    BuildContext context,
    DeliveryStatusHistoryDto statusHistory, {
    required bool isLast,
    required bool isFirst,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(statusHistory.slug);
    final dateTime = statusHistory.createdAt;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : ResponsiveConstants.mdSpacing,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // Timeline indicator
          Column(
            children: [
              Builder(
                builder: (context) {
                  final cs = Theme.of(context).colorScheme;
                  return Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.surface,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                ),
            ],
          ),
          SizedBox(width: ResponsiveConstants.mdSpacing),
          // Status details
          Expanded(
            child: Column(
              crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  statusHistory.title,
                  textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (statusHistory.merchantTitle.isNotEmpty &&
                    statusHistory.merchantTitle != statusHistory.title) ...[
                  SizedBox(height: ResponsiveConstants.xsSpacing),
                  Text(
                    statusHistory.merchantTitle,
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.smFontSize,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                SizedBox(height: ResponsiveConstants.xsSpacing),
                Row(
                  mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    if (!isRTL) Icon(
                      Icons.access_time,
                      size: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    if (!isRTL) SizedBox(width: ResponsiveConstants.xsSpacing),
                    Text(
                      OrderDateUtils.formatDateTime(context, dateTime),
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.xsFontSize,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isRTL) SizedBox(width: ResponsiveConstants.xsSpacing),
                    if (isRTL) Icon(
                      Icons.access_time,
                      size: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                if (statusHistory.pivot != null &&
                    statusHistory.pivot!.carrierMessage != null &&
                    statusHistory.pivot!.carrierMessage!.isNotEmpty) ...[
                  SizedBox(height: ResponsiveConstants.xsSpacing),
                  Container(
                    padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        if (!isRTL) Icon(
                          Icons.message_outlined,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        if (!isRTL) SizedBox(width: ResponsiveConstants.xsSpacing),
                        Expanded(
                          child: Text(
                            statusHistory.pivot!.carrierMessage!,
                            textAlign: isRTL ? TextAlign.right : TextAlign.left,
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.xsFontSize,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (isRTL) SizedBox(width: ResponsiveConstants.xsSpacing),
                        if (isRTL) Icon(
                          Icons.message_outlined,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    return OrderConstants.getDeliveryStatusColor(status);
  }

  IconData _getStatusIcon(String status) {
    return OrderConstants.getDeliveryStatusIcon(status);
  }

}

