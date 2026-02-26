import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/favorite_product.dart';
import '../../../home/domain/entities/product.dart';
import 'favorite_button.dart';
import 'add_to_cart_button.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class FavoriteProductCard extends StatelessWidget {
  final FavoriteProduct product;
  final bool isFavorite;
  final VoidCallback? onAddToCart;
  final Function(int)? onTabChanged;

  const FavoriteProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    this.onAddToCart,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Defensive check for required product properties
    try {
      if (product.id.isEmpty || product.name.isEmpty) {
        return const SizedBox.shrink();
      }
    } catch (e) {
      debugPrint('Error checking product properties: $e');
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pushNamed(
            '/product-details',
            arguments: {
              'productId': product.id,
              'productType': 'variant',
              'cardPreview': {
                'imageUrl': product.imageUrl,
                'brand': product.brand,
                'productTitle': product.name,
                'price': product.price,
              },
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
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.4 : 0.1,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Builder(
                builder: (context) {
                  final isRTL = Directionality.of(context) == TextDirection.rtl;
                  
                  return Stack(
                    children: [
                      // Main content: text + bigger image
                      Row(
                        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text + chips + add-to-cart at bottom (with padding)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                              child: Column(
                                crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                              // Brand + name + price (slightly smaller fonts)
                              Builder(
                                builder: (context) {
                                  final cs = Theme.of(context).colorScheme;
                                  final innerIsRTL = Directionality.of(context) == TextDirection.rtl;

                                  return Column(
                                    crossAxisAlignment: innerIsRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      if (product.brand.isNotEmpty)
                                        Text(
                                          product.brand,
                                          style: AppFonts.getTextStyle(
                                            fontSize: ResponsiveConstants.smFontSize - 1,
                                            fontWeight: FontWeight.w500,
                                            color: cs.onSurface.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      if (product.brand.isNotEmpty) SizedBox(height: ResponsiveConstants.xsSpacing),
                                      Text(
                                        product.name.isNotEmpty ? product.name : 'Product',
                                        style: AppFonts.getTextStyle(
                                          fontSize: ResponsiveConstants.mdFontSize - 1,
                                          fontWeight: FontWeight.w600,
                                          color: cs.onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: ResponsiveConstants.xsSpacing),
                                      Consumer<CurrencyProvider>(
                                        builder: (context, currencyProvider, child) {
                                          return Text(
                                            currencyProvider.formatPrice(
                                              product.price,
                                              locale: Localizations.localeOf(context),
                                            ),
                                            style: AppFonts.getTextStyle(
                                              fontSize: ResponsiveConstants.mdFontSize - 1,
                                              fontWeight: FontWeight.w700,
                                              color: cs.primary,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),

                              SizedBox(height: ResponsiveConstants.smSpacing),

                              // Variant detail chips
                              Builder(
                                builder: (context) {
                                  final loc = AppLocalizations.of(context);
                                  if (loc == null) return const SizedBox.shrink();
                                  final variantChips = _buildVariantChips(context, loc);

                                  if (variantChips.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Wrap(
                                    spacing: ResponsiveConstants.xsSpacing,
                                    runSpacing: ResponsiveConstants.xsSpacing,
                                    children: variantChips,
                                  );
                                },
                              ),

                              SizedBox(height: ResponsiveConstants.smSpacing),

                              // Add to cart button aligned based on locale
                              Align(
                                alignment: isRTL ? AlignmentDirectional.bottomEnd : AlignmentDirectional.bottomStart,
                                child: AddToCartButton(
                                  product: _convertToProduct(),
                                  size: 30,
                                  isCompact: true,
                                  onAddToCart: onAddToCart,
                                  onTabChanged: onTabChanged,
                                ),
                              ),
                                ],
                              ),
                            ),
                          ),
                          // Bigger product image flush to card edge (no padding, starts from edges) with favorite button
                          Stack(
                            children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: isRTL ? Radius.circular(12) : Radius.zero,
                                topRight: isRTL ? Radius.zero : Radius.circular(12),
                                bottomLeft: isRTL ? Radius.circular(12) : Radius.zero,
                                bottomRight: isRTL ? Radius.zero : Radius.circular(12),
                              ),
                              child: SizedBox(
                                width: 150,
                                height: 160,
                                child: product.imageUrl != null
                                    ? Hero(
                                        tag: 'product_image_${product.id}',
                                        child: Builder(
                                          builder: (context) {
                                            final cs = Theme.of(context).colorScheme;

                                            return CachedNetworkImage(
                                              imageUrl: product.imageUrl!,
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) => Container(
                                                color: cs.surface,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      cs.primary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                color: cs.surface,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: cs.onSurface.withValues(alpha: 0.4),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Hero(
                                        tag: 'product_image_${product.id}',
                                        child: Builder(
                                          builder: (context) {
                                            final cs = Theme.of(context).colorScheme;

                                            return Container(
                                              color: cs.surface,
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: cs.onSurface.withValues(alpha: 0.4),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ),
                            ),
                            // Favorite button positioned on the image (top-right for both LTR and RTL)
                            Positioned(
                              top: ResponsiveConstants.xsPadding,
                              left: isRTL ? ResponsiveConstants.xsPadding : null,
                              right: isRTL ? null : ResponsiveConstants.xsPadding,
                              child: FavoriteButton(
                                productId: product.id,
                                productName: product.name,
                                brand: product.brand,
                                price: product.price,
                                imageUrl: product.imageUrl,
                                category: product.category,
                                isFavorite: isFavorite,
                                size: 28,
                                isCompact: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Product _convertToProduct() {
    return Product(
      id: product.id,
      name: product.name,
      description: 'Product from favorites',
      price: product.price,
      originalPrice: null,
      images: product.imageUrl != null ? [product.imageUrl!] : [],
      category: product.category ?? 'General',
      brand: product.brand,
      type: 'variant', // Default for favorites
      rating: 0.0,
      reviewCount: 0,
      isAvailable: product.isAvailable, // Use actual stock status from FavoriteProduct
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Black', 'White', 'Blue'],
      createdAt: DateTime.now(),
    );
  }

  /// Parse variant details from product name and build chips
  /// Examples:
  /// - "[4828.113-38-NAVY/ NAVY] 4828.113 (38, NA..." -> Size: 38, Color: NAVY
  /// - "[8527.1-BLACK 01-37]" -> Color: BLACK 01, Size: 37
  List<Widget> _buildVariantChips(BuildContext context, AppLocalizations loc) {
    final chips = <Widget>[];
    final name = product.name;
    
    if (name.isEmpty) return chips;
    
    // Extract variant details from product name
    // Pattern 1: [CODE-SIZE-COLOR] or [CODE-COLOR-SIZE]
    // Pattern 2: (SIZE, COLOR) in parentheses
    
    String? size;
    String? color;
    
    // Helper to check if a string looks like a color name (not a product description)
    bool looksLikeColor(String s) {
      if (s.isEmpty) return false;
      final trimmed = s.trim();
      // Too long to be a color name (likely product description)
      if (trimmed.length > 30) return false;
      // Contains only numbers and dots (likely a code)
      if (RegExp(r'^[\d.\s]+$').hasMatch(trimmed)) return false;
      // Contains Arabic characters and is long (likely product description)
      if (RegExp(r'[\u0600-\u06FF]').hasMatch(trimmed) && trimmed.length > 15) return false;
      // Common color patterns (uppercase, short, etc.)
      if (trimmed.length <= 20 && !trimmed.contains(' ') || trimmed.split(' ').length <= 3) {
        return true;
      }
      return false;
    }
    
    // Try to extract from brackets: [CODE-SIZE-COLOR] or [CODE-COLOR-SIZE]
    final bracketMatch = RegExp(r'\[([^\]]+)\]').firstMatch(name);
    if (bracketMatch != null) {
      final content = bracketMatch.group(1);
      if (content == null) return chips;
      final parts = content.split('-');
      
      // Check each part to identify size (numeric) and color (text)
      for (final part in parts) {
        final trimmed = part.trim();
        // Remove slashes and extra spaces (e.g., "NAVY/ NAVY" -> "NAVY")
        final cleaned = trimmed.split('/').first.trim();
        
        // Check if it's a size (numeric)
        if (RegExp(r'^\d+$').hasMatch(cleaned)) {
          size = cleaned;
        } else if (cleaned.isNotEmpty && 
                   looksLikeColor(cleaned) &&
                   !RegExp(r'^[\d.]+$').hasMatch(cleaned)) { // Not just numbers/dots
          // Likely a color name
          if (color == null || color.isEmpty) {
            color = cleaned;
          }
        }
      }
    }
    
    // Try to extract from parentheses: (SIZE, COLOR) or (38, NA...)
    if (size == null || color == null) {
      final parenMatch = RegExp(r'\(([^)]+)\)').firstMatch(name);
      if (parenMatch != null) {
        final content = parenMatch.group(1);
        if (content == null) return chips;
        final parts = content.split(',');
        for (final part in parts) {
          final trimmed = part.trim();
          if (RegExp(r'^\d+$').hasMatch(trimmed) && size == null) {
            size = trimmed;
          } else if (trimmed.isNotEmpty && 
                     looksLikeColor(trimmed) && 
                     color == null) {
            color = trimmed;
          }
        }
      }
    }
    
    // Only build chips if we found valid variants
    // Don't extract from the entire name as it's too error-prone
    
    // Build chips for found variants
    if (size != null && size.isNotEmpty) {
      chips.add(_buildVariantChip(
        context,
        '${loc.size}: $size',
      ));
    }
    
    if (color != null && color.isNotEmpty) {
      chips.add(_buildVariantChip(
        context,
        '${loc.color}: $color',
      ));
    }
    
    // Always show brand if available
    if (product.brand.isNotEmpty && 
        product.name.isNotEmpty &&
        !product.name.toLowerCase().contains(product.brand.toLowerCase())) {
      chips.add(_buildVariantChip(
        context,
        '${loc.brand}: ${product.brand}',
      ));
    }
    
    return chips;
  }

  Widget _buildVariantChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.smPadding,
        vertical: ResponsiveConstants.xsPadding / 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.xsFontSize,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
