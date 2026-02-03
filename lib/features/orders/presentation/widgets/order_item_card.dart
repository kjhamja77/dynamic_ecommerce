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
    final currency = context.watch<CurrencyProvider>();
    final locale = Localizations.localeOf(context);
    final String? imageUrl = item.product.images.isNotEmpty ? item.product.images.first : null;

    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? _OrderItemImageLoader(imageUrl: imageUrl)
                : _buildImagePlaceholder(),
          ),
          
          SizedBox(width: ResponsiveConstants.mdPadding),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                // Display variant details (color, size, brand, and other attributes if available)
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
                    
                    // Add brand if available and not already in product name
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
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.smSpacing),
                Text(
                  currency.formatPrice(item.price, locale: locale),
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade300,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade400,
        size: ResponsiveConstants.smIconSize,
      ),
    );
  }

  Widget _buildVariantChip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.smPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.xsFontSize,
          color: Colors.grey.shade700,
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _imageDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
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
          width: 80,
          height: 80,
          fit: BoxFit.contain,
          httpHeaders: headers,
          memCacheWidth: 160, // 2x for retina displays
          memCacheHeight: 160,
          placeholder: (context, url) => Container(
            width: 80,
            height: 80,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            debugPrint('❌ OrderItemCard: Failed to load image: $url, error: $error');
            return Container(
              width: 80,
              height: 80,
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
