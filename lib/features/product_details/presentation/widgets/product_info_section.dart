import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/product_details.dart';
import '../bloc/product_details_bloc.dart';
import 'about_product_section.dart';
import 'package:zalando_clone_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:zalando_clone_app/features/home/presentation/widgets/common/product_card.dart';
import 'package:zalando_clone_app/features/home/domain/entities/product.dart'
    as HomeProduct;
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'color_selection_section.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductDetails productDetails;

  const ProductInfoSection({super.key, required this.productDetails});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primary = colorScheme.primary;

    // Read lightweight loading flag from BLoC so we can show a loader while
    // variant/attribute combinations are being recomputed (e.g. after a
    // color or attribute change).
    final pdState = context.watch<ProductDetailsBloc>().state;
    final bool isVariantFilterLoading =
        pdState is ProductDetailsLoaded ? pdState.isVariantFilterLoading : false;

    return SliverToBoxAdapter(
      child: Container(
        // Follow page background in dark mode, subtle surface tint in light mode.
        color: isDark ? colorScheme.background : colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top spacing
            SizedBox(height: ResponsiveConstants.mdSpacing),

            // Product Header Card (Brand, Name, Price, Stock)
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.smPadding,
              ),
              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(
                  ResponsiveConstants.mdRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.35 : 0.06,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand and Name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productDetails.brand,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.mdFontSize,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            SizedBox(height: ResponsiveConstants.xsSpacing),
                            Text(
                              productDetails.name,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.lgFontSize,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: ResponsiveConstants.smSpacing),
                      // Stock badge
                      _StockBadge(productDetails: productDetails),
                    ],
                  ),

                  SizedBox(height: ResponsiveConstants.mdSpacing),

                  // Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          currencyProvider.formatPrice(
                            productDetails.price,
                            locale: Localizations.localeOf(context),
                          ),
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.xlFontSize,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                      if (productDetails.originalPrice != null) ...[
                        SizedBox(width: ResponsiveConstants.smSpacing),
                        Flexible(
                          child: Text(
                            currencyProvider.formatPrice(
                              productDetails.originalPrice!,
                              locale: Localizations.localeOf(context),
                            ),
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.mdFontSize,
                              color: Colors.grey.shade600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                      if (productDetails.originalPrice != null &&
                          productDetails.originalPrice! >
                              productDetails.price &&
                          (productDetails.discountPercentage ?? 0) > 0) ...[
                        SizedBox(width: ResponsiveConstants.smSpacing),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveConstants.smPadding,
                            vertical: ResponsiveConstants.xsPadding,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(
                              ResponsiveConstants.xsRadius,
                            ),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            '-${productDetails.discountPercentage}%',
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.smFontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (productDetails.originalPrice != null) ...[
                    SizedBox(height: ResponsiveConstants.xsSpacing),
                    Text(
                      AppLocalizations.of(context)!.vatIncluded,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.xsFontSize,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: ResponsiveConstants.mdSpacing),

            // Variant Attributes Card (Size, Material, Height, Width, etc.) - All Dynamic
            // Attributes are dynamically loaded from variant_attributes API response.
            // When a user selects an attribute value, it's stored in variantAttributeOptions.selectedValue
            // and used to filter variants via filterVariantsBySelectedAttributes() function.
            // Example: Selecting SIZE=36, COLOR=BLACK, MATERIALS=Synthetic Leather will filter
            // variant_combinations to find matching variants.
            if (productDetails.variantAttributeOptions.where((attrOption) {
              final name = attrOption.attributeName.toLowerCase();
              return name != 'color' && name != 'colour' && name != 'اللون';
            }).isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.smPadding,
                ),
                padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    ResponsiveConstants.mdRadius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.35 : 0.06,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isVariantFilterLoading
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveConstants.lgSpacing,
                        ),
                        child: Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: productDetails.variantAttributeOptions
                            .where((attrOption) {
                              final name =
                                  attrOption.attributeName.toLowerCase();
                              return name != 'color' &&
                                  name != 'colour' &&
                                  name != 'اللون' &&
                                  name != 'color name';
                            })
                            .map((attrOption) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: attrOption ==
                                          productDetails
                                              .variantAttributeOptions
                                              .where((a) {
                                                final n = a.attributeName
                                                    .toLowerCase();
                                                return n != 'color' &&
                                                    n != 'colour' &&
                                                    n != 'اللون' &&
                                                    n != 'color name';
                                              })
                                              .last
                                      ? 0
                                      : ResponsiveConstants.mdSpacing,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      attrOption.attributeName,
                                      style: AppFonts.getTextStyle(
                                        fontSize:
                                            ResponsiveConstants.mdFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            ResponsiveConstants.smSpacing),
                                    _buildFullWidthAttributeButtons(
                                      context: context,
                                      values: attrOption.values,
                                      primary: primary,
                                      productDetails: productDetails,
                                      attributeName: attrOption.attributeName,
                                    ),
                                  ],
                                ),
                              );
                            })
                            .toList(),
                      ),
              ),

            if (productDetails.variantAttributeOptions.where((attrOption) {
              final name = attrOption.attributeName.toLowerCase();
              return name != 'color' &&
                  name != 'colour' &&
                  name != 'اللون' &&
                  name != 'color name';
            }).isNotEmpty)
              SizedBox(height: ResponsiveConstants.mdSpacing),

            // Color Selection Card (visual swatches)
            if (productDetails.colorOptions.isNotEmpty) ...[
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.smPadding,
                ),
                padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    ResponsiveConstants.mdRadius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.35 : 0.06,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ColorSelectionSection(productDetails: productDetails),
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),
            ],

            // About Product Card
            if (productDetails.description.isNotEmpty) ...[
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.smPadding,
                ),
                padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    ResponsiveConstants.mdRadius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.35 : 0.06,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AboutProductSection(
                  description: productDetails.description,
                ),
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),
            ],

            // All Expandable Sections Grouped Together - COMMENTED OUT (keeping only recommended)

            // Customer Reviews Section - COMMENTED OUT
            /*
            _ExpandableSection(
              title: AppLocalizations.of(context)!.customerReviews,
              icon: Icons.rate_review,
              iconColor: Colors.orange.shade600,
              child: Container(
                padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: ResponsiveConstants.mdIconSize),
                        SizedBox(width: ResponsiveConstants.xsSpacing),
                        Text(
                          '${productDetails.rating}.0',
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: ResponsiveConstants.smSpacing),
                        Text(
                          '(${productDetails.reviewCount} reviews)',
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveConstants.mdSpacing),
                    Text(
                      'Be the first to review this product!',
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: ResponsiveConstants.smSpacing),
            
            // Deals and Offers Section - COMMENTED OUT
            _ExpandableSection(
              title: AppLocalizations.of(context)!.dealsAndOffers,
              icon: Icons.local_fire_department,
              iconColor: Colors.red.shade600,
              child: DealsAndOffersSection(
                hasActiveDiscount: productDetails.hasDiscount,
                discountPercentage: (productDetails.discountPercentage ?? 0).toDouble(),
                dealEndTime: productDetails.hasDiscount ? DateTime.now().add(const Duration(hours: 24)) : null,
              ),
            ),

            SizedBox(height: ResponsiveConstants.smSpacing),
            
            // Delivery Information - COMMENTED OUT
            _ExpandableSection(
              title: AppLocalizations.of(context)!.deliveryAndReturns,
              icon: Icons.local_shipping,
              iconColor: Colors.green.shade600,
              child: DeliveryInfoSection(
                isFreeDeliveryEligible: productDetails.price >= 29.90,
                estimatedDelivery: 'Tomorrow, Dec 15',
                orderTotal: productDetails.price,
              ),
            ),

            SizedBox(height: ResponsiveConstants.smSpacing),
            
            // Product Care & Materials - COMMENTED OUT
            _ExpandableSection(
              title: AppLocalizations.of(context)!.productCareAndMaterials,
              icon: Icons.info_outline,
              iconColor: Colors.blue.shade600,
              child: ProductCareSection(
                countryOfOrigin: AppLocalizations.of(context)!.turkey,
                careInstructions: [productDetails.careInstructions],
                materials: productDetails.materialsList.isNotEmpty
                    ? productDetails.materialsList
                    : [productDetails.material],
              ),
            ),

            // Heel details - COMMENTED OUT
            if (productDetails.heelHeightCm != null || productDetails.heelType != null) ...[
              SizedBox(height: ResponsiveConstants.smSpacing),
              _ExpandableSection(
                title: AppLocalizations.of(context)!.heelDetails,
                icon: Icons.stairs_outlined,
                iconColor: Colors.purple.shade600,
                child: Container(
                  padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (productDetails.heelType != null)
                        _keyValueRow(AppLocalizations.of(context)!.heelType, productDetails.heelType!),
                      if (productDetails.heelHeightCm != null)
                        _keyValueRow(AppLocalizations.of(context)!.heelHeight, '${productDetails.heelHeightCm!.toStringAsFixed(1)} ${AppLocalizations.of(context)!.cm}'),
                    ],
                  ),
                ),
              ),
            ],
            */

            // Bottom spacing before recommendations
            SizedBox(height: ResponsiveConstants.mdSpacing),

            // Recommended Items (render only when available)
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoaded) {
                  final products = state.featuredProducts;
                  debugPrint('recommended products in product details page ${products.length}');
                  if (products.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final cardWidth = ResponsiveConstants.productDetailsCardWidth;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveConstants.smPadding,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.recommendedForYou,
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.mdFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.mdSpacing),
                      SizedBox(
                        height:
                            ResponsiveConstants.productDetailsCompactListHeight,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveConstants.smPadding,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          separatorBuilder: (_, __) => SizedBox(
                            width:
                                ResponsiveConstants.productDetailsGridSpacing,
                          ),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return SizedBox(
                              width: cardWidth,
                              child: ProductCard(
                                product: product,
                                isCompact: true,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                if (state is HomeInitial || state is HomeLoading) {
                  return const SizedBox.shrink();
                }

                if (state is HomeError) {
                  return const SizedBox.shrink();
                }

                return const SizedBox.shrink();
              },
            ),

            // Optional products (horizontal list)
            if (productDetails.optionalProducts.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.smPadding,
                ),
                child: Text(
                  AppLocalizations.of(context)!.optionalItems,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.lgFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),
              SizedBox(
                height: ResponsiveConstants.productDetailsCompactListHeight,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveConstants.smPadding,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: productDetails.optionalProducts.length,
                  separatorBuilder: (_, __) => SizedBox(
                    width: ResponsiveConstants.productDetailsGridSpacing,
                  ),
                  itemBuilder: (context, index) {
                    final rp = productDetails.optionalProducts[index];
                    final mapped = _mapRelatedToHomeProduct(
                      RelatedProduct(
                        id: rp.id,
                        name: rp.name,
                        price: rp.price,
                        imageUrl: rp.imageUrl,
                        type: 'template',
                      ),
                    );
                    final cardWidth =
                        ResponsiveConstants.productDetailsCardWidth;
                    return SizedBox(
                      width: cardWidth,
                      child: ProductCard(
                        product: mapped,
                        productType: rp.type,
                        isCompact: true,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),
            ],

            // Accessories (horizontal list)
            if (productDetails.accessoryProducts.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.smPadding,
                ),
                child: Text(
                  AppLocalizations.of(context)!.accessories,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.lgFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),
              SizedBox(
                height: ResponsiveConstants.productDetailsCompactListHeight,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveConstants.smPadding,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: productDetails.accessoryProducts.length,
                  separatorBuilder: (_, __) => SizedBox(
                    width: ResponsiveConstants.productDetailsGridSpacing,
                  ),
                  itemBuilder: (context, index) {
                    final rp = productDetails.accessoryProducts[index];
                    final mapped = _mapRelatedToHomeProduct(
                      RelatedProduct(
                        id: rp.id,
                        name: rp.name,
                        price: rp.price,
                        imageUrl: rp.imageUrl,
                        type: 'variant',
                      ),
                    );
                    final cardWidth =
                        ResponsiveConstants.productDetailsCardWidth;
                    return SizedBox(
                      width: cardWidth,
                      child: ProductCard(
                        product: mapped,
                        productType: rp.type,
                        isCompact: true,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),
            ],

            // Alternatives (horizontal list)
            if (productDetails.alternativeProducts.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.smPadding,
                ),
                child: Text(
                  AppLocalizations.of(context)!.alternativeItems,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.lgFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),
              SizedBox(
                height: ResponsiveConstants.productDetailsCompactListHeight,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveConstants.smPadding,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: productDetails.alternativeProducts.length,
                  separatorBuilder: (_, __) => SizedBox(
                    width: ResponsiveConstants.productDetailsGridSpacing,
                  ),
                  itemBuilder: (context, index) {
                    final rp = productDetails.alternativeProducts[index];
                    final mapped = _mapRelatedToHomeProduct(
                      RelatedProduct(
                        id: rp.id,
                        name: rp.name,
                        price: rp.price,
                        imageUrl: rp.imageUrl,
                        type: 'template',
                      ),
                    );
                    final cardWidth =
                        ResponsiveConstants.productDetailsCardWidth;
                    return SizedBox(
                      width: cardWidth,
                      child: ProductCard(
                        product: mapped,
                        productType: rp.type,
                        isCompact: true,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),
            ],

            // Extra bottom spacing
            SizedBox(height: ResponsiveConstants.lgSpacing),
          ],
        ),
      ),
    );
  }

  // _sizeHint helper removed along with size recommendation UI
}

// Removed card wrapper (requested) – kept simple typography + spacing paddings above

Widget _buildFullWidthAttributeButtons({
  required BuildContext context,
  required List<dynamic> values,
  required Color primary,
  required ProductDetails productDetails,
  required String attributeName,
}) {
  if (values.isEmpty) return const SizedBox.shrink();

  final attrNameLower = attributeName.toLowerCase();
  final colorScheme = Theme.of(context).colorScheme;
  // If an attribute has ONLY one option, or only ONE available option,
  // make it unclickable (no meaningful alternative to choose).
  final bool isSingleOptionAttribute = values.length == 1;
  final int availableCount = values
      .where((v) => (v as VariantAttributeValue).isAvailable)
      .length;
  final bool onlyOneAvailableAttribute = availableCount == 1;
  // Still used to decide if there is a *meaningful* alternative to tap,
  // but we no longer use it to grey out the *selected* value visually.
  final bool shouldBeUnclickable =
      isSingleOptionAttribute || onlyOneAvailableAttribute;

  // Auto-select visual state for single-option non-color attributes
  final bool shouldForceSelectedForSingleOption =
      isSingleOptionAttribute &&
      attrNameLower != 'color' &&
      attrNameLower != 'colour' &&
      attrNameLower != 'color name' &&
      attrNameLower != 'اللون';

  // CRITICAL: Get all enabled attribute values for the selected color
  // This filters variants by color + stock conditions and collects all attribute values
  final Map<String, Set<String>> enabledAttributesForColor = 
      productDetails.variantCombinations.isNotEmpty &&
      productDetails.selectedColor.isNotEmpty
      ? productDetails.getEnabledAttributeValuesForColor(productDetails.selectedColor)
      : <String, Set<String>>{};

  // Get the enabled values for this specific attribute
  // Try multiple attribute name variations to match (case-insensitive)
  Set<String> enabledValuesForThisAttribute = {};
  String norm(String s) => s.toLowerCase().trim();
  final normalizedAttrName = norm(attributeName);
  
  for (final entry in enabledAttributesForColor.entries) {
    final normalizedEntryName = norm(entry.key);
    // Match by exact name or if attribute name contains the entry key or vice versa
    // Also handle common variations like "MATERIAL NAME" vs "MATERIALS", "MATERIAL" vs "MATERIAL NAME"
    final bool nameMatches = normalizedEntryName == normalizedAttrName ||
        normalizedEntryName.contains(normalizedAttrName) ||
        normalizedAttrName.contains(normalizedEntryName);
    
    // Special handling for material attributes
    final bool isMaterialMatch = 
        (normalizedEntryName.contains('material') && normalizedAttrName.contains('material')) ||
        (normalizedEntryName == 'materials' && normalizedAttrName == 'material name') ||
        (normalizedEntryName == 'material name' && normalizedAttrName == 'materials');
    
    if (nameMatches || isMaterialMatch) {
      // Normalize all values for comparison
      enabledValuesForThisAttribute = entry.value.map((v) => norm(v)).toSet();
      debugPrint('✅ Matched attribute "${entry.key}" with UI attribute "$attributeName" → enabled values: ${enabledValuesForThisAttribute.toList()}');
      break;
    }
  }

  // Auto-select first enabled value if no value is currently selected
  // This happens when color changes and we need to select from available options
  String? valueToAutoSelect;
  if (enabledValuesForThisAttribute.isNotEmpty) {
    // Check if current selection is still enabled
    String? currentSelectedValue;
    for (final opt in productDetails.variantAttributeOptions) {
      if (norm(opt.attributeName) == normalizedAttrName && opt.selectedValue.isNotEmpty) {
        currentSelectedValue = opt.selectedValue;
        break;
      }
    }
    
    // If current selection is enabled, keep it; otherwise select first enabled value
    if (currentSelectedValue != null && 
        enabledValuesForThisAttribute.contains(norm(currentSelectedValue))) {
      valueToAutoSelect = currentSelectedValue;
    } else {
      // Find first value from the values list that is enabled
      for (final val in values) {
        final valObj = val as VariantAttributeValue;
        if (enabledValuesForThisAttribute.contains(norm(valObj.name))) {
          valueToAutoSelect = valObj.name;
          break;
        }
      }
    }
  }

  // Container takes full width, buttons wrap inside
  return SizedBox(
    width: double.infinity,
    child: Wrap(
      spacing: ResponsiveConstants.smSpacing,
      runSpacing: ResponsiveConstants.smSpacing,
      children: values.map((value) {
        final val = value as VariantAttributeValue;
        // Detect if this attribute represents SIZE (primary variant)
        final bool isSizeAttribute =
            attrNameLower == 'size' ||
            attrNameLower == productDetails.primaryVariantLabel.toLowerCase() ||
            attrNameLower.contains('size');

        // CRITICAL: Enable only values that are in the enabled set for this color.
        // The enabled set comes from filtering variants by color + stock conditions.
        bool effectiveIsAvailable = false;
        if (productDetails.selectedColor.isNotEmpty &&
            enabledValuesForThisAttribute.isNotEmpty) {
          // Check if this value is in the enabled set (normalized comparison)
          effectiveIsAvailable =
              enabledValuesForThisAttribute.contains(norm(val.name));
        } else if (productDetails.selectedColor.isEmpty) {
          // No color selected - fallback to original availability
          effectiveIsAvailable = val.isAvailable;
        }
        // If color is selected but there are no enabled values at all,
        // effectiveIsAvailable stays false → all buttons disabled.

        // Selection rule:
        // - CRITICAL: Prioritize valueToAutoSelect (from loop) for ALL attributes.
        //   This ensures values from the matched variant are always selected.
        // - For SIZE: fall back to current selectedSize if valueToAutoSelect is not set.
        // - For other attributes: fall back to BLoC's selection if valueToAutoSelect is not set.
        bool isSelected = false;
        
        // Priority 1: If valueToAutoSelect is set and this value matches it, select it
        if (valueToAutoSelect != null) {
          final normalizedAutoSelect = norm(valueToAutoSelect!);
          final normalizedValName = norm(val.name);
          if (normalizedValName == normalizedAutoSelect &&
              enabledValuesForThisAttribute.contains(normalizedAutoSelect)) {
            isSelected = true;
            debugPrint('✅ Auto-selecting "$normalizedValName" for attribute "$attributeName" (from loop)');
          }
        }
        
        // Priority 2: If not auto-selected, check current selection
        if (!isSelected) {
          if (isSizeAttribute) {
            // For SIZE: Use current selectedSize if still enabled
            if (productDetails.selectedSize.isNotEmpty &&
                enabledValuesForThisAttribute
                    .contains(norm(productDetails.selectedSize)) &&
                norm(val.name) == norm(productDetails.selectedSize)) {
              isSelected = true;
            }
          } else {
            // For non-SIZE: Use BLoC's selection if still enabled
            if ((val.isSelected || shouldForceSelectedForSingleOption) &&
                effectiveIsAvailable) {
              isSelected = true;
            }
          }
        }

        // If this value is not enabled for the current color, it must NOT
        // appear as selected even if BLoC still marks it selected.
        if (!effectiveIsAvailable) {
          isSelected = false;
        }

        // Interaction rule:
        // - Unclickable when already selected OR not enabled for current color.
        //   We still keep the "no meaningful alternative" UX, but that no longer
        //   affects the visual state of the *enabled* selected value.
        final bool isTapEnabled = !isSelected && effectiveIsAvailable;

        // Grey disabled look purely based on effective availability.
        // If a value is not part of the enabled set for this color, it is
        // fully disabled even if BLoC had it selected before.
        final bool showDisabledVisual = !effectiveIsAvailable;
        final bool isEnabledChoice =
            !showDisabledVisual && effectiveIsAvailable == true;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isTapEnabled
                ? () {
                    if (isSizeAttribute) {
                      debugPrint('🎯 Size button tapped: ${val.name} (id: ${val.id})');
                      context.read<ProductDetailsBloc>().add(
                        SelectSizeEvent(
                          productId: productDetails.id,
                          sizeId: val.id,
                        ),
                      );
                    } else {
                      // Store selected attribute value and filter variants
                      // The selected value is stored in variantAttributeOptions and used to
                      // filter variant_combinations that match all selected attributes.
                      debugPrint('🎯 Attribute button tapped: $attributeName="${val.name}" (id: ${val.id})');
                      context.read<ProductDetailsBloc>().add(
                        FilterVariantsByAttributeEvent(
                          productId: productDetails.id,
                          attributeName: attributeName,
                          attributeValue: val.name,
                        ),
                      );
                    }
                  }
                : null,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.mdPadding,
                vertical: ResponsiveConstants.smPadding,
              ),
              decoration: BoxDecoration(
                // Background:
                // - disabled/unavailable: grey (like PRINTED COVER)
                // - selected: solid primary
                // - other choices: neutral surface
                color: showDisabledVisual
                    ? colorScheme.surfaceContainerHighest
                    : (isSelected
                        ? primary
                        : colorScheme.surface.withValues(alpha: 0.5)),
                // Border:
                // - disabled/unavailable: grey outline
                // - selected: primary
                // - enabled (but not selected): primary border
                border: Border.all(
                  color: showDisabledVisual
                      ? colorScheme.outline.withValues(alpha: 0.4)
                      : (isSelected
                          ? primary
                          : (isEnabledChoice
                              ? primary
                              : colorScheme.outline.withValues(alpha: 0.4))),
                  width: showDisabledVisual ? 1 : (isSelected ? 2 : 1),
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveConstants.smRadius,
                ),
              ),
              child: Text(
                val.name,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w600,
                  // Text color:
                  // - disabled: grey
                  // - selected: onPrimary
                  // - enabled (not selected): primary text
                  // - unavailable: faint grey
                  color: showDisabledVisual
                      ? colorScheme.onSurface.withValues(alpha: 0.5)
                      : (isSelected
                          ? colorScheme.onPrimary
                          : (isEnabledChoice
                              ? primary
                              : colorScheme.onSurface.withValues(alpha: 0.5))),
                ),
              ),
            ),
        );
      }).toList(),
    ),
  );
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.productDetails});
  final ProductDetails productDetails;

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Use the matched variant from the loop for stock badge.
    // When a color is selected, get the first in-stock variant for that color
    // and use its stock info directly.
    bool inStock = productDetails.inStock;
    int? q = productDetails.selectedVariantQuantityAvailable;
    
    // If color is selected, use the matched variant from the loop
    if (productDetails.selectedColor.isNotEmpty &&
        productDetails.variantCombinations.isNotEmpty) {
      final matchedVariant =
          productDetails.getFirstInStockVariantForColor(productDetails.selectedColor);
      if (matchedVariant != null) {
        // Use stock info from the matched variant
        inStock = matchedVariant.inStock;
        final double? qty = matchedVariant.quantityAvailable;
        if (qty != null) {
          q = qty.toInt();
          // If quantity is 0, mark as out of stock
          if (q <= 0) {
            inStock = false;
          }
        } else {
          // If quantity is null but inStock is true, consider it available
          inStock = matchedVariant.inStock;
        }
      } else {
        // No matching variant found for this color → out of stock
        inStock = false;
        q = 0;
      }
    } else {
      // Fallback to BLoC-computed values when no color is selected
      if (q != null && q <= 0) {
        inStock = false;
      }
    }
    // Fallback: when bloc didn't set quantity, if the variant matching this product id has 0 stock, show Out of stock
    if (q == null && productDetails.variantCombinations.isNotEmpty && productDetails.id.isNotEmpty) {
      try {
        final variantForProduct = productDetails.variantCombinations.firstWhere(
          (c) => c.variantId == productDetails.id,
        );
        if ((variantForProduct.quantityAvailable != null && variantForProduct.quantityAvailable! <= 0) ||
            !variantForProduct.inStock) {
          inStock = false;
        }
      } catch (_) {}
    }
    bool low = false;
    if (q != null) {
      low = q > 0 && q <= 5;
    } else if (productDetails.variantCombinations.isNotEmpty) {
      // Fallback: resolve variant for low stock when bloc didn't set quantity
      String normalize(String s) => s.toLowerCase().trim();
      String? selectedSize;
      for (final opt in productDetails.variantAttributeOptions) {
        final attrNameLower = opt.attributeName.toLowerCase();
        if ((attrNameLower == 'size' || attrNameLower == productDetails.primaryVariantLabel.toLowerCase()) &&
            opt.selectedValue.isNotEmpty) {
          selectedSize = opt.selectedValue;
          break;
        }
      }
      selectedSize ??= productDetails.selectedSize.isNotEmpty ? productDetails.selectedSize : null;
      String? selectedColor;
      for (final opt in productDetails.variantAttributeOptions) {
        final attrNameLower = opt.attributeName.toLowerCase();
        if ((attrNameLower == 'color name' || attrNameLower == 'color' || attrNameLower == 'colour' || attrNameLower == 'اللون') &&
            opt.selectedValue.isNotEmpty) {
          selectedColor = opt.selectedValue;
          break;
        }
      }
      selectedColor ??= productDetails.selectedColor.isNotEmpty ? productDetails.selectedColor : null;
      String? getVariantColorValue(VariantCombination v) {
        for (final attrName in ['COLOR NAME', 'color name', 'Color Name', 'color', 'Color', 'COLOR', 'colour', 'Colour', 'اللون', 'لون']) {
          final value = v.getAttributeValue(attrName);
          if (value != null && value.isNotEmpty) return value;
        }
        return null;
      }
      if (selectedSize != null && selectedColor != null) {
        final flexibleMatch = productDetails.variantCombinations.where((combo) {
          final sizeMatch = combo.hasAttributeValue('SIZE', selectedSize!) ||
              combo.hasAttributeValue('size', selectedSize) ||
              combo.hasAttributeValue(productDetails.primaryVariantLabel, selectedSize);
          final variantColorName = getVariantColorValue(combo);
          if (variantColorName == null) return false;
          final nv = normalize(variantColorName);
          final ns = normalize(selectedColor!);
          final colorMatch = nv == ns || nv.contains(ns) || ns.contains(nv);
          return sizeMatch && colorMatch;
        }).toList();
        if (flexibleMatch.isNotEmpty) {
          flexibleMatch.sort((a, b) => (b.quantityAvailable ?? 0).compareTo(a.quantityAvailable ?? 0));
          final qa = flexibleMatch.first.quantityAvailable;
          low = qa != null && qa > 0 && qa <= 5;
        }
      }
    }

    final Color bg = inStock
        ? (low ? Colors.orange.shade600 : Colors.green.shade600)
        : Colors.red.shade600;
    final String label = inStock
        ? (low
              ? AppLocalizations.of(context)!.lowStock
              : AppLocalizations.of(context)!.inStock)
        : AppLocalizations.of(context)!.outOfStock;
    // No product count display; only show stock status label

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.xsPadding,
      ),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bg.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inStock ? Icons.check_circle : Icons.error_outline,
            color: bg,
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: AppFonts.getTextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

HomeProduct.Product _mapRelatedToHomeProduct(RelatedProduct rp) {
  return HomeProduct.Product(
    id: rp.id,
    name: rp.name,
    description: '',
    price: rp.price,
    originalPrice: null,
    images: rp.imageUrl.isNotEmpty ? [rp.imageUrl] : [],
    category: 'Recommended',
    brand: '',
    // Regardless of related type, ensure we open the variant API for better detail resolution
    type: 'variant',
    rating: 0,
    reviewCount: 0,
    isAvailable: true,
    sizes: const [],
    colors: const [],
    createdAt: DateTime.now(),
  );
}

class _ExpandableSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _ExpandableSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.smPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with expand/collapse button
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveConstants.mdRadius),
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveConstants.smRadius,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: ResponsiveConstants.mdIconSize,
                    ),
                  ),
                  SizedBox(width: ResponsiveConstants.smSpacing),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                      size: ResponsiveConstants.mdIconSize,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content with smooth animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(ResponsiveConstants.mdRadius),
                      ),
                    ),
                    child: widget.child,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
