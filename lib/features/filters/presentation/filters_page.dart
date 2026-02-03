import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import '../../../core/constants/responsive_constants.dart';
import '../domain/entities/filter_criteria.dart';
import '../domain/entities/filter_options.dart';
import '../domain/entities/filter_attribute.dart';
import '../domain/entities/filter_brand.dart';
import '../domain/entities/filter_category.dart';
import '../domain/repositories/filter_repository.dart';
import 'bloc/filter_bloc.dart';
import 'filters_cubit.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/services/haptic_service.dart';
import 'dart:async';
import '../../../../core/di/injection_container.dart' as di;
import '../data/datasources/filter_remote_data_source.dart';
import 'package:shimmer/shimmer.dart';

class FiltersPage extends StatefulWidget {
  final FilterCriteria initial;
  final FilterOptions options;
  final void Function(FilterCriteria) onApply;
  final FilterRepository? repository;

  const FiltersPage({
    super.key, 
    required this.initial, 
    required this.options, 
    required this.onApply,
    this.repository,
  });

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  // removed: material grouping now split into name/code
  // bool _showAllMaterials = false;
  final Map<String, bool> _attributeShowAll = {};
  final Map<int, bool> _expandedCategories = {}; // Track expanded state for tree view

  int? _resultCount;
  Timer? _debounce;
  bool _isCounting = false;

  /// Build a parent-child map from categories and subcategories
  /// Returns a map where key is parent category ID and value is list of child IDs
  Map<int, List<int>> _buildParentChildMap(
    List<FilterCategory> categories,
    Map<int, List<FilterCategory>> subcategories,
  ) {
    final parentChildMap = <int, List<int>>{};
    
    // Add children from main categories
    for (final category in categories) {
      if (category.children.isNotEmpty) {
        parentChildMap[category.id] = category.children.map((c) => c.id).toList();
      }
    }
    
    // Add children from loaded subcategories
    for (final entry in subcategories.entries) {
      final parentId = entry.key;
      final children = entry.value;
      if (children.isNotEmpty) {
        final childIds = children.map((c) => c.id).toList();
        if (parentChildMap.containsKey(parentId)) {
          // Merge with existing children
          parentChildMap[parentId] = [...parentChildMap[parentId]!, ...childIds];
        } else {
          parentChildMap[parentId] = childIds;
        }
      }
    }
    
    // Also check nested children (subcategories that have their own children)
    for (final category in categories) {
      for (final child in category.children) {
        if (child.children.isNotEmpty) {
          parentChildMap[child.id] = child.children.map((c) => c.id).toList();
        }
      }
    }
    
    for (final subs in subcategories.values) {
      for (final sub in subs) {
        if (sub.children.isNotEmpty) {
          parentChildMap[sub.id] = sub.children.map((c) => c.id).toList();
        }
      }
    }
    
    return parentChildMap;
  }

  /// Extract only the deepest (most specific) category IDs from the selected list.
  /// This removes parent category IDs when their children (at any level) are also selected.
  List<int> _getDeepestCategoryIds(
    List<int> selectedCategoryIds,
    Map<int, List<int>> parentChildMap,
  ) {
    if (selectedCategoryIds.isEmpty) return [];
    if (parentChildMap.isEmpty) {
      // If no hierarchy info, return all IDs (fallback behavior)
      return selectedCategoryIds;
    }
    
    // Build a set of all selected IDs for quick lookup
    final selectedSet = selectedCategoryIds.toSet();
    
    // Helper function to check if a category has ANY selected descendant (recursive)
    bool hasSelectedDescendant(int categoryId, Map<int, List<int>> map, Set<int> selected) {
      final children = map[categoryId] ?? [];
      // Check direct children
      if (children.any((childId) => selected.contains(childId))) {
        return true;
      }
      // Recursively check descendants
      for (final childId in children) {
        if (hasSelectedDescendant(childId, map, selected)) {
          return true;
        }
      }
      return false;
    }
    
    // Filter: keep only IDs that don't have any selected descendants
    final deepestIds = <int>[];
    for (final categoryId in selectedCategoryIds) {
      if (!hasSelectedDescendant(categoryId, parentChildMap, selectedSet)) {
        // This category doesn't have any selected descendants, so it's a deepest level
        deepestIds.add(categoryId);
      }
    }
    
    print('🎯 _getDeepestCategoryIds: Found subcategories=$deepestIds, parents=${selectedCategoryIds.where((id) => !deepestIds.contains(id)).toList()} → returning subcategories only');
    
    return deepestIds;
  }

