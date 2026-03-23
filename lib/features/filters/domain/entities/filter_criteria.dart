import 'package:equatable/equatable.dart';
import '../../../../core/services/brand_mapping_service.dart';

// Sentinel object to distinguish between "not provided" and "explicitly null"
const _undefined = Object();

class FilterCriteria extends Equatable {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final bool onSale;
  final bool inStock;
  final List<String> sizes;
  final List<String> colors;
  final List<String> materials;
  final List<String> seasons;
  final List<String> genders;
  final String? brand;
  final String? category;
  final List<int> categoryIds;
  final List<int> brandIds;
  final List<int> productIds;
  final List<int> attributeIds;
  final Map<String, List<String>> extraAttributes;
  final String? searchQuery;
  final int page;
  final int limit;
  /// When true (e.g. offer banner → filter-search), [toJson] omits `page` and `limit`
  /// so the request body only carries filter fields from the page component.
  final bool omitPaginationInRequest;
  // Backend sort params
  final String? sortByField; // e.g., 'list_price', 'create_date', 'name', 'sales_count'
  final String? sortOrder; // 'asc' | 'desc'

  const FilterCriteria({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.onSale = false,
    this.inStock = false,
    this.sizes = const [],
    this.colors = const [],
    this.materials = const [],
    this.seasons = const [],
    this.genders = const [],
    this.brand,
    this.category,
    this.categoryIds = const [],
    this.brandIds = const [],
    this.productIds = const [],
    this.attributeIds = const [],
    Map<String, List<String>> extraAttributes = const {},
    this.searchQuery,
    this.page = 1,
    this.limit = 20,
    this.omitPaginationInRequest = false,
    this.sortByField,
    this.sortOrder,
  }) : extraAttributes = extraAttributes;

  FilterCriteria copyWith({
    Object? minPrice = _undefined,
    Object? maxPrice = _undefined,
    Object? minRating = _undefined,
    bool? onSale,
    bool? inStock,
    List<String>? sizes,
    List<String>? colors,
    List<String>? materials,
    List<String>? seasons,
    List<String>? genders,
    Object? brand = _undefined,
    Object? category = _undefined,
    List<int>? categoryIds,
    List<int>? brandIds,
    List<int>? productIds,
    List<int>? attributeIds,
    Map<String, List<String>>? extraAttributes,
    Object? searchQuery = _undefined,
    int? page,
    int? limit,
    bool? omitPaginationInRequest,
    Object? sortByField = _undefined,
    Object? sortOrder = _undefined,
  }) {
    return FilterCriteria(
      minPrice: minPrice == _undefined ? this.minPrice : minPrice as double?,
      maxPrice: maxPrice == _undefined ? this.maxPrice : maxPrice as double?,
      minRating: minRating == _undefined ? this.minRating : minRating as double?,
      onSale: onSale ?? this.onSale,
      inStock: inStock ?? this.inStock,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      materials: materials ?? this.materials,
      seasons: seasons ?? this.seasons,
      genders: genders ?? this.genders,
      brand: brand == _undefined ? this.brand : brand as String?,
      category: category == _undefined ? this.category : category as String?,
      categoryIds: categoryIds ?? this.categoryIds,
      brandIds: brandIds ?? this.brandIds,
      productIds: productIds ?? this.productIds,
      attributeIds: attributeIds ?? this.attributeIds,
      extraAttributes: extraAttributes == null ? this.extraAttributes : _freezeAttributeMap(extraAttributes),
      searchQuery: searchQuery == _undefined ? this.searchQuery : searchQuery as String?,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      omitPaginationInRequest: omitPaginationInRequest ?? this.omitPaginationInRequest,
      sortByField: sortByField == _undefined ? this.sortByField : sortByField as String?,
      sortOrder: sortOrder == _undefined ? this.sortOrder : sortOrder as String?,
    );
  }

