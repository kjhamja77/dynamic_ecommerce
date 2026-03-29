import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zalando_clone_app/core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/core/widgets/app_loading_widget.dart';
import 'package:zalando_clone_app/core/widgets/section_header.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../../core/services/haptic_service.dart';
import '../../bloc/home_bloc.dart';
import '../../../domain/entities/product.dart';
import '../../../../catalog/domain/models/catalog_args.dart';
import '../../../../../../l10n/app_localizations.dart';
import 'package:zalando_clone_app/features/filters/domain/entities/filter_criteria.dart';
import 'package:zalando_clone_app/features/home/presentation/theme/home_decorations.dart';
import '../common/no_image_data_placeholder.dart';

class SpecialOffersSection extends StatelessWidget {
  final String? title;
  final List<SpecialOfferData>? offers;
  const SpecialOffersSection({super.key, this.title, this.offers});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          // Prioritize API offers over BLoC product offers
          // If API offers are provided, use them (they maintain the correct order)
          final data = (offers?.isNotEmpty == true)
              ? offers!  // Use API offers first (maintains order)
              : (() {
                  // Fallback to BLoC product offers if no API offers
                  final offerProducts = state.featuredProducts
                      .where((product) => product.hasDiscount)
                      .take(6) // Limit to 6 offer products
                      .toList();
                  return offerProducts.isNotEmpty 
                      ? _convertProductsToOffers(offerProducts, context)
                      : _getSpecialOffers(context);
                })();
          
