import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../core/constants/order_constants.dart';
import '../../core/utils/order_date_utils.dart';
import '../../domain/entities/refund_request.dart';

class RefundRequestCard extends StatelessWidget {
  final RefundRequest refundRequest;
  final VoidCallback? onTap;

  const RefundRequestCard({
    super.key,
    required this.refundRequest,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currency = context.watch<CurrencyProvider>();
    final locale = Localizations.localeOf(context);

    final statusLabel =
        (refundRequest.stateDisplay ?? refundRequest.state).toString();
    final statusKey = (refundRequest.state ?? '').toLowerCase();
    final Color statusColor = _mapRefundStatusColor(statusKey);

    final DateTime createdAt =
        refundRequest.createdAt ?? DateTime.now();
    final double requestedAmount =
        refundRequest.totalRequestedAmount;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(
                  alpha:
                      theme.brightness == Brightness.dark ? 0.3 : 0.08,
                ),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding:
                    EdgeInsets.all(ResponsiveConstants.mdPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      OrderConstants.primaryColor,
                      OrderConstants.primaryColorDark,
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      ResponsiveConstants.mdRadius,
                    ),
                    topRight: Radius.circular(
                      ResponsiveConstants.mdRadius,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveConstants.xsPadding,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveConstants.smRadius,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.assignment_return_outlined,
                                      size: 12,
                                      color: colorScheme.onPrimary,
                                    ),
                                    SizedBox(
                                      width: ResponsiveConstants.xsSpacing,
                                    ),
                                    Text(
                                      loc.returns,
                                      style: AppFonts.getTextStyle(
                                        fontSize: ResponsiveConstants.xsFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: ResponsiveConstants.xsSpacing,
                          ),
                          Text(
                            // Reuse order number localization but show sale order name
                            loc.orderNumberWithValue(
                              refundRequest.orderName,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.getTextStyle(
                              fontSize:
                                  ResponsiveConstants.mdFontSize,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveConstants.xsSpacing,
                          ),
                          Text(
                            refundRequest.number,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.getTextStyle(
                              fontSize:
                                  ResponsiveConstants.xsFontSize,
                              color: colorScheme.onPrimary
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveConstants.xsSpacing,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: colorScheme.onPrimary
                                    .withValues(alpha: 0.8),
                              ),
                              SizedBox(
                                width: ResponsiveConstants.xsSpacing,
                              ),
                              Expanded(
                                child: Text(
                                  OrderDateUtils.formatDate(
                                    context,
                                    createdAt,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.getTextStyle(
                                    fontSize:
                                        ResponsiveConstants.xsFontSize,
                                    color: colorScheme.onPrimary
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveConstants.smPadding,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(
                              ResponsiveConstants.smRadius,
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style: AppFonts.getTextStyle(
                              fontSize:
                                  ResponsiveConstants.xsFontSize,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveConstants.xsSpacing,
                        ),
                        Text(
                          currency.formatPrice(
                            requestedAmount,
                            locale: locale,
                          ),
                          style: AppFonts.getTextStyle(
                            fontSize:
                                ResponsiveConstants.smFontSize,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: EdgeInsets.all(
                  ResponsiveConstants.mdPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reason',
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.smFontSize,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveConstants.xsSpacing,
                    ),
                    Text(
                      refundRequest.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.smFontSize,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveConstants.smSpacing,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _mapRefundStatusColor(String status) {
    switch (status) {
      case 'pending':
        return OrderConstants.warningColor;
      case 'approved':
      case 'processed':
        return OrderConstants.successColor;
      case 'rejected':
      case 'cancelled':
        return OrderConstants.errorColor;
      default:
        return OrderConstants.neutralColor;
    }
  }
}