  /// Extract only the deepest (most specific) category IDs from the selected list.
  /// This removes parent category IDs when their children (at any level) are also selected.
  /// 
  /// Example:
  /// - If [556, 559] where 559 is a child of 556 → returns [559]
  /// - If [556] only → returns [556]
  /// - If [559, 560] where both are siblings → returns [559, 560]
  /// - If [554, 559, 600] where 554->559->600 → returns [600]
  List<int> getDeepestCategoryIds({
    Map<int, List<int>>? parentChildMap,
  }) {
    if (categoryIds.isEmpty) return [];
    if (parentChildMap == null || parentChildMap.isEmpty) {
      // If no hierarchy info, return all IDs (fallback behavior)
      return categoryIds;
    }
    
    // Build a set of all selected IDs for quick lookup
    final selectedSet = categoryIds.toSet();
    
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
    for (final categoryId in categoryIds) {
      if (!hasSelectedDescendant(categoryId, parentChildMap, selectedSet)) {
        // This category doesn't have any selected descendants, so it's a deepest level
        deepestIds.add(categoryId);
      }
    }
    
    return deepestIds;
  }

  Map<String, dynamic> toJson({
    Map<int, List<int>>? parentChildMap,
  }) {
    // Extract only deepest category IDs based on hierarchy
    // If parentChildMap is provided, use it to filter out parent IDs when children are selected
    // Otherwise, use categoryIds as-is (assuming they're already filtered)
    // CRITICAL: Always filter if parentChildMap is provided, even if categoryIds seems correct
    final deepestCategoryIds = (parentChildMap != null && parentChildMap.isNotEmpty)
        ? getDeepestCategoryIds(parentChildMap: parentChildMap)
        : categoryIds;
    
    // Final safety check: If we have multiple categoryIds but no parentChildMap,
    // log a warning (the safeguard in filterProducts should build parentChildMap)
    if (categoryIds.length > 1 && (parentChildMap == null || parentChildMap.isEmpty)) {
      print('⚠️ FilterCriteria.toJson(): Multiple categoryIds ($categoryIds) but no parentChildMap provided. Using as-is.');
      print('⚠️ This should not happen if _scheduleCountFetch or Apply Filters button worked correctly.');
    }
    
    print('🔍 FilterCriteria.toJson() - Category ID filtering:');
    print('   Original categoryIds: $categoryIds');
    print('   ParentChildMap provided: ${parentChildMap != null && parentChildMap.isNotEmpty}');
    if (parentChildMap != null && parentChildMap.isNotEmpty) {
      print('   ParentChildMap keys: ${parentChildMap.keys.toList()}');
      print('   ParentChildMap entries: ${parentChildMap.entries.map((e) => '${e.key} -> ${e.value}').join(', ')}');
    }
    print('   ⚡ Deepest categoryIds (will send): $deepestCategoryIds');
    print('   ⚡ VERIFICATION: Original had ${categoryIds.length} IDs, sending ${deepestCategoryIds.length} IDs');
    
    // Build params object according to API specification
    // Note: Endpoints.withParams will wrap this in a "params" object
    // When filtering (not searching), search_term should NOT be included
    final json = <String, dynamic>{
      // Pagination: omit for offer-only filter-search payloads
      if (!omitPaginationInRequest) ...{
        'page': page,
        'limit': limit,
      },
      // Backend expects category_ids as a list.
      // Send ONLY the deepest (most specific) selected category IDs
      if (deepestCategoryIds.isNotEmpty) 'category_ids': deepestCategoryIds,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (brandIds.isNotEmpty) 'brand_ids': brandIds,
      if (productIds.isNotEmpty) 'product_ids': productIds,
      if (attributeIds.isNotEmpty) 'attribute_values': attributeIds,
      // Stock filter: backend expects 'stock_filter' as string ('in_stock', 'out_of_stock', etc.)
      if (inStock) 'stock_filter': 'in_stock',
      // Only include search_term when it's actually a search (not a filter)
      // When filtering, search_term should be empty/null - do NOT include it
      if (searchQuery != null && searchQuery!.isNotEmpty) 'search_term': searchQuery,
      if (sortByField != null) 'sort_by': sortByField,
      if (sortOrder != null) 'sort_order': sortOrder,
    };
    
    // Print the request body when filters are applied
    print('📦 FilterCriteria.toJson() - Request Body:');
    print('   ==========================================');
    print('   Full JSON Body: $json');
    if (!omitPaginationInRequest) {
      print('   Page: $page, Limit: $limit');
    } else {
      print('   Page/Limit: omitted (omitPaginationInRequest=true)');
    }
    if (categoryIds.isNotEmpty) {
      print('   Category IDs (all selected): $categoryIds');
      print('   Deepest Category IDs (sent to API): $deepestCategoryIds');
    }
    if (brandIds.isNotEmpty) print('   Brand IDs: $brandIds');
    if (productIds.isNotEmpty) print('   Product IDs: $productIds');
    if (attributeIds.isNotEmpty) print('   Attribute Values (IDs): $attributeIds');
    if (minPrice != null) print('   Min Price: $minPrice');
    if (maxPrice != null) print('   Max Price: $maxPrice');
    if (inStock) print('   Stock Filter: in_stock');
    if (searchQuery != null && searchQuery!.isNotEmpty) print('   Search Query: $searchQuery');
    if (sortByField != null) print('   Sort By: $sortByField, Order: $sortOrder');
    print('   ==========================================');
    
    return json;
  }

