import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'dart:async';

class OrderItemCard extends StatelessWidget {
  final CartItem item;

  const OrderItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currency = context.watch<CurrencyProvider>();
    final locale = Localizations.localeOf(context);
    final String? imageUrl =
        item.product.images.isNotEmpty ? item.product.images.first : null;
    final bool isCoupon = item.isCoupon;

    if (isCoupon) {
      return _buildCouponCard(context, colorScheme, currency, locale);
    } else {
      return _buildProductItemCard(
        context,
        colorScheme,
        currency,
        locale,
        imageUrl,
      );
    }
  }

  /// Standard product line card (unchanged layout)
  Widget _buildProductItemCard(
    BuildContext context,
    ColorScheme colorScheme,
    CurrencyProvider currency,
    Locale locale,
    String? imageUrl,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? _OrderItemImageLoader(imageUrl: imageUrl)
                : _buildImagePlaceholder(context),
          ),
          SizedBox(width: ResponsiveConstants.mdPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                Builder(
                  builder: (context) {
                    final variantChips = <Widget>[];
                    if (item.selectedSize.isNotEmpty) {
                      variantChips.add(
                        _buildVariantChip(
                          context,
                          '${loc.size}: ${item.selectedSize}',
                        ),
                      );
                    }
                    if (item.selectedColor.isNotEmpty) {
                      variantChips.add(
                        _buildVariantChip(
                          context,
                          '${loc.color}: ${item.selectedColor}',
                        ),
                      );
                    }
                    if (item.product.brand.isNotEmpty) {
                      variantChips.add(
                        _buildVariantChip(
                          context,
                          '${loc.brand}: ${item.product.brand}',
                        ),
                      );
                    }
                    if (variantChips.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: ResponsiveConstants.xsSpacing),
                      child: Wrap(
                        spacing: ResponsiveConstants.xsSpacing,
                        runSpacing: ResponsiveConstants.xsSpacing,
                        children: variantChips,
                      ),
                    );
                  },
                ),
                SizedBox(height: ResponsiveConstants.smSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${loc.quantity}: ${item.quantity}',
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.smFontSize,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      currency.formatPrice(item.lineTotal, locale: locale),
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Visually distinct coupon/discount card.
  Widget _buildCouponCard(
    BuildContext context,
    ColorScheme colorScheme,
    CurrencyProvider currency,
    Locale locale,
  ) {
    return Container(
      margin: EdgeInsets.only(top: ResponsiveConstants.xsSpacing),
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Coupon icon tile instead of product image
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.local_offer_outlined,
              color: colorScheme.error,
              size: 26,
            ),
          ),
          SizedBox(width: ResponsiveConstants.mdPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.mdFontSize,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveConstants.smPadding,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(ResponsiveConstants.smRadius),
                      ),
                      child: Text(
                        'Coupon',
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.xsFontSize,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                // Negative amount directly under the title
                Text(
                  currency.formatPrice(item.lineTotal, locale: locale),
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildImagePlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 80,
      height: 80,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colorScheme.outline,
        size: ResponsiveConstants.smIconSize,
      ),
    );
  }

  Widget _buildVariantChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.smPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.xsFontSize,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Image loader widget for order items that handles authenticated image loading
/// Similar to _ProductImageLoader in product_card.dart for consistency
class _OrderItemImageLoader extends StatefulWidget {
  final String imageUrl;

  const _OrderItemImageLoader({
    required this.imageUrl,
  });

  @override
  State<_OrderItemImageLoader> createState() => _OrderItemImageLoaderState();
}

class _OrderItemImageLoaderState extends State<_OrderItemImageLoader> {
  late Future<Map<String, dynamic>> _imageDataFuture;

  @override
  void initState() {
    super.initState();
    _imageDataFuture = ImageCacheUtils.getAuthenticatedImageData(
      widget.imageUrl,
      useCacheBuster: false, // Disable cache buster to prevent reloading on scroll/navigation
    );
  }

  @override
  void didUpdateWidget(_OrderItemImageLoader oldWidget) {
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
            width: 80,
            height: 80,
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
          width: 80,
          height: 80,
          fit: BoxFit.contain,
          httpHeaders: headers,
          memCacheWidth: 160,
          memCacheHeight: 160,
          placeholder: (context, url) => Container(
            width: 80,
            height: 80,
            color: colorScheme.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
                color: colorScheme.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            debugPrint('❌ OrderItemCard: Failed to load image: $url, error: $error');
            return Container(
              width: 80,
              height: 80,
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
