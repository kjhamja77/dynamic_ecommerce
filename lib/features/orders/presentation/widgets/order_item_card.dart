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
    final String? imageUrl = item.product.images.isNotEmpty ? item.product.images.first : null;

    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: ResponsiveConstants.xsSpacing,
                          runSpacing: ResponsiveConstants.xsSpacing,
                          children: variantChips,
                        ),
                        SizedBox(height: ResponsiveConstants.xsSpacing),
                      ],
                    );
                  },
                ),
                Text(
                  '${loc.quantity}: ${item.quantity}',
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.smFontSize,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.smSpacing),
                Text(
                  currency.formatPrice(item.price, locale: locale),
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
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