  /// Factory method to create FilterCriteria from catalog parameters
  /// Create FilterCriteria with dynamic brand mapping (async)
  static Future<FilterCriteria> fromCatalogParamsAsync({
    required int page,
    required int pageSize,
    String? category,
    String? categoryId,
    String? brand,
    String? sortBy,
    String? query,
    bool featured = false,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool onSale = false,
    bool inStock = false,
    List<String> sizes = const [],
    List<String> colors = const [],
    List<String> materials = const [],
    List<String> seasons = const [],
    List<String> genders = const [],
    Map<String, List<String>> extraAttributes = const {},
  }) async {
    List<int> categoryIds = [];
    if (categoryId != null && categoryId.isNotEmpty) {
      categoryIds = [int.parse(categoryId)];
    }

    // Use dynamic brand mapping service
    List<int> brandIds = [];
    if (brand != null && brand != 'All' && brand.isNotEmpty) {
      print('🏷️ FilterCriteria: Getting dynamic brand ID for "$brand"...');
      try {
        final brandId = await BrandMappingService().getBrandId(brand);
        if (brandId != null) {
          brandIds = [brandId];
          print('✅ FilterCriteria: Brand "$brand" mapped to ID: $brandId');
        } else {
          print('⚠️ FilterCriteria: Brand "$brand" not found in API, brandIds will be empty');
        }
      } catch (e) {
        print('❌ FilterCriteria: Error getting brand ID for "$brand": $e');
        // Fallback to static mapping based on API response
        final staticBrandMap = {
          'Herman Miller': 6, // Based on API response
          'Nike': 1, 'Adidas': 2, 'Levis': 3, 'Zara': 4, 'H&M': 5,
        };
        final staticBrandId = staticBrandMap[brand];
        if (staticBrandId != null) {
          brandIds = [staticBrandId];
          print('✅ FilterCriteria: Using static mapping for "$brand" → ID: $staticBrandId');
        }
      }
    }

    // Map attribute values (sizes, colors, etc.) to attribute IDs
    List<int> attributeValues = [];
    
    // Map colors to attribute IDs based on API response structure
    // From the API response: Color attribute has values with IDs 3 (White), 4 (Black)
    if (colors.isNotEmpty) {
      final colorMap = {
        'White': 3, 'Black': 4, 'Blue': 5, 'Red': 6, 'Green': 7,
        'Yellow': 8, 'Pink': 9, 'Brown': 10, 'Grey': 11, 'Orange': 12,
        'Purple': 13, 'Navy': 14, 'Beige': 15, 'Khaki': 16, 'Maroon': 17,
      };
      
      for (final color in colors) {
        if (color != 'All') {
          final colorId = colorMap[color];
          if (colorId != null) {
            attributeValues.add(colorId);
          }
        }
      }
    }
    
    // Map sizes to attribute IDs based on API response structure
    // From the API response: Legs attribute has values with IDs 1 (Steel), 2 (Aluminium), 7 (Custom)
    if (sizes.isNotEmpty) {
      final sizeMap = {
        'XS': 20, 'S': 21, 'M': 22, 'L': 23, 'XL': 24, 'XXL': 25,
        '6': 26, '7': 27, '8': 28, '9': 29, '10': 30, '11': 31, '12': 32,
        'Steel': 1, 'Aluminium': 2, 'Custom': 7, // For furniture legs
      };
      
      for (final size in sizes) {
        final sizeId = sizeMap[size];
        if (sizeId != null) {
          attributeValues.add(sizeId);
        }
      }
    }

    // Map sort label to API params
    final mapped = _mapSortLabelToApi(sortBy);

    return FilterCriteria(
      page: page,
      limit: pageSize,
      categoryIds: categoryIds,
      brandIds: brandIds,
      attributeIds: attributeValues,
      searchQuery: query,
      minPrice: minPrice,
      maxPrice: maxPrice,
      inStock: inStock,
      sizes: sizes,
      colors: colors,
      materials: materials,
      seasons: seasons,
      genders: genders,
      brand: brand,
      category: category,
      sortByField: mapped.$1,
      sortOrder: mapped.$2,
      extraAttributes: extraAttributes,
    );
  }

