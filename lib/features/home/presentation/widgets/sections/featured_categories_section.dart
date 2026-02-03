import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zalando_clone_app/core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/core/widgets/app_loading_widget.dart';
import 'package:zalando_clone_app/core/widgets/section_header.dart';
import 'package:zalando_clone_app/features/catalog/domain/models/catalog_args.dart';
import 'package:zalando_clone_app/features/home/presentation/pages/all_categories_page.dart';
import 'package:zalando_clone_app/core/navigation/navigation_service.dart';
import 'package:zalando_clone_app/l10n/app_localizations.dart';
import 'package:zalando_clone_app/core/constants/app_constants.dart';
import 'package:zalando_clone_app/core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class FeaturedCategoriesSection extends StatelessWidget {
  final String? title;
  final List<CategoryData>? categories;

  const FeaturedCategoriesSection({super.key, this.title, this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories != null && categories!.isEmpty) {
      return const SizedBox.shrink();
    }
    final data = categories ?? _getFeaturedCategories();
    final locTitle = AppLocalizations.of(context)!.featuredCategories;
    return Container(
      margin: EdgeInsets.only(
        top: ResponsiveConstants.smSpacing,
        bottom: ResponsiveConstants.smSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            // Always use localized title so it matches the
            // current app language (backend title is English-only).
            title: locTitle,
            actionText: AppLocalizations.of(context)!.viewAll,
            onAction: () {
              final categories = data;
              context.pushCatalog(
                AllCategoriesPage(
                  categories: categories,
                  title: locTitle,
                ),
              );
            },
          ),
          
          SizedBox(height: ResponsiveConstants.smSpacing),
          
          // Categories Grid
          SizedBox(
            height: ResponsiveConstants.productImageHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
              itemCount: data.length,
              separatorBuilder: (context, index) => SizedBox(width: ResponsiveConstants.mdSpacing),
              itemBuilder: (context, index) {
                final category = data[index];
                return _CategoryCard(category: category);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<CategoryData> _getFeaturedCategories() {
    return [
      CategoryData(
        id: '1',
        name: 'Shoes',
        imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=300&h=300&fit=crop',
        productCount: '2.5k+',
        color: Colors.blue.shade100,
      ),
      CategoryData(
        id: '2',
        name: 'Clothing',
        imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=300&h=300&fit=crop',
        productCount: '5.2k+',
        color: Colors.pink.shade100,
      ),
      CategoryData(
        id: '3',
        name: 'Accessories',
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=300&h=300&fit=crop',
        productCount: '1.8k+',
        color: Colors.green.shade100,
      ),
      CategoryData(
        id: '4',
        name: 'Sports',
        imageUrl: 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=300&h=300&fit=crop',
        productCount: '3.1k+',
        color: Colors.orange.shade100,
      ),
      CategoryData(
        id: '5',
        name: 'Luxury',
        imageUrl: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=300&h=300&fit=crop',
        productCount: '890+',
        color: Colors.purple.shade100,
      ),
    ];
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryData category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveConstants.productImageHeight * 0.8,
      child: GestureDetector(
        onTap: () async {
          await HapticService.buttonClick();
          print('═══════════════════════════════════════════════════════');
          print('📁 Featured Category: Opening catalog');
          print('  📛 Category Name: ${category.name}');
          print('  🆔 Category ID (being passed): ${category.id}');
          print('═══════════════════════════════════════════════════════');
          Navigator.pushNamed(
            context,
            '/catalog',
            arguments: CatalogArgs(
              title: category.name, 
              categoryId: category.id, // Category ID - NOT attribute value
            ),
          );
        },
        child: Column(
          children: [
            // Category Image
            Expanded(
              child: Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  final isDark = theme.brightness == Brightness.dark;

                  // Use theme-aware color in dark mode, otherwise use category color
                  final backgroundColor =
                      isDark ? colorScheme.surface : category.color;

                  return Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      // Match search cards radius (outer card ~20)
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      // Inner image radius same as search image cards (~16)
                      borderRadius: BorderRadius.circular(16),
                      child: category.imageUrl.isEmpty
                          ? Center(
                              child: Icon(
                                Icons.category_outlined,
                                color: Colors.grey.shade400,
                                size: ResponsiveConstants.lgIconSize,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: category.imageUrl.startsWith('http')
                                  ? category.imageUrl
                                  : AppConstants.baseUrl + category.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => Center(
                                child: AppLoadingWidget.small(
                                  message:
                                      AppLocalizations.of(context)!.loading,
                                  showMessage: false,
                                ),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Icon(
                                  Icons.category_outlined,
                                  color: Colors.grey.shade400,
                                  size: ResponsiveConstants.lgIconSize,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: ResponsiveConstants.smSpacing),

            // Category Info
            Text(
              category.name,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryData {
  final String id;
  final String name;
  final String imageUrl;
  final String productCount;
  final Color color;

  const CategoryData({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.productCount,
    required this.color,
  });
}
