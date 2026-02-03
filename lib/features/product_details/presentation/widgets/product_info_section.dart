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

            // Variant Attributes Card (Size, Material, etc.) - All Dynamic
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: productDetails.variantAttributeOptions
                      .where((attrOption) {
                        final name = attrOption.attributeName.toLowerCase();
                        return name != 'color' &&
                            name != 'colour' &&
                            name != 'اللون' &&
                            name != 'color name';
                      })
                      .map((attrOption) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                attrOption ==
                                    productDetails.variantAttributeOptions
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
                                  fontSize: ResponsiveConstants.mdFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: ResponsiveConstants.smSpacing),
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

            // Product Tags Card
            if (productDetails.tags.isNotEmpty) ...[
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
                    Text(
                      AppLocalizations.of(context)!.tags,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.smSpacing),
                    Wrap(
                      spacing: ResponsiveConstants.smSpacing,
                      runSpacing: ResponsiveConstants.smSpacing,
                      alignment: WrapAlignment.start,
                      children: productDetails.tags.map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveConstants.mdPadding,
                            vertical: ResponsiveConstants.smPadding,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(
                              ResponsiveConstants.smRadius,
                            ),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag.name,
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.smFontSize,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.2,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
  // Auto-select visual state for single-option non-color attributes
  final bool shouldForceSelectedForSingleOption =
      values.length == 1 &&
      attrNameLower != 'color' &&
      attrNameLower != 'colour' &&
      attrNameLower != 'color name' &&
      attrNameLower != 'اللون';

  // Container takes full width, buttons wrap inside
  return SizedBox(
    width: double.infinity,
    child: Wrap(
      spacing: ResponsiveConstants.smSpacing,
      runSpacing: ResponsiveConstants.smSpacing,
      children: values.map((value) {
        // Detect if this attribute represents SIZE (primary variant)
        final bool isSizeAttribute =
            attrNameLower == 'size' ||
            attrNameLower == productDetails.primaryVariantLabel.toLowerCase() ||
            attrNameLower.contains('size');

        // Selection rule:
        // - For SIZE: rely ONLY on productDetails.selectedSize (BLoC source of truth)
        // - For other attributes: use value.isSelected from BLoC
        final bool isSelected = isSizeAttribute
            ? (productDetails.selectedSize.isNotEmpty &&
                value.name == productDetails.selectedSize)
            : (value.isSelected || shouldForceSelectedForSingleOption);

        return Opacity(
          // Sizes should always look enabled when stock exists in any variant.
          opacity: isSizeAttribute ? 1.0 : (value.isAvailable ? 1.0 : 0.5),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque, // Ensure taps are captured
            onTap: isSizeAttribute
                ? () {
                    // Size buttons are ALWAYS clickable, regardless of availability
                    debugPrint('🎯 Size button tapped: ${value.name} (id: ${value.id})');
                    final bloc = context.read<ProductDetailsBloc>();
                    bloc.add(
                      SelectSizeEvent(
                        productId: productDetails.id,
                        sizeId: value.id,
                      ),
                    );
                  }
                : (value.isAvailable
                    ? () {
                        // For material/height etc., keep using generic filter
                        context.read<ProductDetailsBloc>().add(
                          FilterVariantsByAttributeEvent(
                            productId: productDetails.id,
                            attributeName: attributeName,
                            attributeValue: value.name,
                          ),
                        );
                      }
                    : null),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.mdPadding,
                vertical: ResponsiveConstants.smPadding,
              ),
              decoration: BoxDecoration(
                color: isSelected 
                    ? primary 
                    : colorScheme.surface.withValues(alpha: 0.5),
                border: Border.all(
                  color: isSelected
                      ? primary
                      : (value.isAvailable
                            ? colorScheme.outline.withValues(alpha: 0.3)
                            : colorScheme.outline.withValues(alpha: 0.2)),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveConstants.smRadius,
                ),
              ),
              child: Text(
                value.name,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : (value.isAvailable
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withValues(alpha: 0.4)),
                ),
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
    // Use computed inStock flag from ProductDetails (kept in sync by bloc)
    // The BLoC already computes this correctly when color/size changes
    bool inStock = productDetails.inStock;
    bool low = false;
    
    // Only find variant for low stock indicator (quantity check)
    if (productDetails.variantCombinations.isNotEmpty) {
      // Try to find matching variant using flexible matching (same as BLoC)
      VariantCombination? match;
      String normalize(String s) => s.toLowerCase().trim();
      
      // Get selected size
      String? selectedSize;
      for (final opt in productDetails.variantAttributeOptions) {
        final attrNameLower = opt.attributeName.toLowerCase();
        if ((attrNameLower == 'size' || attrNameLower == productDetails.primaryVariantLabel.toLowerCase()) && 
            opt.selectedValue.isNotEmpty) {
          selectedSize = opt.selectedValue;
          break;
        }
      }
      if (selectedSize == null && productDetails.selectedSize.isNotEmpty) {
        selectedSize = productDetails.selectedSize;
      }
      
      // Get selected color
      String? selectedColor;
      for (final opt in productDetails.variantAttributeOptions) {
        final attrNameLower = opt.attributeName.toLowerCase();
        if ((attrNameLower == 'color name' || 
             attrNameLower == 'color' || 
             attrNameLower == 'colour' ||
             attrNameLower == 'اللون') && 
            opt.selectedValue.isNotEmpty) {
          selectedColor = opt.selectedValue;
          break;
        }
      }
      if (selectedColor == null && productDetails.selectedColor.isNotEmpty) {
        selectedColor = productDetails.selectedColor;
      }
      
      // Helper to get color value from variant
      String? getVariantColorValue(VariantCombination v) {
        final colorAttrNames = ['COLOR NAME', 'color name', 'Color Name', 'color', 'Color', 'COLOR', 'colour', 'Colour', 'اللون', 'لون'];
        for (final attrName in colorAttrNames) {
          final value = v.getAttributeValue(attrName);
          if (value != null && value.isNotEmpty) {
            return value;
          }
        }
        return null;
      }
      
      // Try flexible match (size + color only, like BLoC does)
      if (selectedSize != null && selectedColor != null) {
        final flexibleMatch = productDetails.variantCombinations.where((combo) {
          // Must match size
          bool sizeMatch = combo.hasAttributeValue('SIZE', selectedSize!) ||
                          combo.hasAttributeValue('size', selectedSize) ||
                          combo.hasAttributeValue(productDetails.primaryVariantLabel, selectedSize);
          
          // Must match color
          final variantColorName = getVariantColorValue(combo);
          bool colorMatch = false;
          if (variantColorName != null) {
            final normalizedVariant = normalize(variantColorName);
            final normalizedSelected = normalize(selectedColor!);
            colorMatch = normalizedVariant == normalizedSelected ||
                        normalizedVariant.contains(normalizedSelected) ||
                        normalizedSelected.contains(normalizedVariant);
          }
          
          return sizeMatch && colorMatch;
        }).toList();
        
        if (flexibleMatch.isNotEmpty) {
          // Sort by highest stock (same as BLoC)
          flexibleMatch.sort((a, b) {
            final qtyA = a.quantityAvailable ?? 0;
            final qtyB = b.quantityAvailable ?? 0;
            return qtyB.compareTo(qtyA);
          });
          match = flexibleMatch.first;
        }
      }
      
      // Use variant quantity for low stock indicator
      if (match != null) {
        final qa = match.quantityAvailable;
        low = qa != null && qa > 0 && qa <= 5;
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
