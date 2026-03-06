import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../core/constants/order_constants.dart';
import '../../core/utils/order_date_utils.dart';
import '../../domain/entities/order.dart';
import 'dart:async';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currency = context.watch<CurrencyProvider>();
    final locale = Localizations.localeOf(context);

    // Use backend order_status value for status chip text and color.
    final String rawStatus = (order.orderStatus ?? '').trim();
    final String statusKey = rawStatus.toLowerCase();
    final Color statusColor =
        OrderConstants.statusColors[statusKey] ?? colorScheme.outline;
    final String statusText = rawStatus.isNotEmpty
        ? rawStatus
        : OrderConstants.localizedStatus(context, order.status);

    final String? imageUrl = order.items.isNotEmpty &&
            order.items.first.product.images.isNotEmpty
        ? order.items.first.product.images.first
        : null;

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
                color: colorScheme.shadow.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with order number, date and status
              Container(
                padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
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
                    topLeft: Radius.circular(ResponsiveConstants.mdRadius),
                    topRight: Radius.circular(ResponsiveConstants.mdRadius),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.orderNumberWithValue(order.orderNumber),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.mdFontSize,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          SizedBox(height: ResponsiveConstants.xsSpacing),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: colorScheme.onPrimary.withValues(alpha: 0.8),
                              ),
                              SizedBox(width: ResponsiveConstants.xsSpacing),
                              Expanded(
                                child: Text(
                                  OrderDateUtils.formatDate(context, order.orderDate),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.getTextStyle(
                                    fontSize: ResponsiveConstants.xsFontSize,
                                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
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
                            horizontal: ResponsiveConstants.smPadding,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              ResponsiveConstants.smRadius,
                            ),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 140,
                            ),
                            child: Text(
                              statusText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.xsFontSize,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveConstants.xsSpacing),
                        Text(
                          currency.formatPrice(order.totalAmount, locale: locale),
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.smFontSize,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Body: first item + meta
              Padding(
                padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.items.isNotEmpty) ...[
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              ResponsiveConstants.smRadius,
                            ),
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? _OrderCardImageLoader(imageUrl: imageUrl)
                                : _placeholderImage(context),
                          ),
                          SizedBox(width: ResponsiveConstants.mdSpacing),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.items.first.product.name,
                                  style: AppFonts.getTextStyle(
                                    fontSize: ResponsiveConstants.mdFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: ResponsiveConstants.xsSpacing),
                                Row(
                                  children: [
                                    if (order.items.first.selectedSize.isNotEmpty) ...[
                                      Text(
                                        '${loc.size}: ${order.items.first.selectedSize}',
                                        style: AppFonts.getTextStyle(
                                          fontSize: ResponsiveConstants.xsFontSize,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            order.items.first.selectedColor.isNotEmpty
                                                ? ResponsiveConstants.smSpacing
                                                : 0,
                                      ),
                                    ],
                                    if (order.items.first.selectedColor.isNotEmpty)
                                      Text(
                                        '${loc.color}: ${order.items.first.selectedColor}',
                                        style: AppFonts.getTextStyle(
                                          fontSize: ResponsiveConstants.xsFontSize,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: ResponsiveConstants.xsSpacing),
                                Text(
                                  '${loc.quantity}: ${order.items.first.quantity}',
                                  style: AppFonts.getTextStyle(
                                    fontSize: ResponsiveConstants.xsFontSize,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    SizedBox(height: ResponsiveConstants.mdSpacing),
                    Row(
                      children: [
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
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

  Widget _placeholderImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 60,
      height: 60,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colorScheme.outline,
        size: ResponsiveConstants.smIconSize,
      ),
    );
  }
}

/// Image loader widget for order card that handles authenticated image loading
/// Similar to _ProductImageLoader in product_card.dart and _OrderItemImageLoader for consistency
class _OrderCardImageLoader extends StatefulWidget {
  final String imageUrl;

  const _OrderCardImageLoader({
    required this.imageUrl,
  });

  @override
  State<_OrderCardImageLoader> createState() => _OrderCardImageLoaderState();
}

class _OrderCardImageLoaderState extends State<_OrderCardImageLoader> {
  late Future<Map<String, dynamic>> _imageDataFuture;

  @override
  void initState() {
    super.initState();
    _imageDataFuture = ImageCacheUtils.getAuthenticatedImageData(
      widget.imageUrl,
      useCacheBuster: false, // Disable cache buster to prevent reloading on scroll, same as product card
    );
  }

  @override
  void didUpdateWidget(_OrderCardImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageDataFuture = ImageCacheUtils.getAuthenticatedImageData(
        widget.imageUrl,
        useCacheBuster: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<Map<String, dynamic>>(
      future: _imageDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: 60,
            height: 60,
            color: colorScheme.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
                color: colorScheme.primary,
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final imageUrl = data['url'] as String;
        final headers = data['headers'] as Map<String, String>;

        return CachedNetworkImage(
          imageUrl: imageUrl,
          cacheKey: widget.imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.contain,
          httpHeaders: headers,
          memCacheWidth: 120,
          memCacheHeight: 120,
          placeholder: (context, url) => Container(
            width: 60,
            height: 60,
            color: colorScheme.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
                color: colorScheme.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            debugPrint('❌ OrderCard: Failed to load image: $url, error: $error');
            return Container(
              width: 60,
              height: 60,
              color: colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: colorScheme.outline,
                size: ResponsiveConstants.smIconSize,
              ),
            );
          },
        );
      },
    );
  }
}
