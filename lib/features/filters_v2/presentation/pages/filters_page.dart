import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../filters/domain/entities/filter_criteria.dart';
import '../../../filters/domain/entities/filter_options.dart';
import '../../../filters/domain/entities/filter_attribute.dart';
import '../../../filters/domain/entities/filter_brand.dart';
import '../../../filters/domain/entities/filter_category.dart';
import '../bloc/filters_bloc.dart';
import '../bloc/filters_event.dart';
import '../bloc/filters_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../product_details/presentation/utils/attribute_label_helper.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/services/haptic_service.dart';
import 'dart:async';
import '../../../../core/di/injection_container.dart' as di;
import '../../../filters/data/datasources/filter_remote_data_source.dart';
import '../../../filters/domain/usecases/get_available_filters.dart';
import '../../../filters/domain/usecases/clear_available_filters_cache.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../widgets/filters_shimmer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

/// Main filters page using BLoC pattern with UI from old Cubit implementation
class FiltersPage extends StatefulWidget {
  final FilterCriteria initial;
  final FilterOptions options;
  final void Function(FilterCriteria) onApply;

  const FiltersPage({
    super.key,
    required this.initial,
    required this.options,
    required this.onApply,
  });

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  late final FiltersBloc _filtersBloc;
  late FilterOptions _options;
  int _subcategoriesRequestSeq = 0;
  int _attributesRequestSeq = 0;
  final Map<String, bool> _attributeShowAll = {};
  final Set<int> _loadingCategoryIds = {}; // Track which categories are currently loading (for UI shimmer)
  final Set<int> _subcategoriesApiInProgress = {}; // Track which categories have API calls in progress (prevent duplicates)
  late List<FilterAttribute> _currentAttributes; // Attributes that update when category changes
  List<int>? _currentAttributesCategoryId; // null => global (no category_ids), sorted list for cache key
  final Map<List<int>?, List<FilterAttribute>> _attributesCache = {}; // cache per category_ids list (null => global)
  List<int>? _deepestCategoryIdsForAttributes; // Store the deepest category IDs used to load current attributes
  bool _isAttributesLoading = false;
  int? _resultCount;
  Timer? _debounce;
  bool _isCounting = false;
  bool _isApplying = false;
  bool _isRefreshingOptions = false;


  /// Map attribute names to IDs for API request
  Future<FilterCriteria> _mapAttributeNamesToIds(FilterCriteria criteria) async {
    try {
      // IMPORTANT: Avoid re-fetching attributes here (it was doubling requests).
      // Use already loaded attributes for the currently selected categories when possible.
      final ds = di.sl<FilterRemoteDataSource>();
      
      // Use the deepest category IDs that were used to load current attributes
      // This ensures we use the correct attributes (subcategories if selected, parent otherwise)
      final categoryIds = _deepestCategoryIdsForAttributes;
      
      // Create cache key from sorted category IDs list (for consistent caching)
      List<int>? cacheKey;
      if (categoryIds != null && categoryIds.isNotEmpty) {
        cacheKey = List<int>.from(categoryIds)..sort();
      }

      List<FilterAttribute> attrs;
      // IMPORTANT: Only use cached attributes if they match the current category selection
      // AND the category ID matches (to avoid showing wrong category's attributes)
      if (_currentAttributesCategoryId == cacheKey && _currentAttributes.isNotEmpty) {
        attrs = _currentAttributes;
      } else if (cacheKey != null && _attributesCache[cacheKey] != null && _attributesCache[cacheKey]!.isNotEmpty) {
        // Only use cache if it has attributes (not empty)
        attrs = _attributesCache[cacheKey]!;
      } else {
        // Fallback only (should be rare): fetch once and cache it using deepest category IDs
        // Use the deepest category IDs if available, otherwise extract from criteria
        List<int>? deepestCategoryIds = _deepestCategoryIdsForAttributes;
        
        if (deepestCategoryIds == null && criteria.categoryIds.isNotEmpty) {
          // Try to get subcategories from BLoC if context is available
          try {
            if (mounted) {
              final currentState = context.read<FiltersBloc>().state;
              Map<int, List<FilterCategory>> subcategoriesMap = {};
              if (currentState is FiltersLoaded) {
                subcategoriesMap = currentState.subcategories;
              }
              final deepestIds = _getDeepestCategoryIds(criteria.categoryIds, subcategoriesMap);
              deepestCategoryIds = deepestIds.isNotEmpty ? deepestIds : null;
            }
          } catch (_) {
            // If context is not available, use all category IDs as fallback
            deepestCategoryIds = criteria.categoryIds;
          }
        }
        
        attrs = await ds.getAttributes(page: 1, limit: 200, categoryIds: deepestCategoryIds);
        final fallbackCacheKey = deepestCategoryIds != null && deepestCategoryIds.isNotEmpty
            ? (List<int>.from(deepestCategoryIds)..sort())
            : null;
        if (fallbackCacheKey != null) {
          _attributesCache[fallbackCacheKey] = attrs;
        }
        _currentAttributesCategoryId = fallbackCacheKey;
        _currentAttributes = attrs;
        _deepestCategoryIdsForAttributes = deepestCategoryIds;
      }
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

      // Preserve existing brandIds, only map if we have a brand name but no IDs
      List<int> brandIds = criteria.brandIds;
      if ((criteria.brand ?? '').isNotEmpty && brandIds.isEmpty) {
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
            final fallback = valueNameToId[criteria.brand!.trim().toLowerCase()];
            if (fallback != null) brandIds = [fallback];
          }
        } catch (_) {}
      }

