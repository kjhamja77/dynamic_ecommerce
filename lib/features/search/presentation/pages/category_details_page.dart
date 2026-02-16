import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/search_subcategory.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/models/catalog_args.dart';
import '../../../catalog/presentation/pages/catalog_page.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../widgets/category_details_shimmer.dart';
import 'search_input_page.dart';

class CategoryDetailsPage extends StatefulWidget {
  final String categoryId;
  final String title;
  final String? iconName;

  const CategoryDetailsPage({
    super.key,
    required this.categoryId,
    required this.title,
    this.iconName,
  });

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Load subcategories for this category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Get SearchBloc from context if available, otherwise get from DI
      SearchBloc searchBloc;
      try {
        searchBloc = context.read<SearchBloc>();
      } catch (e) {
        // If not available in context, get from DI
        searchBloc = di.sl<SearchBloc>();
      }
      
      if (searchBloc.isClosed) return;
      
      final currentState = searchBloc.state;
      if (currentState is SearchLoaded) {
        final subcategories = currentState.subcategories[widget.categoryId];
        final isLoading = currentState.loadingSubcategories.contains(widget.categoryId);
        
        // Only load if not already loaded and not currently loading
        if (subcategories == null && !isLoading) {
          if (!mounted || searchBloc.isClosed) return;
          searchBloc.add(LoadSubcategories(widget.categoryId));
        }
      } else {
        // Load initial search data first if needed
        if (!mounted || searchBloc.isClosed) return;
        searchBloc.add(const LoadSearchData());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(),
      body: BlocBuilder<SearchBloc, SearchState>(
        bloc: _getSearchBloc(context),
        builder: (context, state) {
          if (state is SearchInitial || state is SearchLoading) {
            return const CategoryDetailsShimmer();
          }

          if (state is SearchError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: ResponsiveConstants.xlIconSize,
                      color: colorScheme.error,
                    ),
                    SizedBox(height: ResponsiveConstants.mdSpacing),
                    Text(
                      AppLocalizations.of(context)!.error,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.lgFontSize,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.smSpacing),
                    Text(
                      state.message,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.mdFontSize,
                        color: colorScheme.onSurface.withValues(
                          alpha: isDark ? 0.7 : 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveConstants.lgSpacing),
                    ElevatedButton(
                      onPressed: () async {
                        if (!mounted) return;
                        await HapticService.buttonClick();
                        try {
                          final bloc = _getSearchBloc(context);
                          if (!bloc.isClosed) {
                            // In error state, reload the full search data so tabs/categories
                            // and their subcategories can be recovered cleanly.
                            bloc.add(const LoadSearchData());
                          }
                        } catch (e) {
                          debugPrint('⚠️ CategoryDetailsPage: Error reloading search data: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveConstants.lgPadding,
                          vertical: ResponsiveConstants.mdPadding,
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.tryAgain),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SearchLoaded) {
            final isLoading = state.loadingSubcategories.contains(widget.categoryId);
            final subcategories = state.subcategories[widget.categoryId];
            
            if (isLoading) {
              return const CategoryDetailsShimmer();
            }
            
            if (subcategories == null || subcategories.isEmpty) {
              return _buildEmptyState();
            }
            
            return _buildCategoryList(subcategories);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.background,
      elevation: 0,
      iconTheme: IconThemeData(
        color: colorScheme.onBackground,
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: colorScheme.onBackground,
          size: ResponsiveConstants.mdIconSize,
        ),
        onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        widget.title,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.lgFontSize,
          fontWeight: FontWeight.w600,
          color: colorScheme.onBackground,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: colorScheme.onBackground,
            size: ResponsiveConstants.mdIconSize,
          ),
          onPressed: () async {
            await HapticService.buttonClick();
            // Navigate to search input page
            final searchBloc = _getSearchBloc(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: searchBloc,
                  child: const SearchInputPage(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: ResponsiveConstants.xlIconSize,
              color: colorScheme.onSurface.withValues(
                alpha: isDark ? 0.5 : 0.4,
              ),
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),
            Text(
              'No subcategories found',
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.xlFontSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Text(
              AppLocalizations.of(context)!.tryDifferentSearchTerms,
              textAlign: TextAlign.center,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                color: colorScheme.onSurface.withValues(
                  alpha: isDark ? 0.7 : 0.6,
                ),
              ),
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            ElevatedButton.icon(
              onPressed: () async {
                if (!mounted) return;
                await HapticService.buttonClick();
                try {
                  final bloc = _getSearchBloc(context);
                  if (!bloc.isClosed) {
                    // Reload subcategories for this category
                    bloc.add(LoadSubcategories(widget.categoryId));
                  }
                } catch (e) {
                  debugPrint('⚠️ CategoryDetailsPage: Error refreshing subcategories: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.lgPadding,
                  vertical: ResponsiveConstants.mdPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<SearchSubcategory> subcategories) {
    // Separate categories into main and "more" sections
    // For now, show all in one section, but you can customize this
    final mainCategories = subcategories;
    
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Main Categories Section
        if (mainCategories.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveConstants.mdPadding,
              ResponsiveConstants.mdPadding,
              ResponsiveConstants.mdPadding,
              ResponsiveConstants.smPadding,
            ),
            child: Text(
              AppLocalizations.of(context)!.categories,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          ...mainCategories.map((subcategory) => _buildCategoryItem(subcategory)),
        ],
        
        // Bottom spacing
        SizedBox(height: ResponsiveConstants.lgSpacing),
      ],
    );
  }

  Widget _buildCategoryItem(SearchSubcategory subcategory) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(
              alpha: isDark ? 0.2 : 0.15,
            ),
            width: 0.6,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await HapticService.buttonClick();
            _onCategoryTap(subcategory);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.mdPadding,
              vertical: ResponsiveConstants.mdPadding,
            ),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(
                      alpha: isDark ? 0.3 : 0.8,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getCategoryIcon(subcategory.title),
                    color: colorScheme.onSurface,
                    size: 18,
                  ),
                ),
                
                SizedBox(width: ResponsiveConstants.mdSpacing),
                
                // Category Name
                Expanded(
                  child: Text(
                    subcategory.title,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                
                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(
                    alpha: isDark ? 0.6 : 0.4,
                  ),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCategoryTap(SearchSubcategory subcategory) {
    if (subcategory.hasChildren && subcategory.children.isNotEmpty) {
      // Navigate to another category details page for nested subcategories
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CategoryDetailsPage(
            categoryId: subcategory.id,
            title: subcategory.title,
            iconName: subcategory.title,
          ),
        ),
      );
    } else {
      // Navigate to catalog page for products
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CatalogPage(
            args: CatalogArgs(
              title: subcategory.title,
              category: widget.title,
              categoryId: subcategory.id,
            ),
          ),
        ),
      );
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    
    // Map category names to icons (similar to the image)
    if (name.contains('discover') || name.contains('all')) {
      return Icons.grid_view_outlined;
    } else if (name.contains('boot')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('ankle')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('flat')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('trainer') || name.contains('sneaker')) {
      return Icons.sports_basketball_outlined;
    } else if (name.contains('heel')) {
      return Icons.straighten;
    } else if (name.contains('ballet')) {
      return Icons.directions_walk;
    } else if (name.contains('pump')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('mule')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('slipper')) {
      return Icons.hotel;
    } else if (name.contains('sandal')) {
      return Icons.beach_access;
    } else if (name.contains('clothing') || name.contains('apparel')) {
      return Icons.checkroom;
    } else if (name.contains('shoe')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('accessory')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('beauty')) {
      return Icons.face;
    } else if (name.contains('designer')) {
      return Icons.star;
    } else if (name.contains('sport')) {
      return Icons.sports;
    } else if (name.contains('street')) {
      return Icons.sports_baseball;
    } else if (name.contains('underwear') || name.contains('lingerie')) {
      return Icons.checkroom;
    } else if (name.contains('sale')) {
      return Icons.local_offer;
    } else {
      return Icons.category_outlined;
    }
  }

  /// Get SearchBloc from context if available, otherwise get from DI
  SearchBloc _getSearchBloc(BuildContext context) {
    try {
      return context.read<SearchBloc>();
    } catch (e) {
      // If not available in context, get from DI
      return di.sl<SearchBloc>();
    }
  }
}