          return Container(
            margin: EdgeInsets.only(
              top: ResponsiveConstants.smSpacing,
              bottom: ResponsiveConstants.smSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: AppLocalizations.of(context)!.specialOffers,
                  subtitle: AppLocalizations.of(context)!.limitedTimeDeals,
                ),
                
                SizedBox(height: ResponsiveConstants.smSpacing),
                
                // Special Offers Grid
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
                  child: Column(
                    children: data.map((offer) => _SpecialOfferCard(
                      offer: offer,
                      onTap: () async {
                        await HapticService.buttonClick();
                        _navigateToOfferProducts(context, offer, state.featuredProducts);
                      },
                    )).toList(),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Loading or error state - show static offers
        final data = offers ?? _getSpecialOffers(context);
        return Container(
          margin: EdgeInsets.only(
            top: ResponsiveConstants.smSpacing,
            bottom: ResponsiveConstants.smSpacing,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: title?.isNotEmpty == true ? title! : AppLocalizations.of(context)!.specialOffers, 
                subtitle: AppLocalizations.of(context)!.limitedTimeDeals
              ),
              
              SizedBox(height: ResponsiveConstants.smSpacing),
              
              // Special Offers Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
                child: Column(
                  children: data.map((offer) => _SpecialOfferCard(offer: offer)).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Convert products with discounts to offer data
  List<SpecialOfferData> _convertProductsToOffers(List<Product> products, BuildContext context) {
    return products.map((product) {
      return SpecialOfferData(
        id: product.id,
        title: product.brand,
        description: '${product.discountPercentage.toStringAsFixed(0)}% off ${product.name}',
        imageUrl: product.images.isNotEmpty ? product.images.first : '',
        discount: '${product.discountPercentage.toStringAsFixed(0)}%',
        timeLeft: AppLocalizations.of(context)!.limitedTime,
        backgroundColor: Colors.red.shade50,
        textColor: Colors.red.shade700,
        filters: null, // Product-based offers don't have specific filters
      );
    }).toList();
  }


  /// Navigate to products related to specific offer
  void _navigateToOfferProducts(BuildContext context, SpecialOfferData offer, List<Product> allProducts) {
    print('🎯 Special Offers Navigation - Offer: ${offer.title}');
    
    // Use filter data if available, otherwise fallback to title search
    if (offer.filters != null) {
      _navigateWithOfferFilters(context, offer);
    } else {
      // Fallback to title-based search
      Navigator.pushNamed(
        context,
        '/catalog',
        arguments: CatalogArgs(
          title: offer.title,
          query: offer.title,
        ),
      );
    }
  }

  /// Navigate to catalog with proper offer filter data
  void _navigateWithOfferFilters(BuildContext context, SpecialOfferData offer) {
    final filters = offer.filters!;
    
    print('🎯 Offer Navigation with Filters - Name: ${offer.title}');
    print('  - Category IDs: ${filters.categoryIds}');
    print('  - Brand IDs: ${filters.brandIds}');
    print('  - Product IDs: ${filters.productIds}');
    print('  - Keyword: ${filters.keyword}');
    
    // Strict offer payload rule:
    // - If offer_product_ids exists, send ONLY product_ids.
    // - Otherwise send only non-empty available fields from the offer.
    final hasExplicitProductIds = filters.productIds.isNotEmpty;
    final filterCriteria = hasExplicitProductIds
        ? FilterCriteria(
            productIds: filters.productIds,
            omitPaginationInRequest: true,
          )
        : FilterCriteria(
            categoryIds: filters.categoryIds,
            brandIds: filters.brandIds,
            searchQuery: filters.keyword?.isNotEmpty == true ? filters.keyword : null,
            omitPaginationInRequest: true,
          );
    
    print('✅ Created FilterCriteria for offer:');
    print('  - Category IDs: ${filterCriteria.categoryIds}');
    print('  - Brand IDs: ${filterCriteria.brandIds}');
    print('  - Product IDs: ${filterCriteria.productIds}');
    print('  - Search Query: ${filterCriteria.searchQuery}');
    
    // Navigate to catalog with combined filters
    Navigator.pushNamed(
      context,
      '/catalog',
      arguments: CatalogArgs(
        title: offer.title,
        initialFilters: filterCriteria,
      ),
    );
  }

  List<SpecialOfferData> _getSpecialOffers(BuildContext context) {
    return [
      SpecialOfferData(
        id: '1',
        title: AppLocalizations.of(context)!.flashSale,
        description: 'Up to 70% off on selected items',
        imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&h=200&fit=crop',
        discount: '70%',
        timeLeft: '2h 15m',
        backgroundColor: Colors.red.shade50,
        textColor: Colors.red.shade700,
        filters: null, // Static offers don't have specific filters
      ),
      SpecialOfferData(
        id: '2',
        title: AppLocalizations.of(context)!.newCustomer,
        description: 'Get 20% off your first order',
        imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400&h=200&fit=crop',
        discount: '20%',
        timeLeft: '24h',
        backgroundColor: Colors.blue.shade50,
        textColor: Colors.blue.shade700,
        filters: null, // Static offers don't have specific filters
      ),
      SpecialOfferData(
        id: '3',
        title: AppLocalizations.of(context)!.weekendSpecial,
        description: 'Free shipping on orders over €50',
        imageUrl: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=400&h=200&fit=crop',
        discount: AppLocalizations.of(context)!.free,
        timeLeft: '3d',
        backgroundColor: Colors.green.shade50,
        textColor: Colors.green.shade700,
        filters: null, // Static offers don't have specific filters
      ),
    ];
  }
}

class _SpecialOfferCard extends StatelessWidget {
  final SpecialOfferData offer;
  final VoidCallback? onTap;

  const _SpecialOfferCard({required this.offer, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = offer.imageUrl.trim().isNotEmpty;
    final titleColor = hasImage ? Colors.white : colorScheme.onSurface;
    final descColor = hasImage
        ? Colors.white.withValues(alpha: 0.9)
        : colorScheme.onSurfaceVariant;
    final timeChipColor = hasImage
        ? Colors.white.withValues(alpha: 0.2)
        : colorScheme.surfaceContainerHighest;
    final timeIconColor = hasImage
        ? Colors.white
        : colorScheme.onSurfaceVariant;
    final timeTextColor = hasImage
        ? Colors.white
        : colorScheme.onSurface;

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            boxShadow: homeCardBoxShadow(context, [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]),
          ),
          child: Stack(
            children: [
              // Background Image with overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: offer.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: offer.backgroundColor,
                            child: Center(
                              child: AppLoadingWidget.small(
                                message: 'Loading...',
                                showMessage: false,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const NoImageDataPlaceholder(),
                        )
                      : const NoImageDataPlaceholder(),
                ),
              ),
              
              // Gradient overlay for better text readability
              if (hasImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
              
              // Content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                  child: Row(
                    children: [
                      // Left side content
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Header
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer.title,
                                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: titleColor,
                                  ),
                                ),
                                SizedBox(height: ResponsiveConstants.xsSpacing),
                                Text(
                                  offer.description,
                                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                                    color: descColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            
                            // Time Left
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(ResponsiveConstants.xsSpacing),
                                  decoration: BoxDecoration(
                                    color: timeChipColor,
                                    borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                                  ),
                                  child: Icon(
                                    Icons.access_time,
                                    size: ResponsiveConstants.smIconSize,
                                    color: timeIconColor,
                                  ),
                                ),
                                SizedBox(width: ResponsiveConstants.xsSpacing),
                                Text(
                                  offer.timeLeft,
                                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                                    color: timeTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Right side - Discount badge
                      if (offer.discount.trim().isNotEmpty)
                        Container(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveConstants.mdSpacing,
                              vertical: ResponsiveConstants.smSpacing,
                            ),
                            decoration: BoxDecoration(
                              color: offer.textColor,
                              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                              boxShadow: homeCardBoxShadow(context, [
                                BoxShadow(
                                  color: offer.textColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]),
                            ),
                            child: Text(
                              offer.discount,
                              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpecialOfferData {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String discount;
  final String timeLeft;
  final Color backgroundColor;
  final Color textColor;
  final OfferFilterData? filters;

  const SpecialOfferData({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discount,
    required this.timeLeft,
    required this.backgroundColor,
    required this.textColor,
    this.filters,
  });
}

class OfferFilterData {
  final List<int> categoryIds;
  final List<int> brandIds;
  final List<int> productIds;
  final String? keyword;

  const OfferFilterData({
    this.categoryIds = const [],
    this.brandIds = const [],
    this.productIds = const [],
    this.keyword,
  });

  factory OfferFilterData.fromMap(Map<String, dynamic>? filters) {
    if (filters == null) return const OfferFilterData();

    // New API key is `offer_product_ids` (list). Keep backward compatibility
    // with legacy `offer_product_id` (single id or list).
    final dynamic productIdsRaw =
        filters['offer_product_ids'] ?? filters['offer_product_id'];

    return OfferFilterData(
      categoryIds: _parseIdList(filters['offer_category_id']),
      brandIds: _parseIdList(filters['offer_brand_id']),
      productIds: _parseIdList(productIdsRaw),
      keyword: _parseOfferKeyword(filters['offer_keyword']),
    );
  }
}

/// Odoo/API may send a single id as [int] or many as [List]; normalize to [List<int>].
List<int> _parseIdList(dynamic value) {
  if (value == null) return const [];
  if (value is int) return value > 0 ? [value] : const [];
  if (value is num) {
    final i = value.toInt();
    return i > 0 ? [i] : const [];
  }
  if (value is List) {
    final out = <int>[];
    for (final e in value) {
      if (e is int) {
        if (e > 0) out.add(e);
      } else {
        final p = int.tryParse(e.toString()) ?? 0;
        if (p > 0) out.add(p);
      }
    }
    return out;
  }
  final parsed = int.tryParse(value.toString());
  if (parsed != null && parsed > 0) return [parsed];
  return const [];
}

String? _parseOfferKeyword(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isNotEmpty ? value : null;
  return value.toString();
}