  factory FilterCriteria.fromCatalogParams({
    required int page,
    required int pageSize,
    String? category,
    String? categoryId,
    String? brand,
    String? sortBy,
    String? query,
    bool featured = false,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool onSale = false,
    bool inStock = false,
    List<String> sizes = const [],
    List<String> colors = const [],
    List<String> materials = const [],
    List<String> seasons = const [],
    List<String> genders = const [],
    Map<String, List<String>> extraAttributes = const {},
  }) {
    List<int> categoryIds = [];
    if (categoryId != null && categoryId.isNotEmpty) {
      categoryIds = [int.parse(categoryId)];
    }

    // Map brand name to brand ID 
    List<int> brandIds = [];
    if (brand != null && brand != 'All' && brand.isNotEmpty) {
      print('🏷️ FilterCriteria: Mapping brand "$brand" to ID...');
      
      // Updated mapping to include furniture brands from your catalog
      final brandMap = {
        'Nike': 1,
        'Adidas': 2,
        'Levis': 3,
        'Zara': 4,
        'H&M': 5,
        'Uniqlo': 6,
        'Gap': 7,
        'Calvin Klein': 8,
        'Tommy Hilfiger': 9,
        'Ralph Lauren': 10,
        'Herman Miller': 11,
        'IKEA': 12,
        'West Elm': 13,
        'CB2': 14,
        'Pottery Barn': 15,
        'Crate & Barrel': 16,
        'Room & Board': 17,
        'Design Within Reach': 18,
        'Knoll': 19,
        'Steelcase': 20,
      };
      final brandId = brandMap[brand];
      if (brandId != null) {
        brandIds = [brandId];
        print('✅ FilterCriteria: Brand "$brand" mapped to ID: $brandId');
      } else {
        print('⚠️ FilterCriteria: Brand "$brand" not found in mapping, brandIds will be empty');
        print('📋 Available brands: ${brandMap.keys.join(', ')}');
      }
    }

    // Map attribute values (sizes, colors, etc.) to attribute IDs
    List<int> attributeValues = [];
    
    // Map colors to attribute IDs based on API response structure
    if (colors.isNotEmpty) {
      final colorMap = {
        'White': 3, 'Black': 4, 'Blue': 5, 'Red': 6, 'Green': 7,
        'Yellow': 8, 'Pink': 9, 'Brown': 10, 'Grey': 11, 'Orange': 12,
        'Purple': 13, 'Navy': 14, 'Beige': 15, 'Khaki': 16, 'Maroon': 17,
      };
      
      for (final color in colors) {
        if (color != 'All') {
          final colorId = colorMap[color];
          if (colorId != null) {
            attributeValues.add(colorId);
          }
        }
      }
    }
    
    // Map sizes to attribute IDs based on API response structure
    if (sizes.isNotEmpty) {
      final sizeMap = {
        'XS': 20, 'S': 21, 'M': 22, 'L': 23, 'XL': 24, 'XXL': 25,
        '6': 26, '7': 27, '8': 28, '9': 29, '10': 30, '11': 31, '12': 32,
        'Steel': 1, 'Aluminium': 2, 'Custom': 7, // For furniture legs
      };
      
      for (final size in sizes) {
        final sizeId = sizeMap[size];
        if (sizeId != null) {
          attributeValues.add(sizeId);
        }
      }
    }

    final mapped = _mapSortLabelToApi(sortBy);
    return FilterCriteria(
      page: page,
      limit: pageSize,
      categoryIds: categoryIds,
      brandIds: brandIds,
      attributeIds: attributeValues,
      searchQuery: query,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      onSale: onSale,
      inStock: inStock,
      sizes: sizes,
      colors: colors,
      materials: materials,
      seasons: seasons,
      genders: genders,
      brand: brand,
      category: category,
      sortByField: mapped.$1,
      sortOrder: mapped.$2,
      extraAttributes: extraAttributes,
    );
  }

