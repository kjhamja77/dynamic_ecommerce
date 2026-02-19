import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/authenticated_cached_image.dart';
import '../../../product/domain/entities/product_category.dart';
import '../../../catalog/domain/models/catalog_args.dart';
import '../../domain/entities/search_category.dart';
import '../../domain/entities/search_subcategory.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../utils/category_localization_helper.dart';
import '../bloc/search_bloc.dart';
import '../pages/category_details_page.dart';
import '../../../../core/di/injection_container.dart' as di;

class ExpandableCategoryListWidget extends StatefulWidget {
  final List<dynamic> categories; // Can be List<ProductCategory>, List<SearchCategory>, or List<SearchSubcategory>
  final String? searchQuery;

  const ExpandableCategoryListWidget({
    super.key,
    required this.categories,
    this.searchQuery,
  });

  @override
  State<ExpandableCategoryListWidget> createState() => _ExpandableCategoryListWidgetState();
}

class _ExpandableCategoryListWidgetState extends State<ExpandableCategoryListWidget> {


  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: ResponsiveConstants.mdSpacing,
        mainAxisSpacing: ResponsiveConstants.mdSpacing,
        childAspectRatio: 0.75, // Taller cards for better image display
      ),
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        return _buildCategoryItem(category, level: 0);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.lgPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: ResponsiveConstants.xlIconSize,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),
            Text(
              AppLocalizations.of(context)!.noCategoriesAvailable,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Text(
              AppLocalizations.of(context)!.tryDifferentSearchTerms,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(dynamic category, {int level = 0}) {
    // Different styling based on level
    if (level == 0) {
      // Main categories - modern grid card design
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: _buildMainCategoryContent(category, level),
      );
    } else {
      // Subcategories - simpler list item style
      return _buildSubcategoryItem(category, level);
    }
  }

  Widget _buildMainCategoryContent(dynamic category, int level) {
    final categoryId = _getCategoryId(category);
    final hasChildren = _hasChildren(category);
    final childrenCount = _getChildren(category).length;
    final categoryColor = _getCategoryColor(categoryId);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await HapticService.buttonClick();
          _onCategoryTap(category, level: level);
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: categoryColor.withOpacity(0.1),
        highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          child: Padding(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Large centered image/icon - improved design
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildCategoryImage(category, categoryColor),
                ),
              ),
              
              SizedBox(height: ResponsiveConstants.mdSpacing),
              
              // Category title - centered (localized)
              Text(
                CategoryLocalizationHelper.localizeCategoryName(
                  context,
                  _getCategoryName(category),
                ),
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.2,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (hasChildren) ...[
                SizedBox(height: ResponsiveConstants.xsSpacing),
                Text(
                  '$childrenCount ${AppLocalizations.of(context)!.subcategoriesAvailable}',
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.xsFontSize,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else if (_hasProducts(category)) ...[
                SizedBox(height: ResponsiveConstants.xsSpacing),
                Text(
                  '${_getProductCount(category)} ${AppLocalizations.of(context)!.productsAvailable}',
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.xsFontSize,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoryItem(dynamic category, int level) {
    return Column(
      children: [
        // Subcategory list item
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await HapticService.buttonClick();
              _onCategoryTap(category, level: level);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.mdPadding + (level * ResponsiveConstants.mdPadding),
                vertical: ResponsiveConstants.smPadding,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  left: BorderSide(
                    color: _getLevelColor(level),
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Small category icon
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _getLevelColor(level).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getCategoryIcon(_getCategoryName(category)),
                      color: _getLevelColor(level),
                      size: 16,
                    ),
                  ),
                  
                  SizedBox(width: ResponsiveConstants.smSpacing),
                  
                  // Category info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CategoryLocalizationHelper.localizeCategoryName(
                            context,
                            _getCategoryName(category),
                          ),
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.smFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          _getCategoryDescription(category),
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.xsFontSize,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action indicators
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(int level) {
    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.teal.shade600,
      Colors.red.shade600,
    ];
    return colors[level % colors.length];
  }

  void _onCategoryTap(dynamic category, {int level = 0}) {
    final categoryId = _getCategoryId(category);
    final hasChildren = _hasChildren(category);
    final rawName = _getCategoryName(category);
    final localizedName = CategoryLocalizationHelper.localizeCategoryName(context, rawName);
    
    if (hasChildren) {
      // Always navigate to category details page instead of expanding inline
      // Get SearchBloc from context if available, otherwise create from DI
      SearchBloc searchBloc;
      try {
        searchBloc = context.read<SearchBloc>();
      } catch (e) {
        // If not available in context, get from DI
        searchBloc = di.sl<SearchBloc>();
      }
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: searchBloc,
            child: CategoryDetailsPage(
              categoryId: categoryId.toString(),
              title: localizedName,
            ),
          ),
        ),
      );
    } else {
      // Navigate directly to catalog for categories without children
      Navigator.pushNamed(
        context,
        '/catalog',
        arguments: CatalogArgs(
          title: localizedName,
          // Use the raw backend name for filters/query to keep semantics,
          // and show the localized label only in the UI.
          category: rawName,
          categoryId: categoryId.toString(),
        ),
      );
    }
  }


  String _getCategoryDescription(dynamic category) {
    final hasChildren = _hasChildren(category);
    final hasProducts = _hasProducts(category);
    
    if (hasChildren && hasProducts) {
      final childrenCount = _getChildren(category).length;
      final productCount = _getProductCount(category);
      return '$childrenCount ${AppLocalizations.of(context)!.subcategories}, $productCount ${AppLocalizations.of(context)!.products}';
    } else if (hasChildren) {
      final childrenCount = _getChildren(category).length;
      return '$childrenCount ${AppLocalizations.of(context)!.subcategoriesAvailable}';
    } else if (hasProducts) {
      return AppLocalizations.of(context)!.navigateToProducts;
    } else {
      return AppLocalizations.of(context)!.navigateToProducts; // Always show this for subcategories
    }
  }

  // Helper methods to extract common properties from different category types
  int _getCategoryId(dynamic category) {
    if (category is ProductCategory) {
      return category.id;
    } else if (category is SearchCategory) {
      try {
        return int.parse(category.id);
      } catch (e) {
        debugPrint('⚠️ ExpandableCategoryListWidget: Invalid category ID format: ${category.id}');
        return 0;
      }
    } else if (category is SearchSubcategory) {
      try {
        return int.parse(category.id);
      } catch (e) {
        debugPrint('⚠️ ExpandableCategoryListWidget: Invalid subcategory ID format: ${category.id}');
        return 0;
      }
    }
    return 0;
  }

  String _getCategoryName(dynamic category) {
    if (category is ProductCategory) {
      return category.name;
    } else if (category is SearchCategory) {
      return category.title;
    } else if (category is SearchSubcategory) {
      return category.title;
    }
    return '';
  }

  bool _hasChildren(dynamic category) {
    if (category is ProductCategory) {
      return category.hasChildren || category.children.isNotEmpty;
    } else if (category is SearchCategory) {
      return category.children.isNotEmpty;
    } else if (category is SearchSubcategory) {
      return category.hasChildren || category.children.isNotEmpty;
    }
    return false;
  }

  bool _hasProducts(dynamic category) {
    if (category is ProductCategory) {
      return category.productCount > 0;
    } else if (category is SearchCategory) {
      return category.productCount > 0;
    } else if (category is SearchSubcategory) {
      return category.productCount > 0;
    }
    return false;
  }

  int _getProductCount(dynamic category) {
    if (category is ProductCategory) {
      return category.productCount;
    } else if (category is SearchCategory) {
      return category.productCount;
    } else if (category is SearchSubcategory) {
      return category.productCount;
    }
    return 0;
  }

  List<dynamic> _getChildren(dynamic category) {
    if (category is ProductCategory) {
      return category.children;
    } else if (category is SearchCategory) {
      return category.children;
    } else if (category is SearchSubcategory) {
      return category.children;
    }
    return [];
  }

  Color _getCategoryColor(int categoryId) {
    // Modern e-commerce color palette - vibrant and appealing
    final colors = [
      const Color(0xFF10B981), // Emerald Green (like in image)
      const Color(0xFF3B82F6), // Bright Blue
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF97316), // Orange
      const Color(0xFF84CC16), // Lime
      const Color(0xFFA855F7), // Violet
    ];
    return colors[categoryId % colors.length];
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('desk') || name.contains('table')) {
      return Icons.table_bar;
    } else if (name.contains('chair') || name.contains('seat')) {
      return Icons.chair;
    } else if (name.contains('furniture') || name.contains('couch')) {
      return Icons.weekend;
    } else if (name.contains('box') || name.contains('drawer')) {
      return Icons.inventory_2;
    } else if (name.contains('cabinet') || name.contains('shelf')) {
      return Icons.kitchen;
    } else if (name.contains('lamp') || name.contains('light')) {
      return Icons.lightbulb;
    } else if (name.contains('multimedia') || name.contains('media')) {
      return Icons.play_circle;
    } else if (name.contains('service')) {
      return Icons.support_agent;
    } else {
      return Icons.category;
    }
  }

  /// Get category image URL from API response
  String? _getCategoryImageUrl(dynamic category) {
    String? imagePath;
    
    // Handle SearchCategory entity (most common case)
    if (category is SearchCategory) {
      imagePath = category.image;
      debugPrint('🔍 SearchCategory image: $imagePath');
    }
    // Handle ProductCategory entity
    else if (category is ProductCategory) {
      imagePath = category.image;
      debugPrint('🔍 ProductCategory image: $imagePath');
    }
    // Handle SearchSubcategory entity
    else if (category is SearchSubcategory) {
      imagePath = category.imageUrl;
      debugPrint('🔍 SearchSubcategory image: $imagePath');
    }
    // Handle Map<String, dynamic> from API
    else if (category is Map<String, dynamic>) {
      imagePath = category['image'] as String?;
      debugPrint('🔍 Map image: $imagePath');
    }
    // Handle other Map types
    else if (category is Map) {
      try {
        imagePath = category['image'] as String?;
        debugPrint('🔍 Generic Map image: $imagePath');
      } catch (e) {
        // Ignore errors when accessing image property
        return null;
      }
    }
    
    // Construct full URL if image path exists
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        debugPrint('✅ Full image URL: $imagePath');
        return imagePath;
      } else {
        final fullUrl = '${AppConstants.baseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}';
        debugPrint('✅ Constructed image URL: $fullUrl');
        return fullUrl;
      }
    }
    
    debugPrint('❌ No image found for category');
    return null;
  }

  /// Build category image widget using AuthenticatedCachedImage like other pages
  Widget _buildCategoryImage(dynamic category, Color fallbackColor) {
    final imageUrl = _getCategoryImageUrl(category);
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return AuthenticatedCachedImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        memCacheWidth: 200,
        memCacheHeight: 200,
        placeholder: Container(
          color: Colors.grey.shade100,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
            ),
          ),
        ),
        errorWidget: Container(
          color: Colors.grey.shade100,
          child: Center(
            child: Icon(
              Icons.category_outlined,
              color: Colors.grey.shade400,
              size: ResponsiveConstants.lgIconSize,
            ),
          ),
        ),
      );
    }
    
    // Show fallback icon if no image available
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.category_outlined,
          color: Colors.grey.shade400,
          size: ResponsiveConstants.lgIconSize,
        ),
      ),
    );
  }
}