  void _scheduleCountFetch(FilterCriteria criteria) {
    print('🚀 _scheduleCountFetch CALLED with criteria.categoryIds: ${criteria.categoryIds}');
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      print('⏰ _scheduleCountFetch TIMER FIRED');
      try {
        if (mounted) setState(() => _isCounting = true);
        final ds = di.sl<FilterRemoteDataSource>();
        // Build server-ready criteria by mapping selected names → IDs
        // Extract only deepest category IDs for attributes endpoint
        final parentChildMap = _buildParentChildMap(
          widget.options.categories,
          context.read<FiltersCubit>().state.subcategories,
        );
        final deepestCategoryIds = _getDeepestCategoryIds(
          criteria.categoryIds,
          parentChildMap,
        );
        final categoryIds = deepestCategoryIds.isNotEmpty ? deepestCategoryIds : null;
        print('🎯 _scheduleCountFetch: Using deepest category IDs for attributes: $categoryIds');
        final attrs = await ds.getAttributes(page: 1, limit: 200, categoryIds: categoryIds);
        final Map<String, int> valueNameToId = {};
        for (final a in attrs) {
          for (final v in a.values) {
            final key = v.name.trim().toLowerCase();
            if (key.isNotEmpty) valueNameToId[key] = v.id;
          }
        }

        // Collect all selected textual values and map to IDs
        final Set<int> attributeIds = {};
        final allSelectedLists = [
          ...criteria.colors,
          ...criteria.materials,
          ...criteria.sizes,
          ...criteria.seasons,
          ...criteria.genders,
        ];
        for (final entry in criteria.extraAttributes.values) {
          allSelectedLists.addAll(entry);
        }
        for (final val in allSelectedLists) {
          final id = valueNameToId[val.trim().toLowerCase()];
          if (id != null) attributeIds.add(id);
        }
        
        // Category IDs should only be sent in category_ids field, not attribute_values
        // They are already in criteria.categoryIds and will be sent correctly via FilterCriteria.toJson()

        // Map brand via brands endpoint
        List<int> brandIds = criteria.brandIds;
        if ((criteria.brand ?? '').isNotEmpty) {
          try {
            int page = 1;
            int safety = 0;
            int? foundId;
            while (safety < 10) {
              final list = await ds.getBrands(page: page, limit: 200);
              if (list.isEmpty) break;
              for (final b in list) {
                if (b.name.trim().toLowerCase() == criteria.brand!.trim().toLowerCase()) {
                  foundId = b.id;
                  break;
                }
              }
              if (foundId != null || list.length < 200) break;
              page += 1;
              safety += 1;
            }
            if (foundId != null) {
              brandIds = [foundId];
            } else {
              // fallback via attributes map
              final fallback = valueNameToId[criteria.brand!.trim().toLowerCase()];
              if (fallback != null) brandIds = [fallback];
            }
          } catch (_) {}
        }

        // Reuse deepestCategoryIds for filter endpoint (same calculation)
        print('🎯 _scheduleCountFetch: Using deepest category IDs for filter: $deepestCategoryIds');
        print('🎯 _scheduleCountFetch: Original criteria.categoryIds: ${criteria.categoryIds}');
        print('🎯 _scheduleCountFetch: Deepest category IDs: $deepestCategoryIds');
        print('🎯 _scheduleCountFetch: deepestCategoryIds is null? ${deepestCategoryIds == null}');
        print('🎯 _scheduleCountFetch: deepestCategoryIds isEmpty? ${deepestCategoryIds.isEmpty}');

        // Create a new list to ensure copyWith uses it (not the original reference)
        final categoryIdsForFilter = List<int>.from(deepestCategoryIds);
        print('🎯 _scheduleCountFetch: categoryIdsForFilter: $categoryIdsForFilter');
        print('🎯 _scheduleCountFetch: criteria.categoryIds BEFORE copyWith: ${criteria.categoryIds}');

        final serverCriteria = FilterCriteria(
          page: 1,
          limit: 1,
          minPrice: criteria.minPrice,
          maxPrice: criteria.maxPrice,
          minRating: criteria.minRating,
          onSale: criteria.onSale,
          inStock: criteria.inStock,
          sizes: criteria.sizes,
          colors: criteria.colors,
          materials: criteria.materials,
          seasons: criteria.seasons,
          genders: criteria.genders,
          brand: criteria.brand,
          category: criteria.category,
          categoryIds: categoryIdsForFilter, // Use deepest IDs directly
          brandIds: brandIds,
          productIds: criteria.productIds,
          attributeIds: attributeIds.toList(),
          extraAttributes: criteria.extraAttributes,
          searchQuery: criteria.searchQuery,
          sortByField: criteria.sortByField,
          sortOrder: criteria.sortOrder,
        );
        
        print('🎯 _scheduleCountFetch: serverCriteria.categoryIds after creation: ${serverCriteria.categoryIds}');
        print('🎯 _scheduleCountFetch: Expected: $categoryIdsForFilter');
        print('🎯 _scheduleCountFetch: Match? ${serverCriteria.categoryIds.toString() == categoryIdsForFilter.toString()}');
        
        // CRITICAL: Verify serverCriteria has correct categoryIds before calling filterProducts
        if (serverCriteria.categoryIds.toString() != categoryIdsForFilter.toString()) {
          print('⚠️ WARNING: serverCriteria.categoryIds mismatch! Creating corrected criteria...');
          // Recreate with correct categoryIds
          final correctedCriteria = FilterCriteria(
            page: 1,
            limit: 1,
            minPrice: criteria.minPrice,
            maxPrice: criteria.maxPrice,
            minRating: criteria.minRating,
            onSale: criteria.onSale,
            inStock: criteria.inStock,
            sizes: criteria.sizes,
            colors: criteria.colors,
            materials: criteria.materials,
            seasons: criteria.seasons,
            genders: criteria.genders,
            brand: criteria.brand,
            category: criteria.category,
            categoryIds: categoryIdsForFilter, // Force correct deepest IDs
            brandIds: brandIds,
            productIds: criteria.productIds,
            attributeIds: attributeIds.toList(),
            extraAttributes: criteria.extraAttributes,
            searchQuery: criteria.searchQuery,
            sortByField: criteria.sortByField,
            sortOrder: criteria.sortOrder,
          );
          print('🎯 _scheduleCountFetch: correctedCriteria.categoryIds: ${correctedCriteria.categoryIds}');
          final resp = await ds.filterProducts(
            correctedCriteria,
            parentChildMap: parentChildMap, // Pass parentChildMap so toJson() can filter if needed
          );
          final result = resp['result'] as Map<String, dynamic>?;
          final data = result?['data'] as Map<String, dynamic>?;
          final total = data?['total_count'] as int?;
          if (mounted) setState(() => _resultCount = total);
          return;
        }

        // ALWAYS pass parentChildMap to ensure toJson() filters correctly
        // Even though serverCriteria should have deepest IDs, pass parentChildMap as a safety measure
        final resp = await ds.filterProducts(
          serverCriteria,
          parentChildMap: parentChildMap, // Pass parentChildMap so toJson() can filter if needed
        );
        final result = resp['result'] as Map<String, dynamic>?;
        final data = result?['data'] as Map<String, dynamic>?;
        final total = data?['total_count'] as int?;
        if (mounted) setState(() => _resultCount = total);
      } catch (_) {
        if (mounted) setState(() => _resultCount = null);
      } finally {
        if (mounted) setState(() => _isCounting = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Single-source-of-truth: state provided by caller (FiltersLoaderPage)
    // Remove internal repository path to avoid re-fetch and flicker
    return BlocProvider<FiltersCubit>(
      create: (_) {
        final cubit = FiltersCubit(widget.initial);
        // Initialize pre-selected category if coming from catalog page
        if (widget.initial.categoryIds.isNotEmpty) {
          _initializePreSelectedCategory(cubit, widget.initial.categoryIds.first);
        }
        return cubit;
      },
      child: _buildScaffold(),
    );
  }

  /// Initialize pre-selected category from catalog page
  void _initializePreSelectedCategory(FiltersCubit cubit, int categoryId) {
    // Use WidgetsBinding to ensure this runs after the frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Check if category info is in options.categories
        final category = widget.options.categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => FilterCategory(id: -1, name: '', completeName: '', sequence: 0),
        );
        
        if (category.id != -1 && (category.hasChildren || category.children.isNotEmpty)) {
          // Category has children - use them if available, otherwise fetch
          if (category.children.isNotEmpty) {
            cubit.setSubcategories(categoryId, category.children);
          } else {
            // Fetch subcategories from API
            final repository = widget.repository ?? di.sl<FilterRepository>();
            final result = await repository.getCategories(page: 1, limit: 100, parentId: categoryId);
            result.fold(
              (failure) => print('Failed to load subcategories: ${failure.message}'),
              (subcategories) {
                if (subcategories.isNotEmpty) {
                  cubit.setSubcategories(categoryId, subcategories);
                }
              },
            );
          }
        }
      } catch (e) {
        print('Error initializing pre-selected category: $e');
      }
    });
  }

  Widget _buildScaffold() {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.filters, 
            style: AppFonts.getTextStyle(fontWeight: FontWeight.w600)
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: const [],
        ),
        body: SafeArea(
          child: BlocBuilder<FiltersCubit, FiltersState>(
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(child: _buildFilterContent(context, state.criteria, widget.options, state.subcategories)),
                  _buildBottomBar(context, state.criteria),
                ],
              );
            },
          ),
        ),
      );
  }

  Widget _buildFilterContent(BuildContext context, FilterCriteria criteria, FilterOptions options, Map<int, List<FilterCategory>> subcategories) {
    final cubit = widget.repository != null 
        ? null 
        : context.read<FiltersCubit>();
    
    print('🔍 _buildFilterContent: cubit=${cubit != null}, repository=${widget.repository != null}');
    print('🔍 Current subcategories keys: ${subcategories.keys.toList()}');
    print('🔍 Selected category IDs: ${criteria.categoryIds}');
    
    final minBound = options.priceRange?.minPrice ?? 0;
    final maxBound = options.priceRange?.maxPrice ?? 1000;
    
    print('🎚️ Price Slider Debug:');
    print('   minBound: $minBound, maxBound: $maxBound');
    print('   criteria.minPrice: ${criteria.minPrice}, criteria.maxPrice: ${criteria.maxPrice}');
    
    // Ensure we have a valid range
    if (minBound >= maxBound) {
      return ListView(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        children: [
          Center(
            child: Text(
              AppLocalizations.of(context)!.priceRangeNotAvailable,
              style: AppFonts.getTextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
    }
    
    // Calculate slider values - ensure start is always less than end
    double startVal, endVal;
    
    if (criteria.minPrice == null && criteria.maxPrice == null) {
      // Both are null - set reasonable defaults (start at 10% of range, end at 90% of range)
      final range = maxBound - minBound;
      startVal = minBound + (range * 0.1);
      endVal = minBound + (range * 0.9);
    } else if (criteria.minPrice == null) {
      // Only maxPrice is set
      startVal = minBound;
      endVal = (criteria.maxPrice ?? maxBound).clamp(minBound + 1, maxBound);
    } else if (criteria.maxPrice == null) {
      // Only minPrice is set
      startVal = (criteria.minPrice ?? minBound).clamp(minBound, maxBound - 1);
      endVal = maxBound;
    } else {
      // Both are set - ensure proper ordering
      final minVal = (criteria.minPrice ?? minBound).clamp(minBound, maxBound);
      final maxVal = (criteria.maxPrice ?? maxBound).clamp(minBound, maxBound);
      
      if (minVal >= maxVal) {
        // If min >= max, adjust them
        startVal = minVal;
        endVal = (minVal + 1).clamp(minBound, maxBound);
      } else {
        startVal = minVal;
        endVal = maxVal;
      }
    }
    
    print('   Calculated: startVal: $startVal, endVal: $endVal');

    final currency = context.read<CurrencyProvider>();
    
    // Get selected category for "Current Category" display
    final selectedCategoryId = criteria.categoryIds.isNotEmpty ? criteria.categoryIds.first : null;
    FilterCategory? selectedCategory;
    if (selectedCategoryId != null) {
      try {
        selectedCategory = options.categories.firstWhere((c) => c.id == selectedCategoryId);
      } catch (_) {
        selectedCategory = null;
      }
    }
    
    return ListView(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      children: [
        // Current Category box (if a category is selected)
        if (selectedCategoryId != null && selectedCategory != null) ...[
          Container(
            margin: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Category icon (triangle, square, circle)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 8,
                        child: Icon(Icons.change_history, size: 12, color: Colors.grey.shade700),
                      ),
                      Positioned(
                        top: 16,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveConstants.mdSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Category',
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.xsFontSize,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing / 2),
                      Text(
                        selectedCategory.completeName.isNotEmpty
                            ? selectedCategory.completeName
                            : selectedCategory.name,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.mdFontSize,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Price Range
        _buildSectionHeader(AppLocalizations.of(context)!.priceRange),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currency.formatPrice(startVal, locale: Localizations.localeOf(context)), 
              style: AppFonts.getTextStyle(fontWeight: FontWeight.w600)
            ),
            Text(
              currency.formatPrice(endVal, locale: Localizations.localeOf(context)), 
              style: AppFonts.getTextStyle(fontWeight: FontWeight.w600)
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(startVal, endVal),
          min: minBound,
          max: maxBound,
          activeColor: Colors.black,
          inactiveColor: Colors.grey.shade300,
          divisions: 20,
          labels: RangeLabels(
            currency.formatPrice(startVal, locale: Localizations.localeOf(context)), 
            currency.formatPrice(endVal, locale: Localizations.localeOf(context))
          ),
          onChanged: (values) async {
            await HapticService.selectionClick();
            print('🎚️ Slider onChanged: start=${values.start}, end=${values.end}');
            print('🎚️ Slider bounds: minBound=$minBound, maxBound=$maxBound');
            
            // Ensure values are within bounds and properly ordered
            final newStart = values.start.clamp(minBound, maxBound);
            final newEnd = values.end.clamp(minBound, maxBound);
            
            // Ensure start is always less than end
            final finalStart = newStart < newEnd ? newStart : newEnd - 1;
            final finalEnd = newStart < newEnd ? newEnd : newStart + 1;
            
            print('🎚️ Slider final values: start=$finalStart, end=$finalEnd');
            
            if (cubit != null) {
              cubit.setMinPrice(finalStart == minBound ? null : finalStart);
              cubit.setMaxPrice(finalEnd == maxBound ? null : finalEnd);
              _scheduleCountFetch(criteria.copyWith(
                minPrice: finalStart == minBound ? null : finalStart,
                maxPrice: finalEnd == maxBound ? null : finalEnd,
              ));
            } else {
              // Update FilterBloc
              final newCriteria = criteria.copyWith(
                minPrice: finalStart == minBound ? null : finalStart,
                maxPrice: finalEnd == maxBound ? null : finalEnd,
              );
              context.read<FilterBloc>().add(UpdateFilterCriteria(newCriteria));
              _scheduleCountFetch(newCriteria);
            }
          },
        ),
        // Add reset price button
        Padding(
          padding: EdgeInsets.only(top: ResponsiveConstants.xsSpacing),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                print('🎚️ Resetting price range');
                if (cubit != null) {
                  cubit.setMinPrice(null);
                  cubit.setMaxPrice(null);
                } else {
                  final newCriteria = criteria.copyWith(
                    minPrice: null,
                    maxPrice: null,
                  );
                  context.read<FilterBloc>().add(UpdateFilterCriteria(newCriteria));
                  _scheduleCountFetch(newCriteria);
                }
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(AppLocalizations.of(context)!.resetPrice),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.smPadding,
                  vertical: ResponsiveConstants.xsPadding,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: ResponsiveConstants.mdSpacing),

        // Category - Only show if we have categories
        if (options.categories.isNotEmpty) ...[
          ..._buildCategorySection(context, criteria, options.categories, subcategories, cubit),
          // Show subcategories directly below category chips when a category is selected
          ..._buildSubcategoriesTreeSection(context, criteria, options.categories, subcategories, cubit),
        ],

        // Show attributes/brands when:
        // 1. A leaf category (no children) is selected, OR
        // 2. Initial criteria has categoryIds (coming from catalog page) - show attributes immediately
        if (_shouldShowAttributes(criteria, options.categories, subcategories))
          ..._buildDynamicAttributeSections(context, criteria, options.attributes, cubit),

        // Toggles
        _buildSectionHeader(AppLocalizations.of(context)!.availability),
        Row(
          children: [
            Expanded(
              child: _buildToggleSwitch(
                title: AppLocalizations.of(context)!.onSale,
                value: criteria.onSale,
                onChanged: (_) {
                  if (cubit != null) {
                    cubit.toggleOnSale();
                    _scheduleCountFetch(criteria.copyWith(onSale: !criteria.onSale));
                  } else {
                    final newCriteria = criteria.copyWith(onSale: !criteria.onSale);
                    context.read<FilterBloc>().add(UpdateFilterCriteria(newCriteria));
                    _scheduleCountFetch(newCriteria);
                  }
                },
              ),
            ),
            Expanded(
              child: _buildToggleSwitch(
                title: AppLocalizations.of(context)!.inStock,
                value: criteria.inStock,
                onChanged: (_) {
                  if (cubit != null) {
                    cubit.toggleInStock();
                    _scheduleCountFetch(criteria.copyWith(inStock: !criteria.inStock));
                  } else {
                    final newCriteria = criteria.copyWith(inStock: !criteria.inStock);
                    context.read<FilterBloc>().add(UpdateFilterCriteria(newCriteria));
                    _scheduleCountFetch(newCriteria);
                  }
                },
              ),
            ),
          ],
        ),

        SizedBox(height: ResponsiveConstants.lgSpacing),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, FilterCriteria criteria) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
        ResponsiveConstants.mdPadding,
        ResponsiveConstants.smPadding,
        ResponsiveConstants.mdPadding,
        ResponsiveConstants.mdPadding,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await HapticService.warning();
                  if (widget.repository != null) {
                    context.read<FilterBloc>().add(ClearFilters());
                  } else {
                    context.read<FiltersCubit>().update(const FilterCriteria());
                    _scheduleCountFetch(const FilterCriteria());
                  }
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(AppLocalizations.of(context)!.reset),
              ),
            ),
            SizedBox(width: ResponsiveConstants.smSpacing),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await HapticService.buttonClick();
                  // Extract only deepest category IDs before applying filters
                  final cubit = context.read<FiltersCubit>();
                  final parentChildMap = _buildParentChildMap(
                    widget.options.categories,
                    cubit.state.subcategories,
                  );
                  final deepestCategoryIds = _getDeepestCategoryIds(
                    criteria.categoryIds,
                    parentChildMap,
                  );
                  print('🎯 Apply Filters: Using deepest category IDs: $deepestCategoryIds');
                  final criteriaWithDeepestIds = criteria.copyWith(
                    categoryIds: deepestCategoryIds,
                  );
                  widget.onApply(criteriaWithDeepestIds);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: (_resultCount == null)
                    ? Text(AppLocalizations.of(context)!.applyFilters)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppLocalizations.of(context)!.applyFilters),
                          const SizedBox(width: 6),
                          Text('('),
                          if (_isCounting)
                            Shimmer.fromColors(
                              baseColor: Colors.white.withValues(alpha: 0.6),
                              highlightColor: Colors.white,
                              child: Container(
                                width: 24,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            )
                          else
                            Text('$_resultCount'),
                          Text(')'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveConstants.xsSpacing),
        AnimatedToggleSwitch<bool>.rolling(
          current: value,
          values: const [false, true],
          onChanged: onChanged,
          iconBuilder: (value, size) => Icon(
            value ? Icons.check : Icons.close,
            size: 20,
            color: value ? Colors.white : Colors.grey.shade600,
          ),
          style: ToggleStyle(
            backgroundColor: Colors.grey.shade200,
            borderColor: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            indicatorColor: Colors.black,
            indicatorBorderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      child: Text(
        title,
        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildExpandableChips({
    required List<String> items,
    required List<String> selectedItems,
    required bool showAll,
    required Function(bool) onShowAllChanged,
    required Function(String, bool) onItemSelected,
    required bool isSingleSelection,
  }) {
    final int itemLimit = 8;
    final visibleItems = showAll ? items : items.take(itemLimit).toList();
    final hasMore = items.length > itemLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: ResponsiveConstants.xsSpacing,
          children: visibleItems.map((item) {
            final selected = selectedItems.contains(item);
            return ChoiceChip(
              label: ConstrainedBox(
                constraints: BoxConstraints(
                  // prevent overflow on small screens
                  maxWidth: MediaQuery.of(context).size.width * 0.55,
                ),
                child: Text(
                  item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.getTextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              selected: selected,
              checkmarkColor: Colors.white,
              onSelected: (newSelected) async {
                await HapticService.selectionClick();
                // For single selection, we need to handle the logic differently
                if (isSingleSelection) {
                  if (newSelected) {
                    // Selecting a new item - call with true
                    onItemSelected(item, true);
                  } else {
                    // Deselecting current item - call with false
                    onItemSelected(item, false);
                  }
                } else {
                  // For multiple selection, just pass the new state
                  onItemSelected(item, newSelected);
                }
              },
              selectedColor: Colors.black,
              backgroundColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(
                  color: selected ? Colors.black : Colors.grey.shade300
                )
              ),
            );
          }).toList(),
        ),
        if (hasMore)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveConstants.xsSpacing),
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () => onShowAllChanged(!showAll),
                icon: Icon(
                  showAll ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: Colors.black,
                ),
                label: Text(
                  showAll ? AppLocalizations.of(context)!.seeLess : AppLocalizations.of(context)!.seeMore,
                  style: AppFonts.getTextStyle(fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveConstants.mdPadding,
                    vertical: ResponsiveConstants.xsPadding,
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildDynamicAttributeSections(
    BuildContext context,
    FilterCriteria criteria,
    List<FilterAttribute> attributes,
    FiltersCubit? cubit,
  ) {
    final List<Widget> sections = [];
    for (final attribute in attributes) {
      final section = _buildSingleAttributeSection(context, criteria, attribute, cubit);
      if (section != null) {
        sections.add(section);
      }
    }
    return sections;
  }

  Widget? _buildSingleAttributeSection(
    BuildContext context,
    FilterCriteria criteria,
    FilterAttribute attribute,
    FiltersCubit? cubit,
  ) {
    final attributeName = attribute.name.trim();
    if (attributeName.isEmpty) return null;

    final values = attribute.values
        .map((v) => v.name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    if (values.isEmpty) return null;

    final attributeType = attribute.type.trim().toLowerCase();
    final lowerName = attributeName.toLowerCase();

    final selectedValues = _resolveSelectedValues(criteria, attributeName, lowerName, attributeType, widget.options.brands);
    final showAll = _attributeShowAll[attributeName] ?? false;
    final onShowAllChanged = (bool value) => setState(() => _attributeShowAll[attributeName] = value);

    final isColorVisual = attributeType == 'color' || lowerName.contains('color');
    final isSingleSelection = attributeType.contains('radio') || attributeType == 'select';

    if (isColorVisual) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(attributeName),
          _buildExpandableColorChips(
            items: values,
            selectedItems: selectedValues,
            showAll: showAll,
            onShowAllChanged: onShowAllChanged,
            onItemSelected: (value, selected) {
              _handleAttributeSelection(
                context: context,
                criteria: criteria,
                cubit: cubit,
                attributeName: attributeName,
                lowerAttributeName: lowerName,
                attributeType: attributeType,
                value: value,
                selected: selected,
                isSingleSelection: false,
              );
            },
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(attributeName),
        _buildExpandableChips(
          items: values,
          selectedItems: selectedValues,
          showAll: showAll,
          onShowAllChanged: onShowAllChanged,
          onItemSelected: (value, selected) {
            _handleAttributeSelection(
              context: context,
              criteria: criteria,
              cubit: cubit,
              attributeName: attributeName,
              lowerAttributeName: lowerName,
              attributeType: attributeType,
              value: value,
              selected: selected,
              isSingleSelection: isSingleSelection,
            );
          },
          isSingleSelection: isSingleSelection,
        ),
        SizedBox(height: ResponsiveConstants.mdSpacing),
      ],
    );
  }

  List<String> _resolveSelectedValues(
    FilterCriteria criteria,
    String attributeName,
    String lowerName,
    String attributeType,
    List<FilterBrand>? brands,
  ) {
    if (lowerName == 'brand' && brands != null && brands.isNotEmpty) {
      // Map brand IDs to brand names
      return brands
          .where((brand) => criteria.brandIds.contains(brand.id))
          .map((brand) => brand.name)
          .toList();
    }

    if (attributeType == 'color' || lowerName.contains('color name')) {
      return criteria.colors;
    }

    if (lowerName.contains('size')) {
      return criteria.sizes;
    }

    if (lowerName.contains('material')) {
      return criteria.materials;
    }

    if (lowerName.contains('season')) {
      return criteria.seasons;
    }

    if (lowerName.contains('gender')) {
      return criteria.genders;
    }

    return criteria.extraAttributes[attributeName] ?? const [];
  }

  void _handleAttributeSelection({
    required BuildContext context,
    required FilterCriteria criteria,
    required FiltersCubit? cubit,
    required String attributeName,
    required String lowerAttributeName,
    required String attributeType,
    required String value,
    required bool selected,
    required bool isSingleSelection,
  }) {
    FilterCriteria newCriteria = criteria;
    if (lowerAttributeName == 'brand') {
      // Find brand by name to get its ID
      final brand = widget.options.brands.firstWhere(
        (b) => b.name.trim().toLowerCase() == value.trim().toLowerCase(),
        orElse: () => const FilterBrand(id: 0, name: ''),
      );
      
      if (brand.id == 0) {
        // Brand not found, skip
        return;
      }
      
      final newBrandIds = List<int>.from(criteria.brandIds);
      if (selected) {
        if (!newBrandIds.contains(brand.id)) {
          newBrandIds.add(brand.id);
        }
      } else {
        newBrandIds.remove(brand.id);
      }
      newCriteria = criteria.copyWith(brandIds: newBrandIds, brand: null);
    } else if (attributeType == 'color' || lowerAttributeName.contains('color name')) {
      final next = List<String>.from(criteria.colors);
      if (selected) {
        if (!next.contains(value)) next.add(value);
      } else {
        next.remove(value);
      }
      newCriteria = criteria.copyWith(colors: next);
    } else if (lowerAttributeName.contains('size')) {
      final next = List<String>.from(criteria.sizes);
      if (selected) {
        if (!next.contains(value)) next.add(value);
      } else {
        next.remove(value);
      }
      newCriteria = criteria.copyWith(sizes: next);
    } else if (lowerAttributeName.contains('material')) {
      final next = List<String>.from(criteria.materials);
      if (selected) {
        if (!next.contains(value)) next.add(value);
      } else {
        next.remove(value);
      }
      newCriteria = criteria.copyWith(materials: next);
    } else if (lowerAttributeName.contains('season')) {
      final next = List<String>.from(criteria.seasons);
      if (selected) {
        if (!next.contains(value)) next.add(value);
      } else {
        next.remove(value);
      }
      newCriteria = criteria.copyWith(seasons: next);
    } else if (lowerAttributeName.contains('gender')) {
      final next = List<String>.from(criteria.genders);
      if (selected) {
        if (!next.contains(value)) next.add(value);
      } else {
        next.remove(value);
      }
      newCriteria = criteria.copyWith(genders: next);
    } else {
      final nextMap = Map<String, List<String>>.from(criteria.extraAttributes);
      final current = List<String>.from(nextMap[attributeName] ?? const []);
      if (isSingleSelection) {
        current
          ..clear();
        if (selected) {
          current.add(value);
        }
      } else {
        if (selected) {
          if (!current.contains(value)) current.add(value);
        } else {
          current.remove(value);
        }
      }
      if (current.isEmpty) {
        nextMap.remove(attributeName);
      } else {
        nextMap[attributeName] = current;
      }
      newCriteria = criteria.copyWith(extraAttributes: nextMap);
    }

    if (cubit != null) {
      cubit.update(newCriteria);
    } else {
      context.read<FilterBloc>().add(UpdateFilterCriteria(newCriteria));
    }
    _scheduleCountFetch(newCriteria);
  }

  Widget _buildColorChip(BuildContext context, {
    required String color,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    final chipColor = _colorForName(color);
    final bool useDarkText = chipColor.computeLuminance() > 0.5;
    return FilterChip(
      selectedColor: chipColor,
      backgroundColor: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? (chipColor == Colors.white ? Colors.black : chipColor) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: chipColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
          ),
          SizedBox(width: ResponsiveConstants.xsSpacing),
          Flexible(
            child: Text(
              color,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.getTextStyle(
                color: selected ? (useDarkText ? Colors.black : Colors.white) : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
    );
  }

  Widget _buildExpandableColorChips({
    required List<String> items,
    required List<String> selectedItems,
    required bool showAll,
    required Function(bool) onShowAllChanged,
    required Function(String, bool) onItemSelected,
  }) {
    final int itemLimit = 8;
    final visibleItems = showAll ? items : items.take(itemLimit).toList();
    final hasMore = items.length > itemLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: ResponsiveConstants.xsSpacing,
          children: visibleItems.map((color) {
            final selected = selectedItems.contains(color);
            return _buildColorChip(
              context,
              color: color,
              selected: selected,
              onSelected: (value) => onItemSelected(color, value),
            );
          }).toList(),
        ),
        if (hasMore)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveConstants.xsSpacing),
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () => onShowAllChanged(!showAll),
                icon: Icon(
                  showAll ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: Colors.black,
                ),
                label: Text(
                  showAll ? AppLocalizations.of(context)!.seeLess : AppLocalizations.of(context)!.seeMore,
                  style: AppFonts.getTextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveConstants.mdPadding,
                    vertical: ResponsiveConstants.xsPadding,
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static const Map<String, Color> _namedColorLookup = {
    'black': Color(0xFF000000),
    'white': Color(0xFFFFFFFF),
    'blue': Color(0xFF1E88E5),
    'red': Color(0xFFE53935),
    'green': Color(0xFF43A047),
    'yellow': Color(0xFFFDD835),
    'purple': Color(0xFF8E24AA),
    'violet': Color(0xFF8E24AA),
    'orange': Color(0xFFFB8C00),
    'pink': Color(0xFFF06292),
    'magenta': Color(0xFFD81B60),
    'fuchsia': Color(0xFFE91E63),
    'coral': Color(0xFFFF7043),
    'gold': Color(0xFFFFD54F),
    'golden': Color(0xFFFFC107),
    'silver': Color(0xFFCFD8DC),
    'grey': Color(0xFF9E9E9E),
    'gray': Color(0xFF9E9E9E),
    'navy': Color(0xFF1B3A6B),
    'camel': Color(0xFFC19A6B),
    'tan': Color(0xFFD2B48C),
    'taupe': Color(0xFFB5A18B),
    'beige': Color(0xFFF5DEB3),
    'nude': Color(0xFFF4D1B8),
    'cream': Color(0xFFF5F0E6),
    'coffee': Color(0xFF6F4E37),
    'brown': Color(0xFF795548),
    'caramel': Color(0xFFB9804F),
    'wine': Color(0xFF722F37),
    'rose': Color(0xFFF8BBD0),
    'graphite': Color(0xFF424242),
    'jeans': Color(0xFF37474F),
    'multi': Color(0xFF7E57C2),
    'natural': Color(0xFFE0C9A6),
    'cocoa': Color(0xFF5D4037),
    'whisky': Color(0xFFD2691E),
    'off': Color(0xFFF5F5F5),
    'silverado': Color(0xFFC0C0C0),
    'creamf': Color(0xFFF3E5AB),
    'pinkgold': Color(0xFFEEBDAF),
  };

  Color _colorForName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Colors.grey;
    }

    final hexCandidate = trimmed.replaceAll('#', '').replaceAll(' ', '');
    final hexMatch = RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(hexCandidate);
    if (hexMatch) {
      return Color(int.parse('FF$hexCandidate', radix: 16));
    }

    final sanitized = trimmed
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9#/]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final tokens = sanitized.split(RegExp(r'[\/\s-]+')).where((token) => token.isNotEmpty);

    for (final token in tokens) {
      final lookup = _namedColorLookup[token];
      if (lookup != null) {
        return lookup;
      }
    }

    // Attempt to combine multi-word descriptors (e.g., off white)
    if (tokens.length >= 2) {
      final composite = tokens.take(2).join();
      final lookup = _namedColorLookup[composite];
      if (lookup != null) {
        return lookup;
      }
    }

    // Fallback: generate a deterministic but pleasant color from the string hash.
    final hash = trimmed.hashCode;
    final hue = (hash & 0xFFFF) % 360;
    final saturation = 0.35 + ((hash >> 5) & 0x3F) / 200;
    final lightness = 0.55 + ((hash >> 11) & 0x3F) / 300;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), saturation.clamp(0.25, 0.7), lightness.clamp(0.45, 0.8)).toColor();
  }

  // Helper methods to extract values from attributes
  // legacy helpers removed

  /// Build category section with subcategory support
  List<Widget> _buildCategorySection(
    BuildContext context,
    FilterCriteria criteria,
    List<FilterCategory> categories,
    Map<int, List<FilterCategory>> subcategories,
    FiltersCubit? cubit,
  ) {
    print('📋 _buildCategorySection called with ${categories.length} categories');
    print('📋 Cubit available: ${cubit != null}');
    final selectedCategoryId = criteria.categoryIds.isNotEmpty ? criteria.categoryIds.first : null;
    print('📋 Selected category ID: $selectedCategoryId');
    FilterCategory? selectedCategory;
    if (selectedCategoryId != null) {
      try {
        selectedCategory = categories.firstWhere((c) => c.id == selectedCategoryId);
      } catch (_) {
        selectedCategory = null;
      }
    }

    return [
      _buildSectionHeader(AppLocalizations.of(context)!.category),
      Wrap(
        spacing: ResponsiveConstants.xsSpacing,
        runSpacing: ResponsiveConstants.xsSpacing,
        children: categories.map((category) {
          final selected = criteria.categoryIds.contains(category.id);
          return ChoiceChip(
            label: Text(
              category.name,
              style: AppFonts.getTextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: selected,
            checkmarkColor: Colors.white,
            onSelected: (_) async {
              print('🖱️ Category clicked: ${category.name} (ID: ${category.id})');
              print('Catgory id Is:::${category.id}');
              print('🖱️ Currently selected: $selected');
              print('🖱️ Cubit available: ${cubit != null}');
              
              await HapticService.selectionClick();
              
              final newCategoryIds = List<int>.from(criteria.categoryIds);
              
              if (selected) {
                print('🖱️ Deselecting category: ${category.name}');
                // Deselect: clear this category and its subcategories
                newCategoryIds.remove(category.id);
                // Clear all subcategories of this category
                final subcats = subcategories[category.id] ?? [];
                for (final subcat in subcats) {
                  newCategoryIds.remove(subcat.id);
                }
                
                // Clear subcategories from state
                if (cubit != null) {
                  cubit.clearSubcategories(category.id);
                }
              } else {
                print('🖱️ Selecting category: ${category.name}');
                // Select: clear other selections and select this category
                newCategoryIds.clear();
                newCategoryIds.add(category.id);
                
                // Always load subcategories when a category is clicked
                if (cubit != null) {
                  print('🖱️ Cubit is available, loading subcategories...');
                  // Use children if already available, otherwise fetch from API
                  if (category.children.isNotEmpty) {
                    print('🖱️ Using existing children: ${category.children.length}');
                    cubit.setSubcategories(category.id, category.children);
                  } else {
                    print('🖱️ Fetching subcategories from API...');
                    // Always fetch subcategories from API with parent_id
                    await _loadSubcategories(context, category.id, cubit);
                  }
                } else {
                  print('⚠️ Cubit is null! Cannot load subcategories.');
                  print('⚠️ Repository available: ${widget.repository != null}');
                  if (widget.repository != null) {
                    // Use repository to load subcategories
                    widget.repository!.getCategories(page: 1, limit: 100, parentId: category.id).then((result) {
                      result.fold(
                        (failure) => print('❌ Failed to load subcategories: ${failure.message}'),
                        (subcats) {
                          print('✅ Loaded ${subcats.length} subcategories via repository');
                          // Update state via FilterBloc if needed
                          // For now, just log - FilterBloc doesn't have subcategory state
                        },
                      );
                    });
                  }
                }
              }
              
              if (cubit != null) {
                cubit.setCategoryIds(newCategoryIds);
                _scheduleCountFetch(criteria.copyWith(categoryIds: newCategoryIds, category: null));
              } else {
                final newCriteria = criteria.copyWith(categoryIds: newCategoryIds, category: null);
                context.read<FilterBloc>().add(UpdateFilterCriteria(newCriteria));
                _scheduleCountFetch(newCriteria);
              }
            },
            selectedColor: Colors.black,
            backgroundColor: Colors.white,
            shape: StadiumBorder(
              side: BorderSide(
                color: selected ? Colors.black : Colors.grey.shade300,
              ),
            ),
          );
        }).toList(),
      ),
      SizedBox(height: ResponsiveConstants.smSpacing),
    ];
  }

  /// Build subcategories tree section (displayed before COLOR/attributes)
  List<Widget> _buildSubcategoriesTreeSection(
    BuildContext context,
    FilterCriteria criteria,
    List<FilterCategory> categories,
    Map<int, List<FilterCategory>> subcategories,
    FiltersCubit? cubit,
  ) {
    final selectedCategoryId = criteria.categoryIds.isNotEmpty ? criteria.categoryIds.first : null;
    if (selectedCategoryId == null) {
      print('🌳 No category selected, returning empty');
      return [];
    }

    FilterCategory? selectedCategory;
    try {
      selectedCategory = categories.firstWhere((c) => c.id == selectedCategoryId);
    } catch (_) {
      // Category not found in main categories, might be a subcategory
      // Try to find it in loaded subcategories
      for (final subs in subcategories.values) {
        try {
          selectedCategory = subs.firstWhere((c) => c.id == selectedCategoryId);
          break;
        } catch (_) {
          continue;
        }
      }
    }

    if (selectedCategory == null) {
      print('🌳 Selected category not found for ID: $selectedCategoryId');
      return [];
    }

    // Get subcategories from cubit state if available, otherwise use passed subcategories
    final cubitSubcategories = cubit != null ? cubit.state.subcategories : subcategories;
    final loadedSubcategories = cubitSubcategories[selectedCategoryId] ?? selectedCategory.children;
    
    print('🌳 Subcategories Tree Section Debug:');
    print('   selectedCategoryId: $selectedCategoryId');
    print('   selectedCategory.name: ${selectedCategory.name}');
    print('   selectedCategory.hasChildren: ${selectedCategory.hasChildren}');
    print('   selectedCategory.children.length: ${selectedCategory.children.length}');
    print('   loadedSubcategories.length: ${loadedSubcategories.length}');
    print('   cubitSubcategories keys: ${cubitSubcategories.keys.toList()}');
    
    final shouldShowSubcategories = selectedCategory.hasChildren || 
        selectedCategory.children.isNotEmpty || 
        loadedSubcategories.isNotEmpty;
    
    if (!shouldShowSubcategories) {
      print('🌳 Should not show subcategories');
      return [];
    }
    
    print('🌳 Will show ${loadedSubcategories.length} subcategories');

    return [
      // Show subcategories list directly below the category chips
      Padding(
        padding: EdgeInsets.only(
          left: ResponsiveConstants.mdPadding,
          top: ResponsiveConstants.smSpacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loadedSubcategories.isNotEmpty) ...[
              // Show subcategories tree
              ..._buildCategoryTree(
                context,
                criteria,
                loadedSubcategories,
                selectedCategoryId,
                cubit,
                0, // Start at level 0 (first level of subcategories)
              ),
            ] else if (selectedCategory.hasChildren) ...[
              // Show loading indicator
              Padding(
                padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.smSpacing),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
                      ),
                    ),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    Text(
                      AppLocalizations.of(context)!.loadingCategoryDetails,
                      style: AppFonts.getTextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      SizedBox(height: ResponsiveConstants.mdSpacing),
    ];
  }

  /// Build category tree recursively
  List<Widget> _buildCategoryTree(
    BuildContext context,
    FilterCriteria criteria,
    List<FilterCategory> categories,
    int parentId,
    FiltersCubit? cubit,
    int level,
  ) {
    print('🌳 _buildCategoryTree called with ${categories.length} categories at level $level');
    if (categories.isEmpty) {
      print('🌳 No categories to display, returning empty');
      return [];
    }

    return categories.map((category) {
      final isSelected = criteria.categoryIds.contains(category.id);
      // Use category's own children first (from API nested response), 
      // then check loaded subcategories from cubit, otherwise use empty
      final categoryChildren = category.children.isNotEmpty 
          ? category.children 
          : (cubit != null 
              ? (cubit.state.subcategories[category.id] ?? [])
              : []);
      final hasChildren = category.hasChildren || category.children.isNotEmpty || categoryChildren.isNotEmpty;
      final isExpanded = _expandedCategories[category.id] ?? false;
      final subcategories = categoryChildren;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: level * ResponsiveConstants.mdSpacing,
              top: ResponsiveConstants.xsSpacing,
              bottom: ResponsiveConstants.xsSpacing,
            ),
            child: Row(
                children: [
                  // Expand/collapse icon
                  if (hasChildren)
                    Semantics(
                      label: isExpanded 
                          ? AppLocalizations.of(context)!.collapseCategory
                          : AppLocalizations.of(context)!.expandCategory,
                      button: true,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _expandedCategories[category.id] = !isExpanded;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                          child: Icon(
                            isExpanded ? Icons.expand_more : Icons.chevron_right,
                            size: 20,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(width: ResponsiveConstants.xsSpacing),
                  
                  // Category checkbox/selection
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) async {
                      await HapticService.selectionClick();
                      
                      final newCategoryIds = List<int>.from(criteria.categoryIds);
                      
                      if (isSelected) {
                        newCategoryIds.remove(category.id);
                        _removeCategoryAndChildren(newCategoryIds, category, subcategories);
                      } else {
                        if (!newCategoryIds.contains(parentId)) {
                          newCategoryIds.add(parentId);
                        }
                        if (!newCategoryIds.contains(category.id)) {
                          newCategoryIds.add(category.id);
                        }
                        
                        // Always load children if not already loaded
                        if (subcategories.isEmpty && cubit != null) {
                          await _loadSubcategories(context, category.id, cubit);
                          // After loading, get the updated subcategories
                          final updatedSubcats = cubit.state.subcategories[category.id] ?? category.children;
                          if (updatedSubcats.isNotEmpty) {
                            setState(() {
                              _expandedCategories[category.id] = true;
                            });
                          }
                        } else if (hasChildren) {
                          // Expand if has children (already loaded)
                          setState(() {
                            _expandedCategories[category.id] = true;
                          });
                        }
                      }
                      
                      if (cubit != null) {
                        cubit.setCategoryIds(newCategoryIds);
                        _scheduleCountFetch(criteria.copyWith(categoryIds: newCategoryIds, category: null));
                        
                        if (!hasChildren) {
                          await _reloadFiltersForCategory(context, category.id);
                        }
                      } else {
                        final newCriteria = criteria.copyWith(categoryIds: newCategoryIds, category: null);
                        context.read<FilterBloc>().add(UpdateFilterCriteria(newCriteria));
                        _scheduleCountFetch(newCriteria);
                      }
                    },
                    activeColor: Colors.black,
                  ),
                  
                  // Category name
                  Expanded(
                    child: Text(
                      category.name,
                      style: AppFonts.getTextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.black : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  
                  // Product count if available
                  if (category.productCount > 0)
                    Padding(
                      padding: EdgeInsets.only(right: ResponsiveConstants.xsSpacing),
                      child: Text(
                        '(${category.productCount})',
                        style: AppFonts.getTextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Recursively show children if expanded
          // Use category's own children (from nested API response) for dynamic tree
          final childrenToShow = category.children.isNotEmpty 
              ? category.children 
              : subcategories;
          
          if (hasChildren && isExpanded && childrenToShow.isNotEmpty)
            ..._buildCategoryTree(
              context,
              criteria,
              childrenToShow,
              category.id,
              cubit,
              level + 1,
            ),
        ],
      );
    }).toList();
  }

  /// Helper method to remove category and all its children from selection
  void _removeCategoryAndChildren(
    List<int> categoryIds,
    FilterCategory category,
    List<FilterCategory> children,
  ) {
    categoryIds.remove(category.id);
    for (final child in children) {
      categoryIds.remove(child.id);
      if (child.children.isNotEmpty) {
        _removeCategoryAndChildren(categoryIds, child, child.children);
      }
    }
  }

  /// Check if attributes should be shown
  /// Returns true if:
  /// 1. A leaf category (no children) is selected, OR
  /// 2. Initial criteria has categoryIds (coming from catalog page) - show attributes for pre-selected category
  bool _shouldShowAttributes(
    FilterCriteria criteria,
    List<FilterCategory> categories,
    Map<int, List<FilterCategory>> subcategories,
  ) {
    if (criteria.categoryIds.isEmpty) return false;
    
    // If we have categoryIds in initial criteria (coming from catalog page), show attributes
    // This handles the case where user opens filters from a category catalog page
    if (widget.initial.categoryIds.isNotEmpty && 
        criteria.categoryIds.contains(widget.initial.categoryIds.first)) {
      // Check if the pre-selected category is a leaf or has subcategories loaded
      final preSelectedId = widget.initial.categoryIds.first;
      final preSelectedCategory = categories.firstWhere(
        (c) => c.id == preSelectedId,
        orElse: () => FilterCategory(id: -1, name: '', completeName: '', sequence: 0),
      );
      
      if (preSelectedCategory.id != -1) {
        // If category has children and we have subcategories loaded, check if a leaf subcategory is selected
        if ((preSelectedCategory.hasChildren || preSelectedCategory.children.isNotEmpty) || 
            subcategories.containsKey(preSelectedId)) {
          // Has subcategories - only show attributes if a leaf subcategory is selected
          return _isLeafCategorySelected(criteria, categories, subcategories);
        } else {
          // No children or subcategories - it's a leaf, show attributes
          return true;
        }
      }
      // If we can't find the category in the list, still show attributes (fallback)
      return true;
    }
    
    // Otherwise, use the normal logic - only show if leaf category selected
    return _isLeafCategorySelected(criteria, categories, subcategories);
  }

  /// Check if a leaf category (no children) is selected
  bool _isLeafCategorySelected(
    FilterCriteria criteria,
    List<FilterCategory> categories,
    Map<int, List<FilterCategory>> subcategories,
  ) {
    if (criteria.categoryIds.isEmpty) return false;
    
    final selectedId = criteria.categoryIds.last; // Get the last (most specific) selected category
    
    // Check if it's a subcategory first
    for (final subs in subcategories.values) {
      final subcat = subs.firstWhere((s) => s.id == selectedId, orElse: () => FilterCategory(id: -1, name: '', completeName: '', sequence: 0));
      if (subcat.id != -1) {
        return !subcat.hasChildren && subcat.children.isEmpty;
      }
    }
    
    // Check main categories
    final category = categories.firstWhere(
      (c) => c.id == selectedId,
      orElse: () => FilterCategory(id: -1, name: '', completeName: '', sequence: 0),
    );
    
    if (category.id == -1) return false;
    
    // If category has children but none are in subcategories, it's not a leaf
    if (category.hasChildren || category.children.isNotEmpty) {
      final subs = subcategories[category.id] ?? [];
      return subs.isEmpty || subs.every((s) => !s.hasChildren && s.children.isEmpty && criteria.categoryIds.contains(s.id));
    }
    
    return true; // No children means it's a leaf
  }

  /// Load subcategories from API with nested children
  /// Sends request with parent_id and max_depth: 1
  Future<void> _loadSubcategories(BuildContext context, int parentId, FiltersCubit cubit) async {
    try {
      print('🌳 Loading subcategories for parentId: $parentId');
      print('🌳 Request params: {parent_id: $parentId, max_depth: 1}');
      final dataSource = di.sl<FilterRemoteDataSource>();
      final subcats = await dataSource.getCategoriesWithChildren(
        parentId: parentId,
        maxDepth: 1, // Use max_depth: 1 as specified
      );
      print('🌳 Loaded ${subcats.length} subcategories for parentId: $parentId');
      for (final subcat in subcats) {
        print('   - ${subcat.name} (ID: ${subcat.id}, hasChildren: ${subcat.hasChildren}, children: ${subcat.children.length})');
      }
      cubit.setSubcategories(parentId, subcats);
      print('🌳 Subcategories stored in cubit state for parentId: $parentId');
      print('🌳 Cubit state now has subcategories for keys: ${cubit.state.subcategories.keys.toList()}');
      print('🌳 Verifying stored subcategories: ${cubit.state.subcategories[parentId]?.length ?? 0} items');
    } catch (e) {
      print('❌ Error loading subcategories: $e');
    }
  }

  /// Reload filters (attributes/brands) for a selected category
  Future<void> _reloadFiltersForCategory(BuildContext context, int categoryId) async {
    // This will be handled by the parent component when category changes
    // The filters page will reload options with the new categoryId
    print('🔄 Should reload filters for category: $categoryId');
  }
}