  // Returns (sort_by, sort_order) from sort option ID
  // The sortOptionId should be the ID from FilterSortOption (e.g., 'price_low_high', 'newest_first')
  static (String?, String?) _mapSortLabelToApi(String? sortOptionId) {
    if (sortOptionId == null) return ('create_date', 'desc');
    final id = sortOptionId.toLowerCase();
    
    // Map sort option IDs to field and order
    // These match the IDs from the API sorting_options
    switch (id) {
      case 'price_low_high':
        return ('list_price', 'asc');
      case 'price_high_low':
        return ('list_price', 'desc');
      case 'newest_first':
        return ('create_date', 'desc');
      case 'oldest_first':
        return ('create_date', 'asc');
      case 'name_asc':
        return ('name', 'asc');
      case 'name_desc':
        return ('name', 'desc');
      case 'best_selling':
        return ('sales_count', 'desc');
      default:
        // Fallback for legacy labels
        if (id.contains('price') && id.contains('high to low')) {
          return ('list_price', 'desc');
        }
        if (id.contains('price') && id.contains('low to high')) {
          return ('list_price', 'asc');
        }
        if (id.contains('newest') || id.contains('new')) {
          return ('create_date', 'desc');
        }
        if (id.contains('oldest')) {
          return ('create_date', 'asc');
        }
        if (id.contains('name') && id.contains('a to z')) {
          return ('name', 'asc');
        }
        if (id.contains('name') && id.contains('z to a')) {
          return ('name', 'desc');
        }
        // Default
        return ('create_date', 'desc');
    }
  }
  
  // Helper method to create FilterCriteria with sort option from API
  static (String?, String?) mapSortOptionIdToApi(String? sortOptionId) {
    return _mapSortLabelToApi(sortOptionId);
  }

  @override
  List<Object?> get props => [
        minPrice,
        maxPrice,
        minRating,
        onSale,
        inStock,
        sizes,
        colors,
        materials,
        seasons,
        genders,
        brand,
        category,
        categoryIds,
        brandIds,
        productIds,
        attributeIds,
        extraAttributes,
        searchQuery,
        page,
        limit,
        omitPaginationInRequest,
        sortByField,
        sortOrder,
      ];
}

Map<String, List<String>> _freezeAttributeMap(Map<String, List<String>> source) {
  if (source.isEmpty) return const {};
  final copy = <String, List<String>>{};
  for (final entry in source.entries) {
    copy[entry.key] = List.unmodifiable(entry.value);
  }
  return Map.unmodifiable(copy);
}