      // Return FilterCriteria with mapped attributeIds
      return criteria.copyWith(
        attributeIds: attributeIds.toList(),
        brandIds: brandIds,
      );
    } catch (e) {
      debugPrint('Error mapping attribute names to IDs: $e');
      // Return original criteria if mapping fails
      return criteria;
    }
  }

  void _scheduleCountFetch(FilterCriteria criteria) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try { 
        final bool needsAttributeMapping =
            criteria.colors.isNotEmpty ||
            criteria.materials.isNotEmpty ||
            criteria.sizes.isNotEmpty ||
            criteria.seasons.isNotEmpty ||
            criteria.genders.isNotEmpty ||
            criteria.extraAttributes.isNotEmpty ||
            
            ((criteria.brand ?? '').isNotEmpty && criteria.brandIds.isEmpty);
 
        if (needsAttributeMapping && _isAttributesLoading) {
          _scheduleCountFetch(criteria);
          return;
        }

        if (mounted) setState(() => _isCounting = true);
        final mappedCriteria =
            needsAttributeMapping ? await _mapAttributeNamesToIds(criteria) : criteria;
        final serverCriteria = mappedCriteria.copyWith(
          page: 1,
          limit: 1,
        );

        final ds = di.sl<FilterRemoteDataSource>();
        final resp = await ds.filterProducts(serverCriteria);
        // API may return either:
        // - RPC wrapped: { result: { data: { total_count } } }
        // - direct:      { data: { total_count } }
        // - sometimes:   { result: { total_count } }
        int? total;
        final result = resp['result'];
        if (result is Map) {
          final rData = result['data'];
          if (rData is Map && rData['total_count'] is int) {
            total = rData['total_count'] as int;
          } else if (result['total_count'] is int) {
            total = result['total_count'] as int;
          }
        }
        if (total == null) {
          final data = resp['data'];
          if (data is Map && data['total_count'] is int) {
            total = data['total_count'] as int;
          }
        }
        final int? sentCategoryId =
            mappedCriteria.categoryIds.isNotEmpty ? mappedCriteria.categoryIds.last : null;
        // Keep a compact summary for count updates
        debugPrint(
          '🔢 Count updated → total_count=${total ?? -1} '
          '(categoryPath=${mappedCriteria.categoryIds}, sent category_id=$sentCategoryId, '
          'attributeValues=${mappedCriteria.attributeIds.length})',
        );
        if (mounted) setState(() => _resultCount = total);
      } catch (_) {
        if (mounted) setState(() => _resultCount = null);
      } finally {
        if (mounted) setState(() => _isCounting = false);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _filtersBloc = FiltersBloc(widget.initial);
    _options = widget.options;

    // Start with empty attributes - will be loaded based on category selection
    // This prevents showing global attributes when a category with no attributes is selected
    _currentAttributes = [];
    _currentAttributesCategoryId = null;
    // Only cache initial attributes if they exist and we're not starting with a pre-selected category
    if (_options.attributes.isNotEmpty && widget.initial.categoryIds.isEmpty) {
      _attributesCache[null] = _options.attributes;
    }

    if (widget.initial.categoryIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final firstCategoryId = widget.initial.categoryIds.first;
        _initializePreSelectedCategory(firstCategoryId);
        // Fetch subcategories from API so they show on initial load (e.g. Men selected → show Men's subcategories)
        _loadSubcategories(firstCategoryId, bloc: _filtersBloc);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.initial.categoryIds.isNotEmpty) {
        final currentState = _filtersBloc.state;
        Map<int, List<FilterCategory>> subcategoriesMap = {};
        if (currentState is FiltersLoaded) {
          subcategoriesMap = currentState.subcategories;
        }

        // Extract deepest category IDs - if subcategories exist in initial selection,
        // use only those (exclude parent)
        final deepestCategoryIds = _getDeepestCategoryIds(
          widget.initial.categoryIds,
          subcategoriesMap,
        );
        final categoryIdsForAttributes = deepestCategoryIds.isNotEmpty
            ? deepestCategoryIds
            : null;

        debugPrint('🎯 initState: categoryIds=${widget.initial.categoryIds}, '
            'deepestForAttributes=$deepestCategoryIds, '
            'willFetchAttributesFor=$categoryIdsForAttributes');

        _reloadAttributesForCategoryIds(categoryIdsForAttributes, forceNetwork: true);
      } else {
        _reloadAttributesForCategoryIds(null, forceNetwork: true);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _filtersBloc.close();
    super.dispose();
  }

  /// Reload attributes (e.g., COLOR) when category or subcategory changes.
  /// When no category is selected, we fetch global attributes (no category_ids).
  /// Now accepts all selected category IDs to send them all to the backend.
  Future<void> _reloadAttributesForCategoryIds(
    List<int>? categoryIds, {
    bool forceNetwork = false,
  }) async {
    try {
      final ds = di.sl<FilterRemoteDataSource>();
      final int requestSeq = ++_attributesRequestSeq;

      // BUSINESS REQUIREMENT:
      // For the attributes endpoint (/ecom/get/product/attributes) we must send
      // ONLY the last selected (deepest) category/subcategory ID, not the full
      // list including parents or multiple siblings.
      //
      // Example:
      //   categoryIds = [554, 559, 565, 573, 569]
      //   → effectiveCategoryIdsForApi = [569]
      //
      // The UI can still keep the full path in criteria.categoryIds so chips
      // show all selected categories, but this method will narrow the list to
      // a single id for the API call and caching.
      List<int>? effectiveCategoryIdsForApi;
      if (categoryIds != null && categoryIds.isNotEmpty) {
        final lastId = categoryIds.last;
        effectiveCategoryIdsForApi = [lastId];
        debugPrint('🎯 Attributes: original categoryIds=$categoryIds → using lastSelected=$lastId');
      }

      // Create cache key from sorted category IDs list (for consistent caching)
      List<int>? cacheKey;
      if (effectiveCategoryIdsForApi != null && effectiveCategoryIdsForApi.isNotEmpty) {
        cacheKey = List<int>.from(effectiveCategoryIdsForApi)..sort();
      }

      // Cache hit => instant UI update, no network
      // BUT: Always fetch fresh when category selection changes to ensure we get the correct attributes
      // IMPORTANT: Only use cache if it matches the current selection AND is not empty
      // CRITICAL: Never use global attributes cache (null key) when a specific category is selected
      final cached = cacheKey != null ? _attributesCache[cacheKey] : null;
      if (!forceNetwork && 
          cached != null && 
          cached.isNotEmpty && 
          _currentAttributesCategoryId == cacheKey &&
          cacheKey != null) { // Never use cache if cacheKey is null (global) when we're fetching for a category
        // Only use cache if it matches the current selection exactly and has attributes
        if (!mounted) return;
        setState(() {
          _currentAttributes = cached;
          _currentAttributesCategoryId = cacheKey;
          _deepestCategoryIdsForAttributes = categoryIds;
          _isAttributesLoading = false;
        });
        debugPrint('🎨 Using cached attributes for categoryIds=$categoryIds');
        return;
      }
      
      // If cache exists but is empty, don't use it - fetch fresh to ensure we get latest data
      if (!forceNetwork && cached != null && cached.isEmpty) {
        debugPrint('⚠️ Attributes cache empty for categoryIds=$categoryIds → fetching fresh');
        // Continue to fetch fresh attributes
      }
      
      // CRITICAL: If we're fetching for a specific category, ensure we don't accidentally use global attributes
      if (effectiveCategoryIdsForApi != null &&
          effectiveCategoryIdsForApi.isNotEmpty &&
          _currentAttributesCategoryId == null) {
        debugPrint(
          '⚠️ Attributes: fetching for categoryIds=$effectiveCategoryIdsForApi '
          'while _currentAttributesCategoryId is null (global) → clearing to avoid stale data',
        );
        if (mounted) {
          setState(() {
            _currentAttributes = []; // Clear any global attributes
          });
        }
      }
      
      // Note: Attributes are already cleared in _onCategoryIdsChanged before this method is called
      // So we don't need to clear them again here, just ensure loading state is set
      setState(() {
        _isAttributesLoading = true;
      });

      debugPrint('🎨 Reloading attributes: '
          'uiCategoryIds=$categoryIds, '
          'apiCategoryIds=$effectiveCategoryIdsForApi, '
          'cacheKey=$cacheKey, '
          'currentAttributesCategoryId=$_currentAttributesCategoryId');
      if (effectiveCategoryIdsForApi != null && effectiveCategoryIdsForApi.isNotEmpty) {
        debugPrint('🎨 Attributes API category_id payload=$effectiveCategoryIdsForApi');
      } else {
        debugPrint('🎨 Attributes API: no category_ids → fetching global attributes');
      }
      
      // High-level log for product-attributes API request from filters UI
      debugPrint('🛰 Attributes API call: '
          'endpoint=/ecom/get/product/attributes, page=1, limit=120, '
          'category_id=${effectiveCategoryIdsForApi ?? []}');

      final attrs = await ds.getAttributes(
        page: 1,
        limit: 120, // smaller payload for faster UI refresh
        categoryIds: effectiveCategoryIdsForApi,
      );

      // High-level summary of response before UI mapping
      debugPrint('🛰 Attributes API response: count=${attrs.length}, '
          'names=${attrs.map((a) => a.name).toList()}');

      // If user changed selection while this request was in-flight/queued, ignore stale response.
      if (!mounted || requestSeq != _attributesRequestSeq) {
        debugPrint('⚠️ Ignoring stale attributes response (requestSeq mismatch or widget disposed)');
        return;
      }

      // Filter out attributes that have no displayable values for the current category.
      // A value is considered displayable only if:
      //  - it has a non‑empty name, AND
      //  - its productCount > 0 (there is at least one product with that value)
      //
      // This ensures that categories like "Children" which have no applicable
      // attributes in the backend (all product_count == 0) will result in an
      // empty attributes list, so the COLOR/HEIGHT/MATERIAL sections are hidden.
      final validAttrs = attrs.where((attr) {
        final nonEmptyValues = attr.values.where((v) {
          final name = v.name.trim();
          return name.isNotEmpty && v.productCount > 0;
        }).toList();

        final hasDisplayableValues = nonEmptyValues.isNotEmpty;
        if (!hasDisplayableValues) {
            debugPrint(
              '⚠️ Dropping attribute "${attr.name}" for categoryIds=$categoryIds '
              'because all values have product_count=0 or empty names.',
            );
        }

        return attr.name.trim().isNotEmpty && hasDisplayableValues;
      }).toList();

      setState(() {
        _currentAttributes = validAttrs; // Only store attributes with valid values
        _currentAttributesCategoryId = cacheKey;
        _deepestCategoryIdsForAttributes =
            effectiveCategoryIdsForApi; // Store the id actually used for attributes API
        // Only cache non-empty attributes to avoid caching empty results incorrectly
        if (cacheKey != null) {
          if (validAttrs.isEmpty) {
            // Don't cache empty attributes - clear cache entry if it exists
            _attributesCache.remove(cacheKey);
            debugPrint('⚠️ Not caching empty attributes for categoryIds=$categoryIds');
          } else {
            _attributesCache[cacheKey] = validAttrs;
          }
        }
        _isAttributesLoading = false;
      });

      debugPrint('🎨 Attributes loaded: raw=${attrs.length}, valid=${validAttrs.length} '
          'for categoryIds=$categoryIds');
    } catch (e) {
      debugPrint('❌ Error reloading attributes for category: $e');
      if (!mounted) return;
      setState(() {
        _isAttributesLoading = false;
      });
    }
  }

  /// Extract only the deepest selected category IDs for attribute fetching.
  /// 
  /// CRITICAL LOGIC:
  /// - If subcategories are selected (e.g., Bags=559, Sneakers=560), return ONLY subcategory IDs
  ///   This ensures the API receives only subcategory IDs: [559, 560] → sends "[559,560]" to endpoint
  /// - If only parent category is selected (e.g., Children=556), return parent ID
  ///   This ensures the API receives parent ID: [556] → sends "[556]" to endpoint
  /// 
  /// This matches the requirement: "send list of sub categories id without the main category id
  /// to the endpoint to bring the attribute that only in these sub categories"
  List<int> _getDeepestCategoryIds(
    List<int> categoryIds,
    Map<int, List<FilterCategory>> subcategories,
  ) {
    if (categoryIds.isEmpty) return [];

    // Get all parent category IDs from _options.categories (top-level: Women, Men, Children)
    final topLevelParentIds = _options.categories.map((c) => c.id).toSet();
    
    // Get all parent IDs from subcategories map keys (e.g., 554 for Women)
    final subcategoryParentIds = subcategories.keys.toSet();
    
    // Combine all parent IDs
    final allParentIds = <int>{...topLevelParentIds, ...subcategoryParentIds};
    
    // Get all subcategory IDs from subcategories map values (e.g., 559, 560, 561 for Bags, Sneakers, Heels)
    final allSubcategoryIds = <int>{};
    for (final subcategoryList in subcategories.values) {
      for (final subcategory in subcategoryList) {
        allSubcategoryIds.add(subcategory.id);
      }
    }

    // Separate parent IDs and subcategory IDs from the selected list
    final selectedParentIds = <int>[];
    final selectedSubcategoryIds = <int>[];

    for (final id in categoryIds) {
      if (allSubcategoryIds.contains(id)) {
        // This ID is a subcategory (e.g., Bags=559, Sneakers=560)
        selectedSubcategoryIds.add(id);
      } else if (allParentIds.contains(id)) {
        // This ID is a parent category (e.g., Women=554)
        selectedParentIds.add(id);
      } else {
        // Unknown ID - treat as subcategory to be safe
        selectedSubcategoryIds.add(id);
      }
    }

    // If subcategories are selected, use ONLY those (exclude parents)
    // This ensures attributes are fetched for Bags only, not Women+Bags
    if (selectedSubcategoryIds.isNotEmpty) {
      debugPrint('🎯 _getDeepestCategoryIds: subcategories=$selectedSubcategoryIds, parents=$selectedParentIds');
      return selectedSubcategoryIds;
    } else {
      // Only parent categories selected, use those
      debugPrint('🎯 _getDeepestCategoryIds: onlyParents=$selectedParentIds');
      return selectedParentIds;
    }
  }

  Future<void> _onCategoryIdsChanged(
    BuildContext blocContext,
    FilterCriteria criteria,
    List<int> newCategoryIds,
  ) async {
    blocContext.read<FiltersBloc>().add(
      FiltersCategoryIdsSet(newCategoryIds),
    );
    final updatedCriteria =
        criteria.copyWith(categoryIds: newCategoryIds, category: null);
    _scheduleCountFetch(updatedCriteria);

    // Get the current state to access subcategories map
    final currentState = blocContext.read<FiltersBloc>().state;
    Map<int, List<FilterCategory>> subcategoriesMap = {};
    if (currentState is FiltersLoaded) {
      subcategoriesMap = currentState.subcategories;
    }

    // Extract only the deepest selected category IDs for attribute fetching
    // CRITICAL: If subcategories are selected, use ONLY subcategory IDs (exclude parent)
    // If only parent is selected, use the parent ID
    final deepestCategoryIds = _getDeepestCategoryIds(newCategoryIds, subcategoriesMap);
    final categoryIdsForAttributes = deepestCategoryIds.isNotEmpty ? deepestCategoryIds : null;
    
    debugPrint('🎯 _onCategoryIdsChanged: all=$newCategoryIds, deepest=$deepestCategoryIds, '
        'forAttributes=$categoryIdsForAttributes');
    
    // Create cache key for the new category
    List<int>? newCacheKey;
    if (categoryIdsForAttributes != null && categoryIdsForAttributes.isNotEmpty) {
      newCacheKey = List<int>.from(categoryIdsForAttributes)..sort();
    }
    
    // CRITICAL: Immediately clear old attributes when category changes to prevent showing stale data
    // This ensures that if the new category has no attributes, we don't show the old category's attributes
    if (mounted) {
      setState(() {
        _currentAttributes = []; // Clear immediately - will be populated by API response
        _currentAttributesCategoryId = null; // Reset to force fresh fetch
        _isAttributesLoading = true; // Show loading state
      });
    }
    
    debugPrint('🎯 Category selection: all=$newCategoryIds, deepest=$deepestCategoryIds, '
        'forAttributes=$categoryIdsForAttributes (parents excluded when subcategories selected)');
    await _reloadAttributesForCategoryIds(categoryIdsForAttributes, forceNetwork: true);
  }

  void _initializePreSelectedCategory(int categoryId) {
    final category = _options.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => FilterCategory(id: -1, name: '', completeName: '', sequence: 0),
    );

    if (category.id != -1 && category.children.isNotEmpty) {
      _filtersBloc.add(FiltersSubcategoriesSet(categoryId, category.children));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FiltersBloc>.value(
      value: _filtersBloc,
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.filters,
          style: AppFonts.getTextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        backgroundColor: colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: colorScheme.onBackground,
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.resetPrice,
            onPressed: _isRefreshingOptions ? null : _onRefreshFiltersPressed,
            icon: _isRefreshingOptions
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    color: colorScheme.onBackground,
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<FiltersBloc, FiltersState>(
          buildWhen: (previous, current) {
            // Always rebuild when state changes, especially for subcategories
            if (previous is FiltersLoaded && current is FiltersLoaded) {
              // Rebuild if subcategories map changed (new entries or updates)
              final prevSubcats = previous.subcategories;
              final currSubcats = current.subcategories;
              if (prevSubcats.length != currSubcats.length) {
                return true;
              }
              // Check if any subcategory lists changed
              for (final key in currSubcats.keys) {
                if (!prevSubcats.containsKey(key) || 
                    prevSubcats[key] != currSubcats[key]) {
                  return true;
                }
              }
              // Also rebuild on criteria changes
              return previous.criteria != current.criteria;
            }
            return previous != current;
          },
          builder: (context, state) {
            if (state is FiltersLoaded) {
              if (_isRefreshingOptions) {
                // While refreshing filter metadata from the backend, show the
                // same skeleton/shimmer that we use on initial load so the
                // user clearly sees a loading state instead of a frozen UI.
                return const FiltersShimmer();
              }
              return Column(
                children: [
                  Expanded(
                    child: _buildFilterContent(
                      context,
                      state.criteria,
                      state.subcategories,
                    ),
                  ),
                  _buildBottomBar(context, state.criteria),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Future<void> _onRefreshFiltersPressed() async {
    if (_isRefreshingOptions) return;

    await HapticService.selectionClick();

    setState(() {
      _isRefreshingOptions = true;
    });

    try {
      final state = _filtersBloc.state;
      final currentCriteria =
          state is FiltersLoaded ? state.criteria : widget.initial;

      final clearCache = di.sl<ClearAvailableFiltersCache>();
      clearCache();

      // Also clear low-level attributes cache so that attribute endpoint
      // is called again on refresh and not served from memory.
      final remoteDataSource = di.sl<FilterRemoteDataSource>();
      remoteDataSource.clearAttributesCache();

      final getFilters = di.sl<GetAvailableFilters>();

      final int? categoryId = currentCriteria.categoryIds.isNotEmpty
          ? currentCriteria.categoryIds.first
          : null;

      final result = await getFilters(
        category: currentCriteria.category,
        brand: currentCriteria.brand,
        query: currentCriteria.searchQuery,
        categoryId: categoryId,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          AppSnackBar.error(
            context,
            '${AppLocalizations.of(context)!.error}: ${failure.message}',
          );
        },
        (options) {
          setState(() {
            _options = options;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        AppLocalizations.of(context)!.errorLoadingCountriesStates,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshingOptions = false;
        });
      }
    }
  }

  Widget _buildFilterContent(
    BuildContext context,
    FilterCriteria criteria,
    Map<int, List<FilterCategory>> subcategories,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final minBound = _options.priceRange?.minPrice ?? 0;
    final maxBound = _options.priceRange?.maxPrice ?? 1000;

    if (minBound >= maxBound) {
      return ListView(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        children: [
          Center(
            child: Text(
              AppLocalizations.of(context)!.priceRangeNotAvailable,
              style: AppFonts.getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    double startVal, endVal;
    if (criteria.minPrice == null && criteria.maxPrice == null) {
      final range = maxBound - minBound;
      startVal = minBound + (range * 0.1);
      endVal = minBound + (range * 0.9);
    } else if (criteria.minPrice == null) {
      startVal = minBound;
      endVal = (criteria.maxPrice ?? maxBound).clamp(minBound + 1, maxBound);
    } else if (criteria.maxPrice == null) {
      startVal = (criteria.minPrice ?? minBound).clamp(minBound, maxBound - 1);
      endVal = maxBound;
    } else {
      final minVal = (criteria.minPrice ?? minBound).clamp(minBound, maxBound);
      final maxVal = (criteria.maxPrice ?? maxBound).clamp(minBound, maxBound);
      if (minVal >= maxVal) {
        startVal = minVal;
        endVal = (minVal + 1).clamp(minBound, maxBound);
      } else {
        startVal = minVal;
        endVal = maxVal;
      }
    }

    final currency = Provider.of<CurrencyProvider>(context);
    return ListView(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      children: [
        // Price Range
        _buildSectionHeader(AppLocalizations.of(context)!.priceRange),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currency.formatPrice(
                startVal,
                locale: Localizations.localeOf(context),
                roundToInteger: true,
              ),
              style: AppFonts.getTextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              currency.formatPrice(
                endVal,
                locale: Localizations.localeOf(context),
                roundToInteger: true,
              ),
              style: AppFonts.getTextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(startVal, endVal),
          min: minBound,
          max: maxBound,
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          divisions: 20,
          labels: RangeLabels(
            currency.formatPrice(
              startVal,
              locale: Localizations.localeOf(context),
              roundToInteger: true,
            ),
            currency.formatPrice(
              endVal,
              locale: Localizations.localeOf(context),
              roundToInteger: true,
            ),
          ),
          onChanged: (values) async {
            await HapticService.selectionClick();
            final newStart = values.start.clamp(minBound, maxBound);
            final newEnd = values.end.clamp(minBound, maxBound);
            final finalStart = newStart < newEnd ? newStart : newEnd - 1;
            final finalEnd = newStart < newEnd ? newEnd : newStart + 1;

            context.read<FiltersBloc>().add(
              FiltersMinPriceSet(finalStart == minBound ? null : finalStart),
            );
            context.read<FiltersBloc>().add(
              FiltersMaxPriceSet(finalEnd == maxBound ? null : finalEnd),
            );

            final newCriteria = criteria.copyWith(
              minPrice: finalStart == minBound ? null : finalStart,
              maxPrice: finalEnd == maxBound ? null : finalEnd,
            );
            _scheduleCountFetch(newCriteria);
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: ResponsiveConstants.xsSpacing),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                context.read<FiltersBloc>().add(const FiltersMinPriceSet(null));
                context.read<FiltersBloc>().add(const FiltersMaxPriceSet(null));
                final newCriteria = criteria.copyWith(minPrice: null, maxPrice: null);
                _scheduleCountFetch(newCriteria);
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(AppLocalizations.of(context)!.resetPrice),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
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
        if (_options.categories.isNotEmpty) ...[
          ..._buildCategorySection(context, criteria, _options.categories, subcategories),
        ],

        // Brands - show as chips when we have brands from API
        if (_options.brands.isNotEmpty) ...[
          _buildSectionHeader(AppLocalizations.of(context)!.brand),
          Wrap(
            spacing: ResponsiveConstants.xsSpacing,
            runSpacing: ResponsiveConstants.xsSpacing,
            children: _options.brands.map((brand) {
              final selected = criteria.brandIds.contains(brand.id);
              final colorScheme = Theme.of(context).colorScheme;
              return ChoiceChip(
                label: Text(
                  brand.name,
                  style: AppFonts.getTextStyle(
                    color: selected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: selected,
                checkmarkColor: colorScheme.onPrimary,
                onSelected: (_) async {
                  await HapticService.selectionClick();
                  final newSelected = !selected;
                  _handleAttributeSelection(
                    context: context,
                    criteria: criteria,
                    attributeName: 'Brand',
                    lowerAttributeName: 'brand',
                    attributeType: 'brand',
                    value: brand.name,
                    selected: newSelected,
                    isSingleSelection: false,
                  );
                },
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.surface,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
        ],

        // Attributes are always shown below category/subcategory.
        // Backend scoping is handled by calling /ecom/get/product/attributes with:
        // - category_id = deepest selected category/subcategory (criteria.categoryIds.last)
        // - OR without category_id when nothing is selected.
        if (_isAttributesLoading)
          // Lightweight shimmer for attributes section (e.g., COLOR)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.mdPadding,
              vertical: ResponsiveConstants.smSpacing,
            ),
            child: _buildSubcategoryShimmer(),
          )
        else if (_currentAttributes.isNotEmpty)
          // Only show attribute sections if we have attributes
          // If API returns empty items [], _currentAttributes will be empty and nothing will be displayed
          ..._buildDynamicAttributeSections(context, criteria, _currentAttributes),

        // Toggles
        _buildSectionHeader(AppLocalizations.of(context)!.availability),
        _buildToggleSwitch(
          title: AppLocalizations.of(context)!.inStock,
          value: criteria.inStock,
          onChanged: (newValue) async {
            debugPrint('🔄 Toggle InStock: ${criteria.inStock} → $newValue');
            // Haptic feedback for better UX
            await HapticService.selectionClick();
            // Use the new value from the toggle switch callback
            context.read<FiltersBloc>().add(const FiltersInStockToggled());
            // Schedule count fetch with the new value
            _scheduleCountFetch(criteria.copyWith(inStock: newValue));
          },
        ),
        SizedBox(height: ResponsiveConstants.lgSpacing),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, FilterCriteria criteria) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
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
                  context.read<FiltersBloc>().add(const FiltersCleared());
                  _scheduleCountFetch(const FilterCriteria());
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(AppLocalizations.of(context)!.reset),
              ),
            ),
            SizedBox(width: ResponsiveConstants.smSpacing),
            Expanded(
              child: ElevatedButton(
                onPressed: _isApplying
                    ? null
                    : () async {
                        await HapticService.buttonClick();
                        if (mounted) setState(() => _isApplying = true);
                        try {
                          final state = context.read<FiltersBloc>().state;
                          if (state is FiltersLoaded) {
                            // CRITICAL: Map attribute names to IDs before applying filters
                            debugPrint('🎯 FiltersPage: Mapping attribute names to IDs before applying...');
                            final mappedCriteria = await _mapAttributeNamesToIds(state.criteria);
                            debugPrint('🎯 FiltersPage: Mapped FilterCriteria → '
                                'categoryIds=${mappedCriteria.categoryIds}, '
                                'brandIds=${mappedCriteria.brandIds}, '
                                'attributeIds=${mappedCriteria.attributeIds}, '
                                'limit=${mappedCriteria.limit}, '
                                'sort=${mappedCriteria.sortByField} (${mappedCriteria.sortOrder})');
                            widget.onApply(mappedCriteria);
                          }
                        } finally {
                          if (mounted) setState(() => _isApplying = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isApplying
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Applying...',
                            style: AppFonts.getTextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      )
                    : (_resultCount == null)
                        ? Text(
                            AppLocalizations.of(context)!.applyFilters,
                            style: AppFonts.getTextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.applyFilters,
                                style: AppFonts.getTextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(',
                                style: AppFonts.getTextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              if (_isCounting)
                                Shimmer.fromColors(
                                  baseColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
                                  highlightColor: Theme.of(context).colorScheme.onPrimary,
                                  child: Container(
                                    width: 24,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  '$_resultCount',
                                  style: AppFonts.getTextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              Text(
                                ')',
                                style: AppFonts.getTextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
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
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.smFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveConstants.xsSpacing / 2),
        SizedBox(
          height: 32, // Minimized height constraint
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final colorScheme = theme.colorScheme;
              final isDark = theme.brightness == Brightness.dark;
              
              return AnimatedToggleSwitch<bool>.rolling(
                current: value,
                values: const [false, true],
                onChanged: onChanged,
                iconBuilder: (value, size) => Icon(
                  value ? Icons.check : Icons.close,
                  size: 14, // Reduced icon size
                  color: value 
                      ? colorScheme.onPrimary 
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                style: ToggleStyle(
                  backgroundColor: isDark 
                      ? colorScheme.outline.withValues(alpha: 0.3)
                      : Colors.grey.shade200,
                  borderColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(50), // Fully rounded (pill shape)
                  indicatorColor: colorScheme.primary,
                  indicatorBorderRadius: BorderRadius.circular(50), // Fully rounded (pill shape)
                ),
              );
            },
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
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.mdFontSize,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
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
                  maxWidth: MediaQuery.of(context).size.width * 0.55,
                ),
                child: Text(
                  item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.getTextStyle(
                    color: selected 
                        ? Theme.of(context).colorScheme.onPrimary 
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              selected: selected,
              checkmarkColor: Theme.of(context).colorScheme.onPrimary,
              onSelected: (newSelected) async {
                await HapticService.selectionClick();
                if (isSingleSelection) {
                  if (newSelected) {
                    onItemSelected(item, true);
                  } else {
                    onItemSelected(item, false);
                  }
                } else {
                  onItemSelected(item, newSelected);
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: StadiumBorder(
                side: BorderSide(
                  color: selected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
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
                  showAll
                      ? AppLocalizations.of(context)!.seeLess
                      : AppLocalizations.of(context)!.seeMore,
                  style: AppFonts.getTextStyle(
                    fontWeight: FontWeight.w600,
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
  ) {
    final List<Widget> sections = [];
    // Filter out attributes with empty values before building sections
    final validAttributes = attributes.where((attr) {
      final values = attr.values
          .map((v) => v.name.trim())
          .where((name) => name.isNotEmpty)
          .toList();
      return attr.name.trim().isNotEmpty && values.isNotEmpty;
    }).toList();

    // Skip "Brand" attribute when we already show a dedicated Brand section from _options.brands
    // to avoid showing two Brand sections (one from options, one from product attributes API).
    for (final attribute in validAttributes) {
      final lowerName = attribute.name.trim().toLowerCase();
      if (lowerName == 'brand' && _options.brands.isNotEmpty) {
        continue; // Deduplicate: use only the section built from _options.brands
      }
      final section = _buildSingleAttributeSection(context, criteria, attribute);
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

    final selectedValues = _resolveSelectedValues(criteria, attributeName, lowerName, attributeType);
    final showAll = _attributeShowAll[attributeName] ?? false;
    final onShowAllChanged = (bool value) => setState(() => _attributeShowAll[attributeName] = value);

    // Build a lookup between the displayed name and the raw value coming
    // from the backend for this attribute. For colors, the backend often
    // sends a "value" field (e.g. hex code or english name) plus a
    // localized "name" (e.g. Arabic label). We want to:
    // - show the localized name to the user (chip text)
    // - use the raw value to compute the dot color dynamically.
    final Map<String, String> valueByName = {
      for (final v in attribute.values)
        if (v.name.trim().isNotEmpty)
          v.name.trim(): (v.value.trim().isNotEmpty ? v.value.trim() : v.name.trim()),
    };

    // Treat as color section when: type is 'color', name contains 'color', or name matches localized "Color" (e.g. "اللون" in Arabic)
    final localizedColorLabel = AppLocalizations.of(context)!.color.trim();
    final isColorVisual = attributeType == 'color' ||
        lowerName.contains('color') ||
        (attributeName.trim() == localizedColorLabel ||
            attributeName.trim().toLowerCase() == localizedColorLabel.toLowerCase());
    final isSingleSelection = attributeType.contains('radio') || attributeType == 'select';

    if (isColorVisual) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(localizedAttributeLabel(context, attributeName)),
          _buildExpandableColorChips(
            items: values,
            selectedItems: selectedValues,
            showAll: showAll,
            onShowAllChanged: onShowAllChanged,
            valueByName: valueByName,
            onItemSelected: (value, selected) {
              _handleAttributeSelection(
                context: context,
                criteria: criteria,
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
        _buildSectionHeader(localizedAttributeLabel(context, attributeName)),
        _buildExpandableChips(
          items: values,
          selectedItems: selectedValues,
          showAll: showAll,
          onShowAllChanged: onShowAllChanged,
          onItemSelected: (value, selected) {
            _handleAttributeSelection(
              context: context,
              criteria: criteria,
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
  ) {
    if (lowerName == 'brand') {
      return _options.brands
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
    required String attributeName,
    required String lowerAttributeName,
    required String attributeType,
    required String value,
    required bool selected,
    required bool isSingleSelection,
  }) {
    if (lowerAttributeName == 'brand') {
      final brand = _options.brands.firstWhere(
        (b) => b.name.trim().toLowerCase() == value.trim().toLowerCase(),
        orElse: () => const FilterBrand(id: 0, name: ''),
      );

      if (brand.id == 0) return;

      final newBrandIds = List<int>.from(criteria.brandIds);
      if (selected) {
        if (!newBrandIds.contains(brand.id)) {
          newBrandIds.add(brand.id);
        }
      } else {
        newBrandIds.remove(brand.id);
      }
      context.read<FiltersBloc>().add(FiltersBrandIdsSet(newBrandIds));
      _scheduleCountFetch(criteria.copyWith(brandIds: newBrandIds, brand: null));
    } else if (attributeType == 'color' || lowerAttributeName.contains('color name')) {
      final next = List<String>.from(criteria.colors);
      if (selected) {
        if (!next.contains(value)) next.add(value);
      } else {
        next.remove(value);
      }
      context.read<FiltersBloc>().add(FiltersColorsSet(next));
      _scheduleCountFetch(criteria.copyWith(colors: next));
    } else if (lowerAttributeName.contains('size')) {
      final next = List<String>.from(criteria.sizes);
      if (selected) {
        if (!next.contains(value)) next.add(value);
      } else {
        next.remove(value);
      }
      context.read<FiltersBloc>().add(FiltersSizesSet(next));
      _scheduleCountFetch(criteria.copyWith(sizes: next));
    } else if (lowerAttributeName.contains('material')) {
      final next = List<String>.from(criteria.materials);
      if (selected) {
        if (!next.contains(value)) next.add(value);
      } else {
        next.remove(value);
      }
      context.read<FiltersBloc>().add(FiltersMaterialsSet(next));
      _scheduleCountFetch(criteria.copyWith(materials: next));
    } else if (lowerAttributeName.contains('season')) {
      final next = List<String>.from(criteria.seasons);
      if (selected) {
        if (!next.contains(value)) next.add(value);
      } else {
        next.remove(value);
      }
      context.read<FiltersBloc>().add(FiltersSeasonsSet(next));
      _scheduleCountFetch(criteria.copyWith(seasons: next));
    } else if (lowerAttributeName.contains('gender')) {
      final next = List<String>.from(criteria.genders);
      if (selected) {
        if (!next.contains(value)) next.add(value);
      } else {
        next.remove(value);
      }
      context.read<FiltersBloc>().add(FiltersGendersSet(next));
      _scheduleCountFetch(criteria.copyWith(genders: next));
    } else {
      final nextMap = Map<String, List<String>>.from(criteria.extraAttributes);
      final current = List<String>.from(nextMap[attributeName] ?? const []);
      if (isSingleSelection) {
        current.clear();
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
      context.read<FiltersBloc>().add(FiltersExtraAttributesSet(nextMap));
      _scheduleCountFetch(criteria.copyWith(extraAttributes: nextMap));
    }
  }

  Widget _buildColorChip(
    BuildContext context, {
    required String label,
    required String rawColorValue,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    // Use the backend "value" (rawColorValue) to determine the actual
    // color for the dot, falling back to the label when needed.
    final chipColor = _colorForName(rawColorValue.isNotEmpty ? rawColorValue : label);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return FilterChip(
      // Don't change background to the actual color - keep it consistent
      // so text is always readable
      selectedColor: colorScheme.surface,
      backgroundColor: colorScheme.surface,
      shape: StadiumBorder(
        side: BorderSide(
          // Only selected chips get the orange (primary) border
          color: selected
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.3),
          width: selected ? 2 : 1,
        ),
      ),
      label: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: chipColor,
                shape: BoxShape.circle,
                border: Border.all(
                  // Radio button circle gets orange border when selected
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.4),
                  width: selected ? 2 : 1,
                ),
              ),
            ),
            SizedBox(width: ResponsiveConstants.xsSpacing),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.getTextStyle(
                  // Always use readable text color, regardless of selection
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
    Map<String, String>? valueByName,
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
              label: color,
              rawColorValue: valueByName != null ? (valueByName[color] ?? color) : color,
              selected: selected,
              onSelected: (value) => onItemSelected(color, value),
            );
          }).toList(),
        ),
        if (hasMore)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveConstants.xsSpacing),
            child: Center(
              child: Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  
                  return OutlinedButton.icon(
                    onPressed: () => onShowAllChanged(!showAll),
                    icon: Icon(
                      showAll ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: colorScheme.onSurface,
                    ),
                    label: Text(
                      showAll
                          ? AppLocalizations.of(context)!.seeLess
                          : AppLocalizations.of(context)!.seeMore,
                      style: AppFonts.getTextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      shape: const StadiumBorder(),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveConstants.mdPadding,
                        vertical: ResponsiveConstants.xsPadding,
                      ),
                      backgroundColor: colorScheme.surface,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  /// Mapping for common Arabic color names to the same colors
  /// used for their English equivalents. This ensures that the
  /// colored dot in the filters UI is consistent between English
  /// and Arabic, even though the backend only sends a localized
  /// `name` field (no shared hex/value field across locales).
  static const Map<String, Color> _arabicColorLookup = {
    // Black / White
    'اسود': Color(0xFF000000),
    'أسود': Color(0xFF000000),
    'ابيض': Color(0xFFFFFFFF),
    'أبيض': Color(0xFFFFFFFF),

    // Primary colors
    'احمر': Color(0xFFE53935), // RED
    'أحمر': Color(0xFFE53935),
    'اخضر': Color(0xFF43A047), // GREEN
    'أخضر': Color(0xFF43A047),

    // PINK
    'وردي': Color(0xFFF06292),

    // BROWN
    'بني': Color(0xFF795548),

    // CREAM
    'كريمي': Color(0xFFF5F0E6),

    // NAVY
    'نيلي': Color(0xFF1B3A6B),

    // GRAY
    'رصاصي': Color(0xFF9E9E9E),

    // BEIGE
    'بيج': Color(0xFFF5DEB3),

    // OFF WHITE
    'اوف وايت': Color(0xFFF5F5F5),
    'أوف وايت': Color(0xFFF5F5F5),

    // NUDE
    'نود': Color(0xFFF4D1B8),

    // GOLD
    'ذهبي': Color(0xFFFFD54F),

    // SILVER
    'فضي': Color(0xFFCFD8DC),
  };

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

    // First try direct Arabic name mapping so that localized
    // color names resolve to the exact same colors as English.
    final arabicColor = _arabicColorLookup[trimmed];
    if (arabicColor != null) {
      return arabicColor;
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

    final tokens =
        sanitized.split(RegExp(r'[\/\s-]+')).where((token) => token.isNotEmpty);

    for (final token in tokens) {
      final lookup = _namedColorLookup[token];
      if (lookup != null) {
        return lookup;
      }
    }

    if (tokens.length >= 2) {
      final composite = tokens.take(2).join();
      final lookup = _namedColorLookup[composite];
      if (lookup != null) {
        return lookup;
      }
    }

    final hash = trimmed.hashCode;
    final hue = (hash & 0xFFFF) % 360;
    final saturation = 0.35 + ((hash >> 5) & 0x3F) / 200;
    final lightness = 0.55 + ((hash >> 11) & 0x3F) / 300;
    return HSLColor.fromAHSL(
      1.0,
      hue.toDouble(),
      saturation.clamp(0.25, 0.7),
      lightness.clamp(0.45, 0.8),
    ).toColor();
  }

  List<Widget> _buildCategorySection(
    BuildContext context,
    FilterCriteria criteria,
    List<FilterCategory> categories,
    Map<int, List<FilterCategory>> subcategories,
  ) {
    final selectedCategoryId =
        criteria.categoryIds.isNotEmpty ? criteria.categoryIds.first : null;
    FilterCategory? selectedCategory;
    if (selectedCategoryId != null) {
      try {
        selectedCategory =
            categories.firstWhere((c) => c.id == selectedCategoryId);
      } catch (_) {
        // Try to find in all categories including nested children
        for (final category in categories) {
          if (category.id == selectedCategoryId) {
            selectedCategory = category;
            break;
          }
          // Check children recursively
          final found = _findCategoryInChildren(category.children, selectedCategoryId);
          if (found != null) {
            selectedCategory = found;
            break;
          }
        }
        
        // Also check in subcategories map
        if (selectedCategory == null) {
          for (final subs in subcategories.values) {
            try {
              selectedCategory = subs.firstWhere((c) => c.id == selectedCategoryId);
              break; // Found it, exit loop
            } catch (_) {
              // Not in this subcategory list, continue
            }
          }
        }
      }
    }

    // Calculate loaded subcategories and whether to show them
    final loadedSubcategories = subcategories[selectedCategoryId] ?? selectedCategory?.children ?? [];
    final isCurrentlyLoading = selectedCategoryId != null && _loadingCategoryIds.contains(selectedCategoryId);
    
    // Show subcategories if:
    // 1. A category is selected
    // 2. We have loaded subcategories OR we're currently loading subcategories OR category indicates it might have children
    // CRITICAL: Always show subcategory section when loading, even if we don't know if it has children yet
    final shouldShowSubcategories = selectedCategoryId != null &&
        (loadedSubcategories.isNotEmpty ||
            isCurrentlyLoading ||
            selectedCategory?.hasChildren == true ||
            selectedCategory?.children.isNotEmpty == true);
    
    final anyCategoryLoading = _loadingCategoryIds.isNotEmpty;

    return [
      // Show selected category name prominently if coming from category page
      if (selectedCategoryId != null && selectedCategory != null) ...[
        Container(
          margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.category_outlined,
                color: Theme.of(context).colorScheme.onSurface,
                size: ResponsiveConstants.mdIconSize,
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.currentCategory,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.xsFontSize,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: ResponsiveConstants.smSpacing),
      ],
      _buildSectionHeader(AppLocalizations.of(context)!.category),
      Wrap(
        spacing: ResponsiveConstants.xsSpacing,
        runSpacing: ResponsiveConstants.xsSpacing,
        children: categories.map((category) {
          final selected = criteria.categoryIds.contains(category.id);
          final isLoading = _loadingCategoryIds.contains(category.id);
          // Use the BlocBuilder context (passed down as `context` to _buildCategorySection)
          // as the stable blocContext for all async work.
          final blocContext = context;
          return Builder(
            builder: (chipContext) {
              final colorScheme = Theme.of(chipContext).colorScheme;

              return ChoiceChip(
                label: isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            selected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                      )
                    : Text(
                        category.name,
                        style: AppFonts.getTextStyle(
                          color: selected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                selected: selected,
                checkmarkColor: colorScheme.onPrimary,
                onSelected: isLoading || (!selected && anyCategoryLoading)
                    ? null // Disable all category changes while any category is loading
                    : (_) async {
                        await _handleTopLevelCategorySelected(
                          blocContext: blocContext,
                          criteria: criteria,
                          subcategories: subcategories,
                          category: category,
                          selected: selected,
                        );
                      },
                selectedColor: colorScheme.primary,
                backgroundColor: isLoading
                    ? colorScheme.surface.withValues(alpha: 0.5)
                    : colorScheme.surface,
                disabledColor: colorScheme.surface.withValues(alpha: 0.5),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: selected
                        ? colorScheme.primary
                        : isLoading
                            ? colorScheme.outline.withValues(alpha: 0.4)
                            : colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
      SizedBox(height: ResponsiveConstants.smSpacing),

      // Show subcategories if a parent category is selected
      if (shouldShowSubcategories && selectedCategoryId != null) ...[
        // Show professional loading shimmer while fetching subcategories
        if (isCurrentlyLoading && loadedSubcategories.isEmpty) ...[
          Padding(
            padding: EdgeInsets.only(
              left: ResponsiveConstants.mdSpacing,
              top: ResponsiveConstants.mdSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subcategory label shimmer
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  highlightColor: Theme.of(context).colorScheme.surface,
                  period: const Duration(milliseconds: 1200),
                  child: Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                // Subcategory chips shimmer
                _buildSubcategoryShimmer(),
              ],
            ),
          ),
        ] else if (loadedSubcategories.isNotEmpty) ...[
          // Show loaded subcategories
          ..._buildSubcategoryTree(
            context,
            criteria,
            selectedCategoryId!,
            loadedSubcategories,
            subcategories,
            1, // Start at level 1
          ),
        ],
      ],
    ];
  }

  Future<void> _handleTopLevelCategorySelected({
    required BuildContext blocContext,
    required FilterCriteria criteria,
    required Map<int, List<FilterCategory>> subcategories,
    required FilterCategory category,
    required bool selected,
  }) async {
    print('####${category.id}');
    await HapticService.selectionClick();

    // Build new categoryIds based on current selection
    final newCategoryIds = List<int>.from(criteria.categoryIds);

    if (selected) {
      // Deselect: remove category and its subcategories
      newCategoryIds.remove(category.id);
      final subcats = subcategories[category.id] ?? [];
      for (final subcat in subcats) {
        newCategoryIds.remove(subcat.id);
      }
      blocContext.read<FiltersBloc>().add(
        FiltersSubcategoriesCleared(category.id),
      );
    } else {
      // Select: clear other selections and select this category
      newCategoryIds.clear();
      newCategoryIds.add(category.id);
    }

    // Update selection + attributes FIRST so COLOR list changes immediately.
    // This will:
    // 1. If parent category selected: fetch attributes for parent category
    // 2. If subcategories selected: fetch attributes ONLY for subcategories (parent excluded)
    await _onCategoryIdsChanged(blocContext, criteria, newCategoryIds);

    // Then load subcategories in background (don’t block attribute refresh).
    if (!selected) {
      print('🌳 Category ${category.id} selected, starting subcategory load...');

      // Set loading state to show shimmer
      if (mounted && !_loadingCategoryIds.contains(category.id)) {
        setState(() {
          _loadingCategoryIds.add(category.id);
        });
        print(
          '🌳 Loading state set immediately for category ${category.id} - widget will rebuild now',
        );
      }

      print('🌳 Starting _loadSubcategories for category ${category.id}');
      _loadSubcategories(category.id, blocContext: blocContext).catchError((error) {
        print('⚠️ Error loading subcategories for ${category.id}: $error');
        if (mounted) {
          setState(() {
            _loadingCategoryIds.remove(category.id);
          });
        }
      });
    }
  }

  bool _shouldShowAttributes(
    FilterCriteria criteria,
    List<FilterCategory> categories,
    Map<int, List<FilterCategory>> subcategories,
  ) {
    if (criteria.categoryIds.isEmpty) return false;

    if (widget.initial.categoryIds.isNotEmpty &&
        criteria.categoryIds.contains(widget.initial.categoryIds.first)) {
      final preSelectedId = widget.initial.categoryIds.first;
      final preSelectedCategory = categories.firstWhere(
        (c) => c.id == preSelectedId,
        orElse: () =>
            FilterCategory(id: -1, name: '', completeName: '', sequence: 0),
      );

      if (preSelectedCategory.id != -1) {
        if ((preSelectedCategory.hasChildren ||
                preSelectedCategory.children.isNotEmpty) ||
            subcategories.containsKey(preSelectedId)) {
          return _isLeafCategorySelected(criteria, categories, subcategories);
        } else {
          return true;
        }
      }
      return true;
    }

    return _isLeafCategorySelected(criteria, categories, subcategories);
  }

  bool _isLeafCategorySelected(
    FilterCriteria criteria,
    List<FilterCategory> categories,
    Map<int, List<FilterCategory>> subcategories,
  ) {
    if (criteria.categoryIds.isEmpty) return false;

    final selectedId = criteria.categoryIds.last;

    for (final subs in subcategories.values) {
      final subcat = subs.firstWhere(
        (s) => s.id == selectedId,
        orElse: () =>
            FilterCategory(id: -1, name: '', completeName: '', sequence: 0),
      );
      if (subcat.id != -1) {
        return !subcat.hasChildren && subcat.children.isEmpty;
      }
    }

    final category = categories.firstWhere(
      (c) => c.id == selectedId,
      orElse: () =>
          FilterCategory(id: -1, name: '', completeName: '', sequence: 0),
    );

    if (category.id == -1) return false;

    if (category.hasChildren || category.children.isNotEmpty) {
      final subs = subcategories[category.id] ?? [];
      return subs.isEmpty ||
          subs.every((s) =>
              !s.hasChildren &&
              s.children.isEmpty &&
              criteria.categoryIds.contains(s.id));
    }

    return true;
  }

  /// Load subcategories for [parentId] from API and update bloc.
  /// Pass [bloc] when calling from initState (no context with provider); pass [blocContext] when calling from UI.
  Future<void> _loadSubcategories(
    int parentId, {
    BuildContext? blocContext,
    FiltersBloc? bloc,
  }) async {
    assert(bloc != null || blocContext != null, 'Provide either bloc or blocContext');
    final targetBloc = bloc ?? blocContext!.read<FiltersBloc>();

    if (_subcategoriesApiInProgress.contains(parentId)) {
      debugPrint('⚠️ API call already in progress for parentId: $parentId, skipping duplicate call...');
      return;
    }

    _subcategoriesApiInProgress.add(parentId);

    if (mounted && !_loadingCategoryIds.contains(parentId)) {
      setState(() {
        _loadingCategoryIds.add(parentId);
      });
    }

    try {
      final int requestSeq = ++_subcategoriesRequestSeq;

      final dataSource = di.sl<FilterRemoteDataSource>();
      final List<FilterCategory> subcats = await dataSource.getCategoriesWithChildren(
        parentId: parentId,
        maxDepth: 1,
      ).timeout(
        const Duration(seconds: 75),
        onTimeout: () => <FilterCategory>[],
      );

      if (!mounted || requestSeq != _subcategoriesRequestSeq) {
        debugPrint('⚠️ Ignoring stale subcategory response (requestSeq mismatch or widget disposed)');
        return;
      }

      if (subcats.isNotEmpty) {
        if (!mounted) {
          debugPrint('⚠️ Widget disposed before BLoC update, skipping subcategory set');
          return;
        }
        targetBloc.add(FiltersSubcategoriesSet(parentId, subcats));
      } else {
        debugPrint('🌳 No subcategories found for parentId: $parentId');
      }
    } catch (e) {
      debugPrint('❌ Error loading subcategories for parentId=$parentId: $e');
    } finally {
      _subcategoriesApiInProgress.remove(parentId);
      if (mounted) {
        setState(() {
          _loadingCategoryIds.remove(parentId);
        });
      }
    }
  }

  /// Helper to find category in children recursively
  FilterCategory? _findCategoryInChildren(List<FilterCategory> categories, int categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) {
        return category;
      }
      if (category.children.isNotEmpty) {
        final found = _findCategoryInChildren(category.children, categoryId);
        if (found != null) return found;
      }
    }
    return null;
  }

  /// Build subcategory tree recursively with levels
  List<Widget> _buildSubcategoryTree(
    BuildContext context,
    FilterCriteria criteria,
    int parentId,
    List<FilterCategory> categories,
    Map<int, List<FilterCategory>> subcategories,
    int level,
  ) {
    final isLoading = _loadingCategoryIds.contains(parentId);
    final loadedSubcategories = subcategories[parentId] ?? categories;
    
    // Get subcategory label
    String getSubcategoryLabel() {
      switch (level) {
        case 1:
          return AppLocalizations.of(context)!.subcategoryOne;
        case 2:
          return AppLocalizations.of(context)!.subcategoryTwo;
        case 3:
          return AppLocalizations.of(context)!.subcategoryThree;
        default:
          return 'Subcategory $level';
      }
    }

    return [
      Padding(
        padding: EdgeInsets.only(
          left: ResponsiveConstants.mdSpacing * level,
          top: level > 1 ? ResponsiveConstants.smSpacing : ResponsiveConstants.mdSpacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subcategory label
            Padding(
              padding: EdgeInsets.only(bottom: ResponsiveConstants.xsSpacing),
              child: Text(
                getSubcategoryLabel(),
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.smFontSize,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            
            // Loading shimmer or subcategories
            if (isLoading) ...[
              _buildSubcategoryShimmer(),
            ] else if (loadedSubcategories.isNotEmpty) ...[
              Wrap(
                spacing: ResponsiveConstants.xsSpacing,
                runSpacing: ResponsiveConstants.xsSpacing,
                children: loadedSubcategories.map((subcategory) {
                  final subSelected = criteria.categoryIds.contains(subcategory.id);
                  final isSubcategoryLoading = _loadingCategoryIds.contains(subcategory.id);
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  
                  return ChoiceChip(
                    label: isSubcategoryLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                subSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                              ),
                            ),
                          )
                        : Text(
                            subcategory.name,
                            style: AppFonts.getTextStyle(
                              color: subSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    selected: subSelected,
                    selectedColor: colorScheme.primary,
                    backgroundColor: colorScheme.surface,
                    checkmarkColor: colorScheme.onPrimary,
                    onSelected: isSubcategoryLoading
                        ? null // Disable button during loading
                        : (_) async {
                            await HapticService.selectionClick();

                            final newCategoryIds = List<int>.from(criteria.categoryIds);

                            if (subSelected) {
                              // Unselect this subcategory (and any of its children)
                              newCategoryIds.remove(subcategory.id);
                              final subcats = subcategories[subcategory.id] ?? [];
                              for (final subcat in subcats) {
                                newCategoryIds.remove(subcat.id);
                              }
                              context.read<FiltersBloc>().add(
                                FiltersSubcategoriesCleared(subcategory.id),
                              );
                            } else {
                              // UI selection model: keep both the parent category id
                              // AND the selected subcategory id in criteria.categoryIds
                              // so that chips / headers can show the full path.
                              //
                              // API model: when calling endpoints we ALWAYS pass only the
                              // deepest ids (subcategories) via _getDeepestCategoryIds /
                              // FilterCriteria.getDeepestCategoryIds, so parents are
                              // automatically removed before hitting the backend.
                              if (!newCategoryIds.contains(parentId)) {
                                newCategoryIds.add(parentId);
                              }
                              if (!newCategoryIds.contains(subcategory.id)) {
                                newCategoryIds.add(subcategory.id);
                              }
                            }
                            // Update selection + attributes FIRST so COLOR list changes immediately.
                            // _getDeepestCategoryIds will extract only subcategory IDs (excluding parent) for API call
                            await _onCategoryIdsChanged(context, criteria, newCategoryIds);

                            // Then load deeper levels in background (don’t block attribute refresh).
                            if (!subSelected && !_loadingCategoryIds.contains(subcategory.id)) {
                              // CRITICAL: Set loading state IMMEDIATELY (synchronously) to trigger widget rebuild
                              if (mounted) {
                                setState(() {
                                  _loadingCategoryIds.add(subcategory.id);
                                });
                              }
                              // ignore: unawaited_futures
                              _loadSubcategories(subcategory.id, blocContext: context);
                            }
                          },
                    disabledColor: colorScheme.surface.withValues(alpha: 0.5),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: subSelected
                            ? colorScheme.primary
                            : isSubcategoryLoading
                                ? colorScheme.outline.withValues(alpha: 0.4)
                                : colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              // Show shimmer for deeper levels when loading
              ...loadedSubcategories.expand((subcategory) {
                final childSubcategories = subcategories[subcategory.id] ?? subcategory.children;
                final isSubcategoryLoading = _loadingCategoryIds.contains(subcategory.id);

                // Show shimmer if loading and no children loaded yet
                if (isSubcategoryLoading && childSubcategories.isEmpty && subcategory.hasChildren) {
                  return [
                    Padding(
                      padding: EdgeInsets.only(
                        left: ResponsiveConstants.mdSpacing * (level + 1),
                        top: ResponsiveConstants.smSpacing,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Subcategory label shimmer
                          Shimmer.fromColors(
                            baseColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                            highlightColor: Theme.of(context).colorScheme.surface,
                            period: const Duration(milliseconds: 1200),
                            child: Container(
                              width: 100,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          SizedBox(height: ResponsiveConstants.xsSpacing),
                          // Subcategory chips shimmer
                          _buildSubcategoryShimmer(),
                        ],
                      ),
                    ),
                  ];
                }

                // Recursively build children if they exist
                if (childSubcategories.isNotEmpty || 
                    (isSubcategoryLoading && subcategory.hasChildren)) {
                  return _buildSubcategoryTree(
                    context,
                    criteria,
                    subcategory.id,
                    childSubcategories,
                    subcategories,
                    level + 1,
                  );
                }
                return <Widget>[];
              }),
            ],
          ],
        ),
      ),
    ];
  }

  /// Build shimmer loading widget for subcategories
  Widget _buildSubcategoryShimmer() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Shimmer.fromColors(
      baseColor: colorScheme.outline.withValues(alpha: 0.3),
      highlightColor: colorScheme.surface,
      period: const Duration(milliseconds: 1200),
      child: Wrap(
        spacing: ResponsiveConstants.xsSpacing,
        runSpacing: ResponsiveConstants.xsSpacing,
        children: List.generate(4, (index) {
          // Vary widths for more realistic loading
          final widths = [70.0, 90.0, 80.0, 100.0];
          return Container(
            width: widths[index % widths.length],
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
          );
        }),
      ),
    );
  }
}
