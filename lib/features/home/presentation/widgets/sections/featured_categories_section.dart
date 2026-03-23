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
import 'package:zalando_clone_app/core/di/injection_container.dart';
import 'package:zalando_clone_app/features/search/domain/services/category_service.dart';
import 'package:zalando_clone_app/core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../common/no_image_data_placeholder.dart';

class FeaturedCategoriesSection extends StatefulWidget {
  final String? title;
  final List<CategoryData>? categories;

  const FeaturedCategoriesSection({super.key, this.title, this.categories});

  @override
  State<FeaturedCategoriesSection> createState() => _FeaturedCategoriesSectionState();
}

class _FeaturedCategoriesSectionState extends State<FeaturedCategoriesSection> {
  List<CategoryData>? _fetchedCategories;
  bool _isLoading = false;
  bool _hasTriedFetch = false;

  @override
  void initState() {
    super.initState();
    // If categories are not provided, fetch from API once on init.
    if (widget.categories == null) {
      _fetchRootCategories();
    }
  }

  Future<void> _fetchRootCategories() async {
    if (_hasTriedFetch) return;
    _hasTriedFetch = true;
    setState(() => _isLoading = true);
    try {
      final service = sl<CategoryService>();
      final result = await service.getRootCategories(maxDepth: 1);
      result.fold(
        (_) {
          // Leave _fetchedCategories as null to fall back to local demo
        },
        (productCategories) {
          final mapped = productCategories.map((c) {
            // Build absolute image URL if backend returns relative path
            String imageUrl = '';
            if (c.image != null && c.image!.isNotEmpty) {
              imageUrl = c.image!.startsWith('http')
                  ? c.image!
                  : '${AppConstants.baseUrl}${c.image!.startsWith('/') ? c.image! : '/${c.image!}'}';
            }
            return CategoryData(
              id: c.id.toString(),
              name: c.name,
              imageUrl: imageUrl,
              // Product count is not prominently shown in this UI; keep simple
              productCount: (c.productCount > 0) ? '${c.productCount}' : '',
              // Provide a soft background; reuse a consistent palette
              color: Colors.grey.shade200,
            );
          }).toList();
          _fetchedCategories = mapped;
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provided = widget.categories;
    if (provided != null && provided.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<CategoryData> data = provided ??
        (_fetchedCategories != null && _fetchedCategories!.isNotEmpty
            ? _fetchedCategories!
            : (_isLoading ? const [] : _getFeaturedCategories()));
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
              final categories = data.isNotEmpty
                  ? data
                  : _getFeaturedCategories();
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
            child: _isLoading && (provided == null) && (data.isEmpty)
                ? Center(
                    child: AppLoadingWidget.small(
                      message: AppLocalizations.of(context)!.loading,
                      showMessage: false,
                    ),
                  )
                : ListView.separated(
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
                          ? const NoImageDataPlaceholder(compact: true)
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
                              errorWidget: (context, url, error) =>
                                  const NoImageDataPlaceholder(compact: true),
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
            // We intentionally hide the product count label (e.g. "0 products")
            // from featured categories to keep the UI clean.
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
