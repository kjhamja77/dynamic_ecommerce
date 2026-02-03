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
    final currency = context.watch<CurrencyProvider>();
    final locale = Localizations.localeOf(context);
    final statusColor = OrderConstants.statusColors[order.status.name] ?? Colors.grey;
    final statusText = OrderConstants.localizedStatus(context, order.status);
    final String? imageUrl = order.items.isNotEmpty && order.items.first.product.images.isNotEmpty
        ? order.items.first.product.images.first
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: ResponsiveConstants.xsSpacing),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              SizedBox(width: ResponsiveConstants.xsSpacing),
                              Expanded(
                                child: Text(
                                  OrderDateUtils.formatDate(context, order.orderDate),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.getTextStyle(
                                    fontSize: ResponsiveConstants.xsFontSize,
                                    color: Colors.white.withValues(alpha: 0.8),
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
                            color: statusColor,
                            borderRadius: BorderRadius.circular(
                              ResponsiveConstants.smRadius,
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.xsFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveConstants.xsSpacing),
                        Text(
                          currency.formatPrice(order.totalAmount, locale: locale),
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.smFontSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
                          // Product image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              ResponsiveConstants.smRadius,
                            ),
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? _OrderCardImageLoader(imageUrl: imageUrl)
                                : _placeholderImage(),
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
                                    color: Colors.black87,
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
                                          color: Colors.grey.shade600,
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
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: ResponsiveConstants.xsSpacing),
                                Text(
                                  '${loc.quantity}: ${order.items.first.quantity}',
                                  style: AppFonts.getTextStyle(
                                    fontSize: ResponsiveConstants.xsFontSize,
                                    color: Colors.grey.shade600,
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
                          color: Colors.grey.shade400,
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

  Widget _placeholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade300,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade400,
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _imageDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final imageUrl = data['url'] as String;
        final headers = data['headers'] as Map<String, String>;

        return CachedNetworkImage(
          imageUrl: imageUrl,
          cacheKey: widget.imageUrl, // Use original URL as cache key for consistent caching
          width: 60,
          height: 60,
          fit: BoxFit.contain,
          httpHeaders: headers,
          memCacheWidth: 120, // 2x for retina displays
          memCacheHeight: 120,
          placeholder: (context, url) => Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            debugPrint('❌ OrderCard: Failed to load image: $url, error: $error');
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey.shade300,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey.shade400,
                size: ResponsiveConstants.smIconSize,
              ),
            );
          },
        );
      },
    );
  }
}
