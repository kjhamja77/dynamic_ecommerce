import 'package:flutter/material.dart';
import 'package:zalando_clone_app/features/home/domain/entities/banner.dart' as home_banner;
import 'package:zalando_clone_app/features/home/presentation/widgets/banner/banner_carousel_widget.dart';
import 'package:zalando_clone_app/features/home/presentation/widgets/sections/featured_brands_section.dart';
import 'package:zalando_clone_app/features/home/presentation/widgets/sections/trending_now_section.dart';
import 'package:zalando_clone_app/features/home/presentation/widgets/sections/featured_categories_section.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../core/constants/responsive_constants.dart';


class HomeContentWidget extends StatelessWidget {
const   HomeContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Bazar',
                  style: AppFonts.getTextStyle(fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover amazing fashion trends',
                  style: AppFonts.getTextStyle(fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Banner Carousel
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
            child: BannerCarouselWidget(
              banners: _getDemoBanners(),
              height: 200,
              showIndicators: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Featured Categories Section
          const FeaturedCategoriesSection(),
          
          // Featured Brands Section
          const FeaturedBrandsSection(),
          
          // Trending Now Section
          const TrendingNowSection(),
          
          // Special Offers Section - Removed static fallback to avoid conflict with dynamic content
          
          // Bottom Spacing
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Demo banner data - can be replaced with API calls later
  List<home_banner.Banner> _getDemoBanners() {
    return [
      home_banner.Banner(
        id: 'banner_1',
        title: 'Summer Collection 2025',
        description: 'Discover the latest summer trends with up to 50% off',
        imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=400&fit=crop',
        actionUrl: '/summer-collection',
        actionText: 'Shop Now',
        isActive: true,
        sortOrder: 1,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      home_banner.Banner(
        id: 'banner_2',
        title: 'New Arrivals',
        description: 'Fresh styles just landed. Be the first to explore',
        imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=800&h=400&fit=crop',
        actionUrl: '/new-arrivals',
        actionText: 'Explore',
        isActive: true,
        sortOrder: 2,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      home_banner.Banner(
        id: 'banner_3',
        title: 'Premium Brands',
        description: 'Luxury fashion from the world\'s top designers',
        imageUrl: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800&h=400&fit=crop',
        actionUrl: '/premium-brands',
        actionText: 'Discover',
        isActive: true,
        sortOrder: 3,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
    ];
  }
}
