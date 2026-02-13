import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zalando_clone_app/core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/core/widgets/app_loading_widget.dart';
import 'package:zalando_clone_app/core/utils/image_cache_utils.dart';
import 'package:zalando_clone_app/l10n/app_localizations.dart';
import 'package:zalando_clone_app/features/home/domain/entities/product.dart';
import 'package:zalando_clone_app/features/favorites/presentation/widgets/favorite_button.dart';
import '../../../../../core/providers/currency_provider.dart';
import '../../../../../core/theme/app_fonts.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String productType; // 'variant' or 'template'
  final bool isCompact; // compact mode for smaller lists
  final bool showFavoriteBadge; // controls built-in favorite badge visibility

  const ProductCard({
    super.key,
    required this.product,
    this.productType = 'variant', // Default to variant for backward compatibility
    this.isCompact = false,
    this.showFavoriteBadge = true,
  });

  // Responsive helper method for card info height (compact values must match ResponsiveConstants.productDetailsCompactCardHeight formula).
  double _getCardInfoHeight() {
    if (isCompact) {
      if (1.sw >= 900) return 106.h; // Tablet and desktop (compact) – brand + 2-line title + price + headroom
      if (1.sw >= 600) return 102.h; // Large phones (compact)
      return 98.h;                   // Small phones (compact)
    }
    // Slightly reduced heights to avoid vertical overflow inside grid tiles,
    // especially on smaller screens with larger text scales.
    if (1.sw >= 900) return 90.h; // Tablet and desktop
    if (1.sw >= 600) return 85.h; // Large phones
    return 80.h;                  // Small phones
  }


  // Responsive helper method for aspect ratio (compact values must match ResponsiveConstants.productDetailsCompactCardHeight formula).
  double _getImageAspectRatio() {
    if (isCompact) {
      if (1.sw >= 900) return 1.45;
      if (1.sw >= 600) return 1.5;
      return 1.55;
    }
    if (1.sw >= 900) return 1.1; // Tablet and desktop
    if (1.sw >= 600) return 1.15; // Large phones
    return 1.2;                  // Small phones
  }

  // Responsive helper method for brand font size
  double _getResponsiveBrandFontSize() {
    if (isCompact) {
      if (1.sw >= 900) return ResponsiveConstants.brandFontSize - 1; // compact reduction
      if (1.sw >= 600) return ResponsiveConstants.brandFontSize - 1.5;
      return ResponsiveConstants.brandFontSize - 2;
    }
    if (1.sw >= 900) return ResponsiveConstants.brandFontSize; // Tablet and desktop
    if (1.sw >= 600) return ResponsiveConstants.brandFontSize - 0.5; // Large phones
    return ResponsiveConstants.brandFontSize - 1; // Small phones
  }

  // Responsive helper method for product name font size
  double _getResponsiveProductNameFontSize() {
    if (isCompact) {
      if (1.sw >= 900) return ResponsiveConstants.productNameFontSize - 1; // compact reduction
      if (1.sw >= 600) return ResponsiveConstants.productNameFontSize - 1.5;
      return ResponsiveConstants.productNameFontSize - 2;
    }
    if (1.sw >= 900) return ResponsiveConstants.productNameFontSize; // Tablet and desktop
    if (1.sw >= 600) return ResponsiveConstants.productNameFontSize - 0.5; // Large phones
    return ResponsiveConstants.productNameFontSize - 1; // Small phones
  }

  // Responsive helper method for spacing
  double _getResponsiveSpacing() {
    if (isCompact) {
      if (1.sw >= 900) return 1.5; // tighter spacing
      if (1.sw >= 600) return 1.25;
      return 1;
    }
    if (1.sw >= 900) return 2; // Tablet and desktop
    if (1.sw >= 600) return 1.5; // Large phones
    return 1; // Small phones
  }

  // Helper method to detect Arabic text
  bool _containsArabic(String text) {
    final arabicRegex = RegExp(r"[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]");
    return arabicRegex.hasMatch(text);
  }

  // Extract clean product name (remove variant details in parentheses)
  String _getCleanProductName(String fullName) {
    // Check if name contains variant details in parentheses: "Product Name (Color, Size)"
    final match = RegExp(r'^(.+?)\s*\(([^)]+)\)\s*$').firstMatch(fullName);
    if (match != null) {
      return match.group(1)?.trim() ?? fullName;
    }
    return fullName;
  }


  @override
  Widget build(BuildContext context) {
    final bool isNew = product.isNew;
    final currencyProvider = context.watch<CurrencyProvider>();

    return GestureDetector(
      onTap: () {
        print('═══════════════════════════════════════════════════════');
        print('🔗 ProductCard: Navigating to product details');
        print('  📦 Product ID: ${product.id}');
        print('  📛 Product Name: ${product.name}');
        print('  🏷️  Product Type (passed to details): $productType');
        print('  🏢 Product Brand: ${product.brand}');
        print('  💰 Product Price: ${product.price}');
        print('  📊 Product.type field: ${product.type}');
        print('═══════════════════════════════════════════════════════');
        Navigator.of(context).pushNamed(
          '/product-details',
          arguments: {
            'productId': product.id,
            'productType': productType,
          },
        );
      },
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;

          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // Remove outer padding so the image can touch the
            // card edges (top/left/right) as per design.
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Image with overlays
            AspectRatio(
              aspectRatio: _getImageAspectRatio(),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Builder(
                      builder: (context) {
                        final cs = Theme.of(context).colorScheme;
                        // Inner image card – round only the top corners so
                        // the bottom edge aligns flush with the info section.
                        return Container(
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(ResponsiveConstants.mdRadius),
                              topRight: Radius.circular(ResponsiveConstants.mdRadius),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: product.images.isNotEmpty
                                ? _ProductImageLoader(
                                    imageUrl: product.images.first,
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey.shade400,
                                      size: ResponsiveConstants.lgIconSize,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Favorite button badge (can be hidden by parent)
                  if (showFavoriteBadge)
                    Positioned(
                      top: ResponsiveConstants.smPadding,
                      right: ResponsiveConstants.smPadding,
                      child: FavoriteButton(
                        productId: product.id,
                        productName: product.name,
                        brand: product.brand,
                        price: product.price,
                        imageUrl: product.images.isNotEmpty ? product.images.first : null,
                        category: product.category,
                        size: ResponsiveConstants.favoriteButtonIconSize,
                        isCompact: true,
                      ),
                    ),

                  // Badges: Use real API data
                  if (product.isOnSale || (product.originalPrice != null && product.originalPrice! > product.price))
                    Positioned(
                      left: ResponsiveConstants.smPadding,
                      bottom: ResponsiveConstants.smPadding,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveConstants.smPadding,
                              vertical: ResponsiveConstants.xsPadding,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                            ),
                            child: Text(
                              product.saleBadge ?? AppLocalizations.of(context)!.discount,
                              style: AppFonts.getTextStyle(color: Colors.white,
                                fontSize: ResponsiveConstants.badgeFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (product.originalPrice != null && product.originalPrice! > product.price &&
                              (product.discountPercentage.isFinite && product.discountPercentage > 0)) ...[
                            SizedBox(width: ResponsiveConstants.xsSpacing),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveConstants.smPadding,
                                vertical: ResponsiveConstants.xsPadding,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                              ),
                              child: Text(
                                '-${product.discountPercentage.toInt()}%',
                                style: AppFonts.getTextStyle(color: Colors.red.shade700,
                                  fontSize: ResponsiveConstants.badgeFontSize,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else if (isNew)
                    Positioned(
                      left: ResponsiveConstants.smPadding,
                      bottom: ResponsiveConstants.smPadding,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveConstants.smPadding,
                          vertical: ResponsiveConstants.xsPadding,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.newBadge,
                          style: AppFonts.getTextStyle(color: Colors.white,
                            fontSize: ResponsiveConstants.badgeFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Show custom tags from API
                  if (product.tags != null && product.tags!.isNotEmpty)
                    Positioned(
                      left: ResponsiveConstants.smPadding,
                      bottom: ResponsiveConstants.smPadding,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveConstants.smPadding,
                          vertical: ResponsiveConstants.xsPadding,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                        ),
                        child: Text(
                          product.tags!.first,
                          style: AppFonts.getTextStyle(color: Colors.white,
                            fontSize: ResponsiveConstants.badgeFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info section - in compact mode wrap in Flexible so it only takes remaining height (avoids bottom overflow in fixed-height lists)
            if (isCompact)
              Flexible(
                child: _buildCardInfoSection(
                  context,
                  currencyProvider,
                  useRtl: null, // computed inside
                ),
              )
            else
              Builder(
                builder: (context) => _buildCardInfoSection(
                  context,
                  currencyProvider,
                  useRtl: null,
                ),
              ),
          ],
        ),
      );
        },
      ),
    );
  }

  Widget _buildCardInfoSection(
    BuildContext context,
    CurrencyProvider currencyProvider, {
    bool? useRtl,
  }) {
    final isRtl = useRtl ?? (Directionality.of(context) == TextDirection.rtl);
    final isBrandArabic = _containsArabic(product.brand);
    final isNameArabic = _containsArabic(product.name);
    final brandTextDirection = isBrandArabic
        ? TextDirection.rtl
        : (isRtl ? TextDirection.rtl : TextDirection.ltr);
    final nameTextDirection = isNameArabic
        ? TextDirection.rtl
        : (isRtl ? TextDirection.rtl : TextDirection.ltr);
    final useRtlValue = isBrandArabic || isNameArabic || isRtl;

    return Container(
      padding: EdgeInsets.all(
        isCompact ? ResponsiveConstants.xsPadding : ResponsiveConstants.smPadding,
      ),
      child: Column(
        crossAxisAlignment:
            useRtlValue ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Brand name
          Directionality(
            textDirection: brandTextDirection,
            child: Text(
              product.brand,
              style: AppFonts.getTextStyle(
                fontSize: _getResponsiveBrandFontSize(),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: brandTextDirection == TextDirection.rtl
                  ? TextAlign.right
                  : TextAlign.left,
            ),
          ),

          SizedBox(height: _getResponsiveSpacing()),

          // Product name (clean name without variant details)
          Directionality(
            textDirection: nameTextDirection,
            child: Text(
              _getCleanProductName(product.name),
              style: AppFonts.getTextStyle(
                fontSize: _getResponsiveProductNameFontSize(),
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
                height: 1.0,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: nameTextDirection == TextDirection.rtl
                  ? TextAlign.right
                  : TextAlign.left,
            ),
          ),

          SizedBox(height: _getResponsiveSpacing() * 1.5),

          // Price block – anchored directly under text for tighter, more
          // balanced layout within the card height.
          Builder(
            builder: (context) {
              final formattedPrice = currencyProvider.formatPrice(
                product.price,
                locale: Localizations.localeOf(context),
              );
              final formattedOriginalPrice = product.originalPrice != null
                  ? currencyProvider.formatPrice(
                      product.originalPrice!,
                      locale: Localizations.localeOf(context),
                    )
                  : null;

              debugPrint(
                '💰 ProductCard: Price=${product.price} → Formatted="$formattedPrice", Currency=${currencyProvider.currency}',
              );

              return _PriceBlock(
                priceText: formattedPrice,
                originalText: formattedOriginalPrice,
                discountPercent: product.hasDiscount
                    ? product.discountPercentage.toInt()
                    : null,
                isRtl: useRtlValue,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Widget that loads and caches the authenticated image data
/// This prevents the FutureBuilder from recreating the future on every rebuild
class _ProductImageLoader extends StatefulWidget {
  final String imageUrl;

  const _ProductImageLoader({
    required this.imageUrl,
  });

  @override
  State<_ProductImageLoader> createState() => _ProductImageLoaderState();
}

class _ProductImageLoaderState extends State<_ProductImageLoader> {
  late final Future<Map<String, dynamic>> _imageDataFuture;

  @override
  void initState() {
    super.initState();
    // Cache the future so it doesn't recreate on rebuild
    _imageDataFuture = ImageCacheUtils.getAuthenticatedImageData(
      widget.imageUrl,
      useCacheBuster: false, // Disable cache buster to prevent reloading on scroll
    );
  }

  @override
  void didUpdateWidget(_ProductImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only recreate future if image URL actually changed
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
          return Center(
            child: AppLoadingWidget.small(
              message: AppLocalizations.of(context)!.loading,
              showMessage: false,
            ),
          );
        }
        final data = snapshot.data!;
        final finalUrl = data['url'] as String;
        // Use normalized URL as cacheKey to ensure consistent caching
        // This prevents cache misses when URLs are normalized differently
        final cacheKey = ImageCacheUtils.normalizeImageUrl(widget.imageUrl);
        return CachedNetworkImage(
          imageUrl: finalUrl,
          cacheKey: cacheKey, // Use normalized original URL as cache key
          // Make the product image fill the available width/height
          // so there is no inner padding around the picture.
          fit: BoxFit.cover,
          httpHeaders: data['headers'] as Map<String, String>,
          placeholder: (context, url) => Center(
            child: AppLoadingWidget.small(
              message: AppLocalizations.of(context)!.loading,
              showMessage: false,
            ),
          ),
          errorWidget: (context, url, error) {
            // Show the real reason images fail (401/403/404/etc.)
            debugPrint(
              '❌ Product image failed to load'
              ' | raw=${widget.imageUrl}'
              ' | final=$url'
              ' | error=$error',
            );
            return Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey.shade400,
                size: ResponsiveConstants.lgIconSize,
              ),
            );
          },
        );
      },
    );
  }
}

class _PriceBlock extends StatelessWidget {
  final String priceText;
  final String? originalText;
  final int? discountPercent;
  final bool isRtl;

  const _PriceBlock({
    required this.priceText,
    this.originalText,
    this.discountPercent,
    this.isRtl = false,
  });

  // Responsive helper method for price font size
  double _getResponsivePriceFontSize() {
    if (1.sw >= 900) return ResponsiveConstants.priceFontSize; // Tablet and desktop
    if (1.sw >= 600) return ResponsiveConstants.priceFontSize - 1; // Large phones
    return ResponsiveConstants.priceFontSize - 2; // Small phones
  }

  // Responsive helper method for original price font size
  double _getResponsiveOriginalPriceFontSize() {
    if (1.sw >= 900) return ResponsiveConstants.originalPriceFontSize; // Tablet and desktop
    if (1.sw >= 600) return ResponsiveConstants.originalPriceFontSize - 0.5; // Large phones
    return ResponsiveConstants.originalPriceFontSize - 1; // Small phones
  }

  // Responsive helper method for spacing
  double _getResponsiveSpacing() {
    if (1.sw >= 900) return 2; // Tablet and desktop
    if (1.sw >= 600) return 1.5; // Large phones
    return 1; // Small phones
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalText != null && discountPercent != null;

    if (hasDiscount) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Flexible(
            child: Text(
              priceText,
              style: AppFonts.getTextStyle(fontSize: _getResponsivePriceFontSize(),
                fontWeight: FontWeight.w700,
                color: Colors.red.shade700,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
            ),
          ),
          SizedBox(width: _getResponsiveSpacing() * 2),
          Flexible(
            child: Text(
              originalText!,
              style: AppFonts.getTextStyle(fontSize: _getResponsiveOriginalPriceFontSize(),
                color: Colors.grey.shade600,
                decoration: TextDecoration.lineThrough,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      );
    } else {
      return Align(
        alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          priceText,
          style: AppFonts.getTextStyle(fontSize: _getResponsivePriceFontSize(),
            fontWeight: FontWeight.w700,
            color: Colors.red.shade700,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: isRtl ? TextAlign.right : TextAlign.left,
        ),
      );
    }
  }
}