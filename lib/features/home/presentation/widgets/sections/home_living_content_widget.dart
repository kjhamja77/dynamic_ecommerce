import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zalando_clone_app/core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/features/home/domain/entities/banner.dart' as home_banner;
import 'package:zalando_clone_app/features/home/presentation/widgets/banner/banner_carousel_widget.dart';
// removed unused localization import
// Using minimal localization keys only; fallbacks to English where missing
import '../../../../../core/providers/currency_provider.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';


class HomeLivingContentWidget extends StatelessWidget {
  const HomeLivingContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Home & Living Banner Carousel
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding, vertical: ResponsiveConstants.mdPadding),
            child: BannerCarouselWidget(
              banners: _getHomeLivingBanners(),
              height: 200,
              showIndicators: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
            ),
          ),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Room Categories
          _buildRoomCategories(),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Trending Furniture
          _buildTrendingFurniture(),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Home Decor Essentials
          _buildHomeDecorEssentials(),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Kitchen & Dining
          _buildKitchenDining(),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Seasonal Collections
          _buildSeasonalCollections(),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
        ],
      ),
    );
  }

  Widget _buildRoomCategories() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop by Room',
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
              childAspectRatio: 1.1,
            ),
            itemCount: _getRoomCategories().length,
            itemBuilder: (context, index) {
              final room = _getRoomCategories()[index];
              return _buildRoomCard(room);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(RoomData room) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: room.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: double.infinity,
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
                height: double.infinity,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: ResponsiveConstants.smPadding,
              left: ResponsiveConstants.smPadding,
              right: ResponsiveConstants.smPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${room.productCount}+ items',
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingFurniture() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending Furniture',
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await HapticService.buttonClick();
                  // TODO: Navigate to trending furniture page
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
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
              itemCount: _getTrendingFurniture().length,
              itemBuilder: (context, index) {
                final furniture = _getTrendingFurniture()[index];
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
                              imageUrl: furniture.imageUrl,
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
                        furniture.name,
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
                            currencyProvider.formatPrice(furniture.price, locale: Localizations.localeOf(context)),
                            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.brown.shade600,
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

  Widget _buildHomeDecorEssentials() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              'Home Decor Essentials',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.titleFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              gradient: LinearGradient(
                colors: [Colors.amber.shade100, Colors.orange.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transform Your Space',
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Text(
                        'Curtains, rugs, cushions & more',
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Icon(
                    Icons.home,
                    size: ResponsiveConstants.xlIconSize,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenDining() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kitchen & Dining',
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
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.kitchen,
                          color: Colors.teal.shade700,
                          size: ResponsiveConstants.lgIconSize,
                        ),
                        Text(
                          'Kitchen',
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade700,
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
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant,
                          color: Colors.indigo.shade700,
                          size: ResponsiveConstants.lgIconSize,
                        ),
                        Text(
                          'Dining',
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo.shade700,
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

  Widget _buildSeasonalCollections() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seasonal Collections',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.titleFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_florist,
                  color: Colors.green.shade600,
                  size: ResponsiveConstants.lgIconSize,
                ),
                SizedBox(width: ResponsiveConstants.mdSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spring Refresh Sale',
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Text(
                        'Up to 50% off on spring collections',
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await HapticService.buttonClick();
                    // TODO: Navigate to spring refresh sale
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
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

  List<home_banner.Banner> _getHomeLivingBanners() {
    return [
      home_banner.Banner(
        id: 'home_banner_1',
        title: 'Modern Furniture Collection',
        description: 'Contemporary designs for your home',
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&h=400&fit=crop',
        actionUrl: '/modern-furniture',
        actionText: 'Shop Now',
        isActive: true,
        sortOrder: 1,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      home_banner.Banner(
        id: 'home_banner_2',
        title: 'Home Decor Essentials',
        description: 'Transform your living space',
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&h=400&fit=crop',
        actionUrl: '/home-decor',
        actionText: 'Explore',
        isActive: true,
        sortOrder: 2,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      home_banner.Banner(
        id: 'home_banner_3',
        title: 'Kitchen & Dining',
        description: 'Create your perfect dining experience',
        imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=400&fit=crop',
        actionUrl: '/kitchen-dining',
        actionText: 'Discover',
        isActive: true,
        sortOrder: 3,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
    ];
  }

  List<RoomData> _getRoomCategories() {
    return [
      RoomData(
        name: 'Living Room',
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=300&h=200&fit=crop',
        productCount: 234,
      ),
      RoomData(
        name: 'Bedroom',
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=300&h=200&fit=crop',
        productCount: 189,
      ),
      RoomData(
        name: 'Kitchen',
        imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=200&fit=crop',
        productCount: 156,
      ),
      RoomData(
        name: 'Bathroom',
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=300&h=200&fit=crop',
        productCount: 98,
      ),
    ];
  }

  List<FurnitureData> _getTrendingFurniture() {
    return [
      FurnitureData(
        name: 'Modern Sofa Set',
        price: 899,
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=300&h=200&fit=crop',
      ),
      FurnitureData(
        name: 'Dining Table',
        price: 599,
        imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=200&fit=crop',
      ),
      FurnitureData(
        name: 'Bed Frame',
        price: 449,
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=300&h=200&fit=crop',
      ),
      FurnitureData(
        name: 'Bookshelf',
        price: 299,
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=300&h=200&fit=crop',
      ),
    ];
  }
}

class RoomData {
  final String name;
  final String imageUrl;
  final int productCount;

  const RoomData({
    required this.name,
    required this.imageUrl,
    required this.productCount,
  });
}

class FurnitureData {
  final String name;
  final double price;
  final String imageUrl;

  const FurnitureData({
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}
