import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zalando_clone_app/core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/core/widgets/app_loading_widget.dart';
import 'package:zalando_clone_app/core/utils/image_cache_utils.dart';
import 'package:zalando_clone_app/core/widgets/authenticated_cached_image.dart';
import 'package:zalando_clone_app/l10n/app_localizations.dart';
import 'package:zalando_clone_app/features/home/domain/entities/product.dart';
import 'package:zalando_clone_app/features/favorites/presentation/widgets/favorite_button.dart';
import '../../../../../core/providers/currency_provider.dart';
import '../../../../../core/theme/app_fonts.dart';
import 'cart_quantity_button.dart';
import 'no_image_data_placeholder.dart';

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

  /// Detects if the card is in a horizontal layout (horizontal list)
  /// vs vertical layout (grid). Based on width/height constraints.
  bool _isHorizontalLayout(BoxConstraints constraints) {
    // If width is bounded and height is also bounded, check aspect ratio
    if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
      final aspectRatio = constraints.maxWidth / constraints.maxHeight;
      // Horizontal cards are typically wider than tall (aspect ratio > 1)
      // Vertical cards are typically taller than wide (aspect ratio < 1)
      return aspectRatio > 0.85; // Threshold to detect horizontal layout
    }
    // If only width is bounded (typical in horizontal ListView), it's horizontal
    if (constraints.hasBoundedWidth && !constraints.hasBoundedHeight) {
      return true;
    }
    // Default to vertical (grid) layout
    return false;
  }

  // Responsive helper method for aspect ratio. Smaller value = taller image (image fills more card height).
  double _getImageAspectRatio() {
    if (isCompact) {
      // Catalog: balanced ratio for mobile – image block not too wide or squat
      if (1.sw >= 900) return 0.98;
      if (1.sw >= 600) return 0.95;
      return 0.92; // small mobile – slightly taller image area
    }
    if (1.sw >= 900) return 0.80; // Tablet and desktop
    if (1.sw >= 600) return 0.84; // Large phones
    return 0.88;                   // Small phones – shorter card
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

  // Responsive helper method for product name font size (slightly smaller than brand)
  double _getResponsiveProductNameFontSize() {
    if (isCompact) {
      if (1.sw >= 900) return ResponsiveConstants.productNameFontSize - 4;
      if (1.sw >= 600) return ResponsiveConstants.productNameFontSize - 4;
      return ResponsiveConstants.productNameFontSize - 5;
    }
    if (1.sw >= 900) return ResponsiveConstants.productNameFontSize - 1;
    if (1.sw >= 600) return ResponsiveConstants.productNameFontSize - 1.5;
    return ResponsiveConstants.productNameFontSize - 4;
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

  /// Whether to show a dedicated brand line (omit placeholders like API "Unknown").
  bool _hasDisplayableBrand(String brand) {
    final t = brand.trim();
    if (t.isEmpty) return false;
    final lower = t.toLowerCase();
    if (lower == 'unknown' || lower == 'unknown brand') return false;
    return true;
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
            'cardPreview': {
              'imageUrl': product.images.isNotEmpty ? product.images.first : null,
              'brand': product.brand,
              'productTitle': _getCleanProductName(product.name),
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
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              // border: Border.all(
              //   color: colorScheme.outline.withValues(alpha: 0.2),
              // ),
              // Only apply shadow in light mode; in dark mode it appears as white glow.
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 2,
                        spreadRadius: 0.5,
                        offset: const Offset(0.5, 2),
                      ),
                    ],
            ),
            // Remove outer padding so the image can touch the
            // card edges (top/left/right) as per design.
            child: LayoutBuilder(
              builder: (context, constraints) {
                final hasBoundedHeight = constraints.hasBoundedHeight && 
                    constraints.maxHeight < double.infinity;
                final isHorizontal = _isHorizontalLayout(constraints);

                // Horizontal layout: image and info side by side or stacked with fixed ratios
                // Vertical layout: image on top, info below (default)
                if (isHorizontal && hasBoundedHeight) {
                  // Horizontal list layout - use Expanded with flex ratios
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Image section - takes 65% of available height (increased from 60%)
                      Expanded(
                        flex: 4,
                        child: _ProductCardImageSection(
                          product: product,
                          showFavoriteBadge: showFavoriteBadge,
                          isNew: isNew,
                          isHorizontal: true,
                        ),
                      ),

                      // Info section - takes 35% of available height, prevents overflow
                      Expanded(
                        flex: 2,
                        child: _buildCardInfoSection(
                          context,
                          currencyProvider,
                          useRtl: null,
                          isHorizontal: true,
                        ),
                      ),
                    ],
                  );
                }

                // Vertical layout (default) - for grids and unbounded lists
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    // Image with carousel, dot indicators, and color swatches
                    AspectRatio(
                      aspectRatio: _getImageAspectRatio(),
                      child: _ProductCardImageSection(
                        product: product,
                        showFavoriteBadge: showFavoriteBadge,
                        isNew: isNew,
                        isHorizontal: false,
                      ),
                    ),

                    // Spacing between image and info section (catalog card: extra space after image)
                    SizedBox(
                      height: isCompact
                          ? ResponsiveConstants.smSpacing
                          : (hasBoundedHeight ? 2.h : ResponsiveConstants.smSpacing),
                    ),

                    // Info section - adapts to content and constraints
                    if (hasBoundedHeight)
                      Expanded(
                        child: _buildCardInfoSection(
                          context,
                          currencyProvider,
                          useRtl: null,
                          isHorizontal: false,
                        ),
                      )
                    else
                      _buildCardInfoSection(
                        context,
                        currencyProvider,
                        useRtl: null,
                        isHorizontal: false,
                      ),
                  ],
                );
              },
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
    required bool isHorizontal,
  }) {
    final isRtl = useRtl ?? (Directionality.of(context) == TextDirection.rtl);
    final hasBrand = _hasDisplayableBrand(product.brand);
    final brandText = product.brand.trim();
    final isBrandArabic = hasBrand && _containsArabic(brandText);
    final isNameArabic = _containsArabic(product.name);
    final brandTextDirection = isBrandArabic
        ? TextDirection.rtl
        : (isRtl ? TextDirection.rtl : TextDirection.ltr);
    final nameTextDirection = isNameArabic
        ? TextDirection.rtl
        : (isRtl ? TextDirection.rtl : TextDirection.ltr);
    final useRtlValue = isBrandArabic || isNameArabic || isRtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if we're in a bounded height context (like GridView)
        final isConstrained = constraints.hasBoundedHeight && 
            constraints.maxHeight < double.infinity;

        // Adjust padding and spacing based on layout type and constraints
        final padding = EdgeInsets.symmetric(
          horizontal:
              isCompact ? ResponsiveConstants.xsPadding : ResponsiveConstants.smPadding,
          vertical: isHorizontal
              ? ResponsiveConstants.xsPadding // Tighter padding for horizontal
              : (isCompact 
                  ? ResponsiveConstants.xsPadding 
                  : (isConstrained ? 2.h : 3.h)),
        );

        // Catalog card (isCompact): adaptive spacing between brand, name, and price for better readability.
        final verticalSpacing = isHorizontal 
            ? 3.h // Tighter spacing for horizontal layout
            : (isCompact 
                ? ResponsiveConstants.smSpacing // catalog: clear gap between brand, name, price
                : (isConstrained ? 5.h : 5.h));

        final columnContent = Column(
          crossAxisAlignment:
              useRtlValue ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brand name (only when provided and not a placeholder)
            if (hasBrand) ...[
              Directionality(
                textDirection: brandTextDirection,
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    brandText,
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
              ),
              SizedBox(height: verticalSpacing),
            ],

              // Product name: secondary (grey) when brand is shown; primary (bold) when brand is missing/placeholder.
              Builder(
                builder: (context) {
                  final nameFontSize = _getResponsiveProductNameFontSize();
                  final brandFontSize = _getResponsiveBrandFontSize();
                  final lineHeightMultiplier = isConstrained ? 1.1 : 1.2;
                  final twoLineHeightSecondary =
                      (2 * nameFontSize * lineHeightMultiplier) + 4.h;
                  final twoLineHeightPrimary =
                      (2 * brandFontSize * lineHeightMultiplier) + 4.h;

                  if (!hasBrand) {
                    final primaryName = Directionality(
                      textDirection: nameTextDirection,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          _getCleanProductName(product.name),
                          style: AppFonts.getTextStyle(
                            fontSize: brandFontSize,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: lineHeightMultiplier,
                          ),
                          maxLines: isHorizontal ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: nameTextDirection == TextDirection.rtl
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                      ),
                    );
                    if (isHorizontal) return primaryName;
                    return SizedBox(
                      height: twoLineHeightPrimary,
                      child: Align(
                        alignment: useRtlValue
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: primaryName,
                      ),
                    );
                  }

                  final maxNameLines = isHorizontal ? 1 : 2;

                  final nameContent = Directionality(
                    textDirection: nameTextDirection,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        _getCleanProductName(product.name),
                        style: AppFonts.getTextStyle(
                          fontSize: nameFontSize,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                          height: lineHeightMultiplier,
                        ),
                        maxLines: maxNameLines,
                        overflow: TextOverflow.ellipsis,
                        textAlign: nameTextDirection == TextDirection.rtl
                            ? TextAlign.right
                            : TextAlign.left,
                      ),
                    ),
                  );

                  if (isHorizontal) return nameContent;
                  return SizedBox(
                    height: twoLineHeightSecondary,
                    child: Align(
                      alignment: useRtlValue
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: nameContent,
                    ),
                  );
                },
              ),

              SizedBox(height: verticalSpacing),

              // Price block
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

              // Add to cart button below price: commented out for now
              // if (!isHorizontal) ...[
              //   SizedBox(height: ResponsiveConstants.smSpacing),
              //   Align(
              //     alignment: useRtlValue ? Alignment.centerLeft : Alignment.centerRight,
              //     child: Directionality(
              //       textDirection: TextDirection.ltr,
              //       child: CartQuantityButton(
              //         product: product,
              //         productType: productType,
              //       ),
              //     ),
              //   ),
              //   SizedBox(height: isConstrained ? (ResponsiveConstants.smSpacing - 2).clamp(2.0, double.infinity) : ResponsiveConstants.smSpacing),
              // ],
            ],
          );

        return Container(
          padding: padding,
          child: isConstrained && constraints.maxHeight.isFinite
              ? SizedBox(
                  height: constraints.maxHeight,
                  child: ClipRect(
                    child: columnContent,
                  ),
                )
              : columnContent,
        );
      },
    );
  }
}

