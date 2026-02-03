import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zalando_clone_app/features/home/presentation/widgets/sections/featured_brands_section.dart';
import 'package:zalando_clone_app/features/home/presentation/widgets/sections/trending_now_section.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/home_bloc.dart';
import 'common/product_card.dart';
import 'banner/banner_carousel_widget.dart';
import '../../domain/entities/banner.dart' as home_banner;
import 'package:zalando_clone_app/features/home/presentation/widgets/sections/featured_categories_section.dart';
import 'fashion/fashion_shimmer.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../catalog/domain/models/catalog_args.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class FashionProductsWidget extends StatelessWidget {
  const FashionProductsWidget({super.key});

  // Responsive helper method for card width
  double _getResponsiveCardWidth() {
    if (1.sw >= 900) return 0.45.sw; // Tablet and desktop - smaller cards
    if (1.sw >= 600) return 0.5.sw;  // Large phones
    return 0.6.sw;                   // Small phones
  }

  // Responsive helper method for list height offset
  double _getResponsiveListHeightOffset() {
    if (1.sw >= 900) return 160; // Tablet and desktop
    if (1.sw >= 600) return 155; // Large phones
    return 150; // Small phones
  }

  // Responsive helper method for banner height
  double _getResponsiveBannerHeight() {
    if (1.sw >= 900) return 200; // Tablet and desktop
    if (1.sw >= 600) return 190; // Large phones
    return 180; // Small phones
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Show loading for both initial and loading states
        if (state is HomeInitial || state is HomeLoading) {
          return const FashionShimmer();
        }

        if (state is HomeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveConstants.errorIconSize,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                Text(
                  AppLocalizations.of(context)!.somethingWentWrong,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xlFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.smSpacing),
                Text(
                  state.message,
                  style: AppFonts.getTextStyle(color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                ElevatedButton(
                  onPressed: () async {
          await HapticService.buttonClick();
          context.read<HomeBloc>().add(LoadFeaturedProducts());
        },
                  child: Text(AppLocalizations.of(context)!.tryAgain),
                ),
              ],
            ),
          );
        }

        if (state is HomeLoaded) {
          return _buildFeaturedProducts(state.featuredProducts);
        }

        // Fallback loading state
        return const Center(
          child: AppLoadingWidget.defaultLoading(
            showMessage: false,
          ),
        );
      },
    );
  }

  Widget _buildFeaturedProducts(List<dynamic> products) {
    // If products list is empty, show loading instead of "no products"
    // This prevents the flash of "no products" message
    if (products.isEmpty) {
      return const FashionShimmer();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Spacing and padding
        final double horizontalPadding = ResponsiveConstants.mdPadding;
        final double spacing = ResponsiveConstants.gridSpacing;
        // Dynamic card/list dimensions to avoid overflow
        final double cardWidth = _getResponsiveCardWidth();
        final double listHeight = cardWidth + _getResponsiveListHeightOffset();

        return CustomScrollView(
          slivers: [
            // Banner Carousel
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: ResponsiveConstants.smPadding,
                  bottom: ResponsiveConstants.mdPadding,
                ),
                child: BannerCarouselWidget(
                  banners: _getFashionBanners(context),
                  height: _getResponsiveBannerHeight(),
                  showIndicators: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: ResponsiveConstants.smPadding,
                  bottom: ResponsiveConstants.smPadding,
                ),
                child: SectionHeader(
                  title: AppLocalizations.of(context)!.featuredProducts,
                  actionText: AppLocalizations.of(context)!.viewAll,
                  onAction: () {
                    Navigator.pushNamed(
                      context,
                      '/catalog',
                      arguments: CatalogArgs(title: AppLocalizations.of(context)!.allFeaturedProducts, featured: true),
                    );
                  },
                ),
              ),
            ),
            // Featured Products - Horizontal list (max 6 items)
            SliverToBoxAdapter(
              child: SizedBox(
                height: listHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  itemCount: products.length > 6 ? 6 : products.length,
                  separatorBuilder: (_, __) => SizedBox(width: spacing),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: cardWidth,
                        height: listHeight,
                        child: ProductCard(product: products[index]),
                      );
                    },
                ),
              ),
            ),

            // Categories Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: ResponsiveConstants.mdPadding),
                child: const FeaturedCategoriesSection(),
              ),
            ),

            // Brands Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: ResponsiveConstants.mdPadding),
                child: const FeaturedBrandsSection(),
              ),
            ),

            // Trending Now
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: ResponsiveConstants.mdPadding),
                child: const TrendingNowSection(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: ResponsiveConstants.smSpacing)),
            
            // Stories Section removed (demo) – real API stories are rendered via DynamicComponentRenderer

            // Special Offers - Removed static fallback to avoid conflict with dynamic content
          ],
        );
      },
    );
  }


  /// Fashion-specific banner data for the fashion tab
  List<home_banner.Banner> _getFashionBanners(BuildContext context) {
    return [
      home_banner.Banner(
        id: 'fashion_banner_1',
        title: AppLocalizations.of(context)!.newSeasonCollection,
        description: AppLocalizations.of(context)!.discoverLatestFashionTrends,
        imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=400&fit=crop',
        actionUrl: '/new-season',
        actionText: AppLocalizations.of(context)!.shopNow,
        isActive: true,
        sortOrder: 1,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      home_banner.Banner(
        id: 'fashion_banner_2',
        title: AppLocalizations.of(context)!.trendingStyles,
        description: AppLocalizations.of(context)!.stayAheadWithPopularStyles,
        imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=800&h=400&fit=crop',
        actionUrl: '/trending',
        actionText: AppLocalizations.of(context)!.exploreTrends,
        isActive: true,
        sortOrder: 2,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      home_banner.Banner(
        id: 'fashion_banner_3',
        title: AppLocalizations.of(context)!.designerCollection,
        description: AppLocalizations.of(context)!.exclusivePiecesFromDesigners,
        imageUrl: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800&h=400&fit=crop',
        actionUrl: '/designer',
        actionText: AppLocalizations.of(context)!.viewCollection,
        isActive: true,
        sortOrder: 3,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      home_banner.Banner(
        id: 'fashion_banner_4',
        title: AppLocalizations.of(context)!.streetStyle,
        description: AppLocalizations.of(context)!.urbanFashionDefinesModernStyle,
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop',
        actionUrl: '/street-style',
        actionText: AppLocalizations.of(context)!.getTheLook,
        isActive: true,
        sortOrder: 4,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
    ];
  }



}
