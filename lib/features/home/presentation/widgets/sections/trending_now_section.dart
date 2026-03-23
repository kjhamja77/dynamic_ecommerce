import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zalando_clone_app/core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/core/widgets/app_loading_widget.dart';
import 'package:zalando_clone_app/core/widgets/section_header.dart';
import 'package:zalando_clone_app/features/catalog/domain/models/catalog_args.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import 'package:zalando_clone_app/features/home/presentation/theme/home_decorations.dart';

class TrendingNowSection extends StatelessWidget {
  const TrendingNowSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: ResponsiveConstants.smSpacing,
        bottom: ResponsiveConstants.smSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Trending Now', subtitle: "What's hot this week"),
          
          SizedBox(height: ResponsiveConstants.smSpacing),
          
          // Trending Items
          SizedBox(
            height: ResponsiveConstants.productImageHeight * 0.6,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
              itemCount: _getTrendingItems().length,
              itemBuilder: (context, index) {
                final item = _getTrendingItems()[index];
                return _TrendingItemCard(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<TrendingItemData> _getTrendingItems() {
    return [
      TrendingItemData(
        id: '1',
        title: 'Summer Dresses',
        subtitle: 'Light & breezy',
        imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=300&h=300&fit=crop',
        trendScore: '🔥 2.5k',
        color: Colors.pink.shade100,
      ),
      TrendingItemData(
        id: '2',
        title: 'Sneaker Culture',
        subtitle: 'Street style',
        imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=300&h=300&fit=crop',
        trendScore: '⚡ 1.8k',
        color: Colors.blue.shade100,
      ),
      TrendingItemData(
        id: '3',
        title: 'Minimalist Fashion',
        subtitle: 'Less is more',
        imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=300&h=300&fit=crop',
        trendScore: '✨ 3.2k',
        color: Colors.grey.shade100,
      ),
      TrendingItemData(
        id: '4',
        title: 'Athleisure',
        subtitle: 'Comfort meets style',
        imageUrl: 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=300&h=300&fit=crop',
        trendScore: '💪 2.1k',
        color: Colors.green.shade100,
      ),
      TrendingItemData(
        id: '5',
        title: 'Vintage Revival',
        subtitle: 'Retro vibes',
        imageUrl: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=300&h=300&fit=crop',
        trendScore: '🕰️ 1.6k',
        color: Colors.amber.shade100,
      ),
    ];
  }
}

class _TrendingItemCard extends StatelessWidget {
  final TrendingItemData item;

  const _TrendingItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveConstants.productImageHeight * 0.5,
      margin: EdgeInsets.only(right: ResponsiveConstants.mdSpacing),
      child: GestureDetector(
        onTap: () async {
          await HapticService.buttonClick();
          Navigator.pushNamed(
            context,
            '/catalog',
            arguments: CatalogArgs(title: item.title, category: item.title),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            boxShadow: homeCardBoxShadow(context, [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]),
          ),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Center(
                      child: AppLoadingWidget.small(
                        message: 'Loading...',
                        showMessage: false,
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Icon(
                        Icons.trending_up,
                        color: Colors.grey.shade400,
                        size: ResponsiveConstants.lgIconSize,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trend Score
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveConstants.smSpacing,
                          vertical: ResponsiveConstants.xsSpacing,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                        ),
                        child: Text(
                          item.trendScore,
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveConstants.smSpacing),
                      
                      // Title
                      Text(
                        item.title,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Subtitle
                      Text(
                        item.subtitle,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

class TrendingItemData {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String trendScore;
  final Color color;

  const TrendingItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.trendScore,
    required this.color,
  });
}