/// Image area with carousel, dot indicators, and color swatches
class _ProductCardImageSection extends StatefulWidget {
  final Product product;
  final bool showFavoriteBadge;
  final bool isNew;
  final bool isHorizontal; // Whether card is in horizontal list layout

  const _ProductCardImageSection({
    required this.product,
    required this.showFavoriteBadge,
    required this.isNew,
    this.isHorizontal = false,
  });

  @override
  State<_ProductCardImageSection> createState() => _ProductCardImageSectionState();
}

class _ProductCardImageSectionState extends State<_ProductCardImageSection> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static const int _maxVisibleColorSwatches = 4;
  static const double _colorSwatchSize = 13;
  static const double _colorSwatchOverlap = 5; // overlap so each circle attaches to the next
  static const double _carouselDotSize = 7.5;
  static const double _carouselDotSpacing = 5;
  static const double _colorSectionPadding = 5;
  static const double _colorSectionRadius = 8;
  static const double _colorSectionShadowBlur = 6;
  static const double _colorSectionShadowOpacity = 0.08;

  /// Build color image widget - shows image if available, falls back to color swatch
  Widget _buildColorImage(String colorName, double size) {
    // Try to get color image from product.colorImages
    final colorImages = widget.product.colorImages;
    String? colorImageUrl;
    
    if (colorImages != null && colorImages.containsKey(colorName) && colorImages[colorName]!.isNotEmpty) {
      colorImageUrl = colorImages[colorName]!.first;
    }
    
    // Background container: grey-to-black gradient with low opacity (transparent)
    final gradientBackground = BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey.withValues(alpha: 0.25),
          Colors.black.withValues(alpha: 0.20),
        ],
      ),
    );

    // If we have a color image URL, show it
    if (colorImageUrl != null && colorImageUrl.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: gradientBackground,
        padding: EdgeInsets.all(2),
        child: Container(
          width: size - 4,
          height: size - 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipOval(
            child: AuthenticatedCachedImage(
              imageUrl: colorImageUrl,
              fit: BoxFit.cover,
              placeholder: Container(
                color: Colors.grey.shade300,
                child: Center(
                  child: SizedBox(
                    width: size * 0.4,
                    height: size * 0.4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              errorWidget: Container(
                color: _colorFromName(colorName),
                child: Icon(
                  Icons.image_not_supported,
                  size: size * 0.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Fallback to color swatch if no image available
    return Container(
      width: size,
      height: size,
      decoration: gradientBackground,
      padding: EdgeInsets.all(2),
      child: Container(
        width: size - 4,
        height: size - 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _colorFromName(colorName),
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  /// Build color swatches section widget
  Widget _buildColorSwatchesSection(List<String> colors) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_colorSectionRadius),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: _colorSwatchSize + _colorSectionPadding * 2,
            maxHeight: _colorSwatchSize * _maxVisibleColorSwatches + 32,
          ),
          padding: EdgeInsets.all(_colorSectionPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.withValues(alpha: 0.25),
                Colors.black.withValues(alpha: 0.20),
              ],
            ),
            borderRadius: BorderRadius.circular(_colorSectionRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _colorSectionShadowOpacity),
                blurRadius: _colorSectionShadowBlur,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: _colorSwatchSize * min(colors.length, _maxVisibleColorSwatches),
                width: _colorSwatchSize,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    min(colors.length, _maxVisibleColorSwatches),
                    (i) => Transform.translate(
                      offset: Offset(0, i * -_colorSwatchOverlap),
                      child: _buildColorImage(
                        colors[i],
                        _colorSwatchSize,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${colors.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.0,
                ),
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Maps variant color name (e.g. from API) to display color. Dynamic: supports hex, exact name, and token match.
  static Color _colorFromName(String name) {
    final raw = name.trim();
    if (raw.isEmpty) return Colors.grey;
    final t = raw.toLowerCase();
    // 1) Hex: e.g. #FFE4C4 or FFE4C4
    final hex = t.replaceAll('#', '').replaceAll(' ', '');
    if (RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(hex)) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    // 2) Exact and common variant names (dynamic mapping from backend color text)
    const Map<String, Color> _names = {
      'black': Colors.black,
      'white': Colors.white,
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'grey': Colors.grey,
      'gray': Colors.grey,
      'brown': Color(0xFF795548),
      'navy': Color(0xFF1B3A6B),
      'beige': Color(0xFFF5DEB3),
      'pink': Colors.pink,
      'purple': Colors.purple,
      'cream': Color(0xFFFFFDD0),
      'offwhite': Color(0xFFFFFAF0),
      'off-white': Color(0xFFFFFAF0),
      'off white': Color(0xFFFFFAF0),
      'ivory': Color(0xFFFFFFF0),
      'gold': Color(0xFFFFD700),
      'silver': Color(0xFFC0C0C0),
      'tan': Color(0xFFD2B48C),
      'nude': Color(0xFFE3C6A8),
      'burgundy': Color(0xFF800020),
      'maroon': Color(0xFF800000),
      'wine': Color(0xFF722F37),
      'olive': Color(0xFF808000),
      'teal': Color(0xFF008080),
      'turquoise': Color(0xFF40E0D0),
      'coral': Color(0xFFFF7F50),
      'salmon': Color(0xFFFA8072),
      'lavender': Color(0xFFE6E6FA),
      'mint': Color(0xFF98FF98),
      'khaki': Color(0xFFC3B091),
      'charcoal': Color(0xFF36454F),
      'denim': Color(0xFF1560BD),
      'rose': Color(0xFFFF007F),
      'peach': Color(0xFFFFCBA4),
      'mustard': Color(0xFFFFDB58),
      'bronze': Color(0xFFCD7F32),
      'copper': Color(0xFFB87333),
      'champagne': Color(0xFFF7E7CE),
      'taupe': Color(0xFF483C32),
      'mauve': Color(0xFFE0B0FF),
      'camel': Color(0xFFC19A6B),
      'multi': Color(0xFF7E57C2),
    };
    final c = _names[t];
    if (c != null) return c;
    // 3) Token match: "light cream" -> try "cream", "dark blue" -> try "blue"
    final tokens = t.split(RegExp(r'[\s\-_]+')).where((s) => s.length > 1).toList();
    for (final token in tokens) {
      final tokenColor = _names[token];
      if (tokenColor != null) return tokenColor;
    }
    if (tokens.isNotEmpty) {
      final last = tokens.last;
      if (last.length >= 3) {
        for (final entry in _names.entries) {
          if (entry.key.contains(last) || last.contains(entry.key)) {
            return entry.value;
          }
        }
      }
    }
    // 4) Fallback: stable hash so same name always gets same color
    final hash = t.hashCode;
    final hue = (hash & 0xFFFF) % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.5, 0.55).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imageCount = product.images.isEmpty ? 1 : product.images.length;
    final showDots = imageCount > 1;
    final colors = product.colors;

    return Stack(
      children: [
        // Image carousel
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
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
              child: product.images.isEmpty
                  ? const NoImageDataPlaceholder(compact: true)
                  : widget.isHorizontal
                      ? _ProductImageLoader(imageUrl: product.images.first)
                      : PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          itemCount: imageCount,
                          itemBuilder: (context, index) => _ProductImageLoader(
                            imageUrl: product.images[index],
                          ),
                        ),
            ),
          ),
        ),

        // Carousel dot indicators - only for vertical layout (hidden in horizontal list)
        if (!widget.isHorizontal && showDots)
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageCount, (index) {
                final selected = index == _currentPage;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: _carouselDotSpacing / 2),
                  width: _carouselDotSize,
                  height: _carouselDotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                );
              }),
            ),
          ),

        // Color section: white container, stacked overlapping color images, count below (clipped to prevent overflow)
        // Position color swatches on right middle for horizontal layout, right top for vertical layout
        if (colors.isNotEmpty)
          Positioned(
            right: 6,
            top: widget.isHorizontal ? 0 : 60,
            bottom: widget.isHorizontal ? 0 : null,
            child: widget.isHorizontal
                ? Center(
                    child: _buildColorSwatchesSection(colors),
                  )
                : _buildColorSwatchesSection(colors),
          ),

        // Favorite button
        if (widget.showFavoriteBadge)
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

        // Sale badge
        // For horizontal layout, positioned lower on the card
        if (product.isOnSale || (product.originalPrice != null && product.originalPrice! > product.price))
          Positioned(
            left: ResponsiveConstants.smPadding,
            // Raise badge slightly in vertical layout so it doesn't cover the carousel dots
            bottom: widget.isHorizontal ? 25 : ResponsiveConstants.smPadding + 16,
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
                    style: AppFonts.getTextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveConstants.badgeFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (product.originalPrice != null &&
                    product.originalPrice! > product.price &&
                    product.discountPercentage.isFinite &&
                    product.discountPercentage > 0) ...[
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
                      style: AppFonts.getTextStyle(
                        color: Colors.red.shade700,
                        fontSize: ResponsiveConstants.badgeFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        else if (widget.isNew)
          Positioned(
            left: ResponsiveConstants.smPadding,
            bottom: widget.isHorizontal ? 25 : ResponsiveConstants.smPadding + 16,
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
                style: AppFonts.getTextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveConstants.badgeFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        // Custom tags from API
        if (product.tags != null && product.tags!.isNotEmpty)
          Positioned(
            left: ResponsiveConstants.smPadding,
            bottom: widget.isHorizontal ? 25 : ResponsiveConstants.smPadding + 16,
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
                style: AppFonts.getTextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveConstants.badgeFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
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
        return Container(
          color: Colors.white,
          child: CachedNetworkImage(
            imageUrl: finalUrl,
            cacheKey: cacheKey, // Use normalized original URL as cache key
            // Make the product image fill the available width/height
            // so there is no inner padding around the picture.
            fit: BoxFit.fitWidth,
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
          ),
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
    return ResponsiveConstants.priceFontSize - 4; // Small phones
  }

  // Responsive helper method for original price font size
  double _getResponsiveOriginalPriceFontSize() {
    // Slightly smaller than main price, especially on mobile
    if (1.sw >= 900) return ResponsiveConstants.originalPriceFontSize - 1; // Tablet and desktop
    if (1.sw >= 600) return ResponsiveConstants.originalPriceFontSize - 1.5; // Large phones
    return ResponsiveConstants.originalPriceFontSize - 3; // Small phones
  }

  // Responsive helper method for spacing
  double _getResponsiveSpacing() {
    if (1.sw >= 900) return 2; // Tablet and desktop
    if (1.sw >= 600) return 1.5; // Large phones
    return 1; // Small phones
  }

  /// Parse price text (e.g. "45000 IQD" or "د.ع 45000") into number and currency parts
  Map<String, String> _parsePriceText(String text) {
    // Try to split by space - format is usually "number currency" (LTR) or "currency number" (RTL)
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      // Check if first part is numeric (LTR: "45000 IQD")
      if (RegExp(r'^\d+\.?\d*$').hasMatch(parts[0])) {
        return {'number': parts[0], 'currency': parts.sublist(1).join(' ')};
      }
      // Check if last part is numeric (RTL: "د.ع 45000")
      if (RegExp(r'^\d+\.?\d*$').hasMatch(parts.last)) {
        return {'number': parts.last, 'currency': parts.sublist(0, parts.length - 1).join(' ')};
      }
    }
    // Fallback: assume entire string is number if no clear split
    return {'number': text, 'currency': ''};
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalText != null && discountPercent != null;
    final priceParts = _parsePriceText(priceText);
    final numberText = priceParts['number'] ?? priceText;
    final currencyText = priceParts['currency'] ?? '';
    final priceFontSize = _getResponsivePriceFontSize();
    final currencyFontSize = (priceFontSize - 5).clamp(8.0, priceFontSize);
    // Use app theme primary color (orange) for prices
    final theme = Theme.of(context);
    final priceColor = theme.colorScheme.primary;

    if (hasDiscount) {
      // Row: discounted price on the left, original (struck-through) price on the right
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // Discounted price (highlighted)
          Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Text(
                numberText,
                style: AppFonts.getTextStyle(
                  fontSize: priceFontSize,
                  fontWeight: FontWeight.w700,
                  color: priceColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (currencyText.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  currencyText,
                  style: AppFonts.getTextStyle(
                    fontSize: currencyFontSize,
                    fontWeight: FontWeight.w600,
                    color: priceColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ],
          ),
          SizedBox(width: _getResponsiveSpacing() * 4),
          // Original price (strikethrough)
          Flexible(
            child: Text(
              originalText!,
              style: AppFonts.getTextStyle(
                fontSize: _getResponsiveOriginalPriceFontSize(),
                color: Colors.grey.shade600,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.grey.shade600,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // Number in orange (app theme color)
            Text(
              numberText,
              style: AppFonts.getTextStyle(
                fontSize: priceFontSize,
                fontWeight: FontWeight.w700,
                color: priceColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            // Currency in orange (app theme color), smaller
            if (currencyText.isNotEmpty) ...[
              SizedBox(width: 2),
              Text(
                currencyText,
                style: AppFonts.getTextStyle(
                  fontSize: currencyFontSize,
                  fontWeight: FontWeight.w500,
                  color: priceColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ],
        ),
      );
    }
  }
}