// Using minimal localization keys only; fallbacks to English where missing
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// removed unused GoogleFonts import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zalando_clone_app/core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/features/home/domain/entities/banner.dart' as home_banner;
import 'package:zalando_clone_app/features/home/presentation/widgets/banner/banner_carousel_widget.dart';
import '../../../../../core/providers/currency_provider.dart';
import '../../../../../core/theme/app_fonts.dart';
import 'package:zalando_clone_app/features/home/presentation/theme/home_decorations.dart';
import '../../../../../core/services/haptic_service.dart';
class ElectronicsContentWidget extends StatelessWidget {
  const ElectronicsContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Electronics Banner Carousel
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding,vertical: ResponsiveConstants.mdPadding),
            child: BannerCarouselWidget(
              banners: _getElectronicsBanners(),
              height: 200,
              showIndicators: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
            ),
          ),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Featured Electronics Categories
          _buildFeaturedCategories(),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Latest Tech Releases
          _buildLatestReleases(),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Smart Home Section
          _buildSmartHomeSection(),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Gaming & Entertainment
          _buildGamingSection(),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Tech Deals
          _buildTechDeals(),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
        ],
      ),
    );
  }

  Widget _buildFeaturedCategories() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop by Category',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.titleFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: ResponsiveConstants.mdSpacing,
              mainAxisSpacing: ResponsiveConstants.mdSpacing,
              childAspectRatio: 1.2,
            ),
            itemCount: _getElectronicsCategories().length,
            itemBuilder: (context, index) {
              final category = _getElectronicsCategories()[index];
              return _buildCategoryCard(context, category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryData category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        boxShadow: homeCardBoxShadow(context, [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ]),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            category.icon,
            size: ResponsiveConstants.lgIconSize * 2,
            color: category.color,
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          Text(
            category.name,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.xsSpacing),
          Text(
            '${category.productCount}+ items',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestReleases() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Tech Releases',
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await HapticService.buttonClick();
                  // TODO: Navigate to latest tech releases page
                },
                child: Text(
                  'View All',
                  style: AppFonts.getTextStyle(color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
              itemCount: _getLatestReleases().length,
              itemBuilder: (context, index) {
                final release = _getLatestReleases()[index];
                return Container(
                  width: 160,
                  margin: EdgeInsets.only(right: ResponsiveConstants.mdSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                            color: Colors.grey.shade100,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                            child: CachedNetworkImage(
                              imageUrl: release.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Container(
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Text(
                        release.name,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Consumer<CurrencyProvider>(
                        builder: (context, currencyProvider, child) {
                          return Text(
                            currencyProvider.formatPrice(release.price, locale: Localizations.localeOf(context)),
                            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartHomeSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart Home Solutions',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.titleFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              gradient: LinearGradient(
                colors: [Colors.purple.shade100, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Control Your Home',
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple.shade800,
                          ),
                        ),
                        SizedBox(height: ResponsiveConstants.xsSpacing),
                        Text(
                          'Smart devices for modern living',
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Icon(
                    Icons.home,
                    size: ResponsiveConstants.xlIconSize,
                    color: Colors.purple.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamingSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gaming & Entertainment',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.titleFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.games,
                          color: Colors.orange.shade700,
                          size: ResponsiveConstants.lgIconSize,
                        ),
                        Text(
                          'Gaming',
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveConstants.mdSpacing),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          color: Colors.green.shade700,
                          size: ResponsiveConstants.lgIconSize,
                        ),
                        Text(
                          'Audio',
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechDeals() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tech Deals',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.titleFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: Colors.red.shade600,
                  size: ResponsiveConstants.lgIconSize,
                ),
                SizedBox(width: ResponsiveConstants.mdSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flash Sale - 24h Left!',
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                      Text(
                        'Up to 40% off on selected electronics',
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await HapticService.buttonClick();
                    // TODO: Navigate to flash sale
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Shop Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<home_banner.Banner> _getElectronicsBanners() {
    return [
      home_banner.Banner(
        id: 'electronics_banner_1',
        title: 'Latest Smartphones',
        description: 'Discover the newest mobile technology',
        imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800&h=400&fit=crop',
        actionUrl: '/smartphones',
        actionText: 'Shop Now',
        isActive: true,
        sortOrder: 1,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      home_banner.Banner(
        id: 'electronics_banner_2',
        title: 'Smart Home Devices',
        description: 'Automate your living space',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=400&fit=crop',
        actionUrl: '/smart-home',
        actionText: 'Explore',
        isActive: true,
        sortOrder: 2,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      home_banner.Banner(
        id: 'electronics_banner_3',
        title: 'Gaming & VR',
        description: 'Next-level gaming experience',
        imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&h=400&fit=crop',
        actionUrl: '/gaming',
        actionText: 'Discover',
        isActive: true,
        sortOrder: 3,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
    ];
  }

  List<CategoryData> _getElectronicsCategories() {
    return [
      CategoryData(
        name: 'Smartphones',
        icon: Icons.phone_android,
        color: Colors.blue,
        productCount: 150,
      ),
      CategoryData(
        name: 'Laptops',
        icon: Icons.laptop,
        color: Colors.green,
        productCount: 89,
      ),
      CategoryData(
        name: 'Smart Home',
        icon: Icons.home,
        color: Colors.purple,
        productCount: 67,
      ),
      CategoryData(
        name: 'Gaming',
        icon: Icons.games,
        color: Colors.orange,
        productCount: 112,
      ),
    ];
  }

  List<ReleaseData> _getLatestReleases() {
    return [
      ReleaseData(
        name: 'iPhone 15 Pro',
        price: 1199,
        imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=200&fit=crop',
      ),
      ReleaseData(
        name: 'MacBook Air M2',
        price: 1299,
        imageUrl: 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=300&h=200&fit=crop',
      ),
      ReleaseData(
        name: 'Samsung Galaxy S24',
        price: 999,
        imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=200&fit=crop',
      ),
      ReleaseData(
        name: 'Sony WH-1000XM5',
        price: 399,
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300&h=200&fit=crop',
      ),
    ];
  }
}

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final int productCount;

  const CategoryData({
    required this.name,
    required this.icon,
    required this.color,
    required this.productCount,
  });
}

class ReleaseData {
  final String name;
  final double price;
  final String imageUrl;

  const ReleaseData({
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}
