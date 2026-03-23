import 'dart:collection';
import '../../domain/entities/paginated_products.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../home/domain/entities/product.dart' as HomeProduct;
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/domain/entities/product.dart' as ProductEntity;
import '../../../product/domain/entities/product_category.dart';
import '../../../filters/domain/entities/filter_criteria.dart';
import '../../../filters/data/datasources/filter_remote_data_source.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../../../core/services/language_service.dart';
import '../catalog_products_isolate.dart';

// Repository that uses real APIs for product and category data
class CatalogRepositoryImpl implements CatalogRepository {
  final HomeRepository homeRepository;
  final ProductRepository productRepository;
  final FilterRemoteDataSource filterRemoteDataSource;
  final Map<String, PaginatedProducts> _cache = HashMap();

  CatalogRepositoryImpl({
    required this.homeRepository,
    required this.productRepository,
    required this.filterRemoteDataSource,
  });

  @override
  void clearCache() {
    _cache.clear();
    print('🧹 CatalogRepository: Cleared in-memory catalog cache');
  }

  /// Constructs full image URL from relative path
  /// Uses ImageCacheUtils.normalizeImageUrl to fix double slashes
  String _constructImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    // Use normalizeImageUrl to fix double slashes and ensure proper URL construction
    return ImageCacheUtils.normalizeImageUrl(imagePath);
  }

  @override
  Future<PaginatedProducts> fetchProducts({
    required int page,
    required int pageSize,
    String? category,
    String? categoryId,
    List<int>? categoryIds, // Support multiple category IDs from filter page
    String? brand,
    List<int>? brandIds, // Support brand IDs directly from filter page
    String? sortBy,
    String? sortByField, // Direct sort field from FilterCriteria
    String? sortOrder, // Direct sort order from FilterCriteria
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
    // Include current API language in the cache key so that when the user
    // switches language (and we update Accept-Language via LanguageService),
    // we do NOT reuse product lists fetched in the previous language.
    //
    // This keeps concerns separated:
    // - ApiClient is responsible for headers / language on the wire
    // - CatalogRepository is responsible for in-memory product caching
    //   and must treat each language as an independent cache namespace.
    final lang = await LanguageService().getApiLanguageCode() ?? 'default';

    // Check if any advanced filters are applied
    // If categoryIds are provided from filter page, always use filter-search API
    // Also check if any filter attributes are selected (colors, sizes, etc.)
    final hasAdvancedFilters = (categoryIds != null && categoryIds.isNotEmpty) || // From filter page
        (brand != null && brand != 'All') ||
        minPrice != null || maxPrice != null || minRating != null ||
        onSale || inStock || sizes.isNotEmpty || colors.isNotEmpty ||
        materials.isNotEmpty || seasons.isNotEmpty || genders.isNotEmpty ||
        extraAttributes.isNotEmpty;
    
    print('🔍 CatalogRepository.fetchProducts: hasAdvancedFilters=$hasAdvancedFilters (lang=$lang)');
    print('   categoryIds: $categoryIds');
    print('   colors: $colors, sizes: $sizes, materials: $materials');
    
    // Use filter-search API when advanced filters are applied
    if (hasAdvancedFilters) {
      print('🔄 CatalogRepository: Using filter-search API due to advanced filters');
      // Clear cache when filters are applied to ensure fresh results
      _cache.clear();
      return fetchProductsWithFilterSearch(
        page: page,
        pageSize: pageSize,
        category: category,
        categoryId: categoryId,
        categoryIds: categoryIds,
        brand: brand,
        brandIds: brandIds,
        sortBy: sortBy,
        sortByField: sortByField,
        sortOrder: sortOrder,
        query: query,
        featured: featured,
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
        extraAttributes: extraAttributes,
      );
    }

    // IMPORTANT: Namespace cache by current API language so that
    // opening the same catalog page after a language change always
    // triggers a fresh API call instead of reusing the old-language
    // product list from memory.
    final cacheKey = '${lang}_${page}_${pageSize}_${category ?? ''}_${brand ?? ''}_${sortBy ?? ''}_${query ?? ''}_${featured}_${minPrice ?? ''}_${maxPrice ?? ''}_${minRating ?? ''}_${onSale}_${inStock}_${sizes.join(',')}_${colors.join(',')}_${materials.join(',')}_${seasons.join(',')}_${genders.join(',')}';
    print('🔍 CatalogRepository: Cache key: $cacheKey');
    if (_cache.containsKey(cacheKey)) {
      print('📦 CatalogRepository: Using cached results');
      return _cache[cacheKey]!;
    }

    try {
      // Prioritize categoryIds if provided (from filter page), then categoryId
      if (categoryIds != null && categoryIds.isNotEmpty) {
        // Use categoryIds from filter page with real pagination
        print('🔍 CatalogRepository: Fetching products for categoryIds: $categoryIds (page=$page, size=$pageSize)');
        final result = await productRepository.getProductsByCategory(
          categoryIds: categoryIds,
          limit: pageSize,
          offset: (page - 1) * pageSize,
        );
        return result.fold<PaginatedProducts>(
          (failure) {
            print('❌ CatalogRepository: API call failed: ${failure.toString()}');
            return PaginatedProducts(
              items: [],
              page: page,
              pageSize: pageSize,
              hasMore: false,
              totalCount: 0,
            );
          }, 
          (r) {
            print('✅ CatalogRepository: API call successful, got ${r.products.length} products, totalCount: ${r.totalCount}');
            final items = r.products.map((productEntity) => _convertToHomeProduct(productEntity)).toList();
            return PaginatedProducts(
              items: items,
              page: page,
              pageSize: pageSize,
              hasMore: r.hasMore,
              totalCount: r.totalCount, // Use actual totalCount from API
            );
          }
        );
      } else if (categoryId != null && categoryId.isNotEmpty) {
        // Prioritize category-based API with real pagination
        print('🔍 CatalogRepository: Fetching products for categoryId: $categoryId (page=$page, size=$pageSize)');
        final result = await productRepository.getProductsByCategory(
          categoryIds: [int.parse(categoryId)],
          limit: pageSize,
          offset: (page - 1) * pageSize,
        );
        return result.fold<PaginatedProducts>(
          (failure) {
            print('❌ CatalogRepository: API call failed: ${failure.toString()}');
            return PaginatedProducts(
              items: [],
              page: page,
              pageSize: pageSize,
              hasMore: false,
              totalCount: 0,
            );
          }, 
          (r) {
            print('✅ CatalogRepository: API call successful, got ${r.products.length} products, totalCount: ${r.totalCount}');
            final items = r.products.map((productEntity) => _convertToHomeProduct(productEntity)).toList();
            return PaginatedProducts(
              items: items,
              page: page,
              pageSize: pageSize,
              hasMore: r.hasMore,
              totalCount: r.totalCount, // Use actual totalCount from API
            );
          }
        );
      } else if (query != null && query.isNotEmpty) {
        // Use filter-search API for query-based searches to align with backend behavior
        print('🔍 CatalogRepository: Using filter-search for query: $query');
        final filterResp = await fetchProductsWithFilterSearch(
          page: page,
          pageSize: pageSize,
          category: category,
          categoryId: categoryId,
          categoryIds: categoryIds,
          brand: brand,
          sortBy: 'create_date_desc', // align with Postman: sort_by create_date desc
          query: query,
          featured: featured,
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
          extraAttributes: extraAttributes,
        );
        return filterResp;
      } else if (category != null && category != 'All') {
        // Fallback: Use category name to find ID (for backward compatibility) with pagination
        final result = await productRepository.getProductsByCategory(
          categoryIds: await _getCategoryIdsByName(category),
          limit: pageSize,
          offset: (page - 1) * pageSize,
        );
        return result.fold<PaginatedProducts>(
          (failure) {
            print('❌ CatalogRepository: API call failed: ${failure.toString()}');
            return PaginatedProducts(
              items: [],
              page: page,
              pageSize: pageSize,
              hasMore: false,
              totalCount: 0,
            );
          },
          (r) {
            print('✅ CatalogRepository: API call successful, got ${r.products.length} products, totalCount: ${r.totalCount}');
            final items = r.products.map((productEntity) => _convertToHomeProduct(productEntity)).toList();
            final pageResp = PaginatedProducts(
              items: items,
              page: page,
              pageSize: pageSize,
              hasMore: r.hasMore,
              totalCount: r.totalCount, // Use actual totalCount from API
            );
            _cache[cacheKey] = pageResp;
            return pageResp;
          }
        );
      } else {
        // Use general product list API with pagination
        final result = await productRepository.getProductList(
          limit: pageSize,
          offset: (page - 1) * pageSize,
        );
        return result.fold<PaginatedProducts>(
          (failure) {
            print('❌ CatalogRepository: API call failed: ${failure.toString()}');
            return PaginatedProducts(
              items: [],
              page: page,
              pageSize: pageSize,
              hasMore: false,
              totalCount: 0,
            );
          },
          (r) {
            print('✅ CatalogRepository: API call successful, got ${r.products.length} products, totalCount: ${r.totalCount}');
            final items = r.products.map((productEntity) => _convertToHomeProduct(productEntity)).toList();
            final pageResp = PaginatedProducts(
              items: items,
              page: page,
              pageSize: pageSize,
              hasMore: r.hasMore,
              totalCount: r.totalCount, // Use actual totalCount from API
            );
            _cache[cacheKey] = pageResp;
            return pageResp;
          }
        );
      }
    } catch (e) {
      // Fallback to empty result on error
      return PaginatedProducts(
        items: [],
        page: page,
        pageSize: pageSize,
        hasMore: false,
        totalCount: 0,
      );
    }
  }

  /// Method to use filter-search API specifically for advanced filtering
  /// This is an additional option, not a replacement for the main fetchProducts method
  Future<PaginatedProducts> fetchProductsWithFilterSearch({
    required int page,
    required int pageSize,
    String? category,
    String? categoryId,
    List<int>? categoryIds, // Support multiple category IDs from filter page
    String? brand,
    List<int>? brandIds, // Support brand IDs directly from filter page (preserves original selection)
    String? sortBy,
    String? sortByField, // Direct sort field from FilterCriteria
    String? sortOrder, // Direct sort order from FilterCriteria
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
    try {
      print('🔍 CatalogRepository: Using filter-search API with params: page=$page, pageSize=$pageSize, categoryId=$categoryId, query=$query');
      
      // Create FilterCriteria from catalog parameters with dynamic brand mapping
      // Use categoryIds if provided (from filter page), otherwise use categoryId
      List<int> finalCategoryIds = categoryIds ?? [];
      if (finalCategoryIds.isEmpty && categoryId != null && categoryId.isNotEmpty) {
        finalCategoryIds = [int.parse(categoryId)];
      }
      
      final filterCriteria = await FilterCriteria.fromCatalogParamsAsync(
        page: page,
        pageSize: pageSize,
        category: category,
        categoryId: categoryId,
        brand: brand,
        sortBy: sortBy, // This is the sort option ID (e.g., 'price_low_high'), will be mapped to field/order
        query: query,
        featured: featured,
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
        extraAttributes: extraAttributes,
      );
      
      // Override with values from FilterCriteria if provided directly (preserves original selections)
      FilterCriteria effectiveCriteria = filterCriteria;
      if (finalCategoryIds.isNotEmpty) {
        effectiveCriteria = effectiveCriteria.copyWith(categoryIds: finalCategoryIds);
        print('📋 CatalogRepository: Using categoryIds from filter: $finalCategoryIds');
      }
      
      // IMPORTANT: Preserve limit from pageSize parameter (this comes from FilterCriteria.limit if provided)
      // The pageSize parameter should reflect the limit from FilterCriteria
      effectiveCriteria = effectiveCriteria.copyWith(limit: pageSize);
      print('📋 CatalogRepository: Setting limit to pageSize: $pageSize (from FilterCriteria if provided)');
      
      // Log sort parameters
      print('📋 CatalogRepository: Sort params - sortByField: ${effectiveCriteria.sortByField}, sortOrder: ${effectiveCriteria.sortOrder}');

      // Map selections to backend IDs dynamically from attributes API
      // Preserve categoryIds and extraAttributes
      effectiveCriteria = effectiveCriteria.copyWith(extraAttributes: extraAttributes);
      
      // Initialize attributeIds with any existing ones (do NOT add categoryIds here)
      // Category IDs should only be sent in category_ids field, not attribute_values
      Set<int> attributeIds = {...effectiveCriteria.attributeIds};

      // Determine whether we actually need attributes/brands mapping for this call.
      final bool hasValueFilters =
          colors.isNotEmpty ||
          materials.isNotEmpty ||
          sizes.isNotEmpty ||
          seasons.isNotEmpty ||
          genders.isNotEmpty ||
          extraAttributes.isNotEmpty;

      // Start from any explicit brandIds / criteria.brandIds
      List<int>? finalBrandIds =
          brandIds ?? (effectiveCriteria.brandIds.isNotEmpty ? effectiveCriteria.brandIds : null);

      final bool needsBrandMappingFromName =
          (finalBrandIds == null || finalBrandIds.isEmpty) &&
          (brand != null && brand != 'All');

      if (hasValueFilters || needsBrandMappingFromName) {
        try {
          final attrs = await filterRemoteDataSource.getAttributes(page: 1, limit: 200);
          // Build a reverse lookup for ALL attribute values: name(lowercased) -> id
          final Map<String, int> valueNameToId = {};
          for (final a in attrs) {
            for (final v in a.values) {
              final key = v.name.trim().toLowerCase();
              if (key.isNotEmpty) valueNameToId[key] = v.id;
            }
          }

          // Collect all selected values across supported groups (extensible)
          final Set<String> selectedValues = {
            ...colors.map((e) => e.trim().toLowerCase()),
            ...materials.map((e) => e.trim().toLowerCase()),
            ...sizes.map((e) => e.trim().toLowerCase()),
            ...seasons.map((e) => e.trim().toLowerCase()),
            ...genders.map((e) => e.trim().toLowerCase()),
          }..removeWhere((e) => e.isEmpty || e == 'all');
          for (final entry in extraAttributes.values) {
            for (final val in entry) {
              final normalized = val.trim().toLowerCase();
              if (normalized.isNotEmpty && normalized != 'all') {
                selectedValues.add(normalized);
              }
            }
          }

          // Map selected values to attribute IDs
          for (final val in selectedValues) {
            final id = valueNameToId[val];
            if (id != null) attributeIds.add(id);
          }

          // Set brandIds - preserve from parameter if provided (from filter page),
          // otherwise try to map from brand string using brands API / attributes.
          if (finalBrandIds == null || finalBrandIds.isEmpty) {
            if (needsBrandMappingFromName) {
              try {
                // Fetch all pages to ensure we can find the brand (some pages omit brands like VIZZANO)
                int page = 1;
                final List<dynamic> collected = [];
                while (true) {
                  final pageBrands =
                      await filterRemoteDataSource.getBrands(page: page, limit: 200);
                  if (pageBrands.isEmpty) break;
                  collected.addAll(pageBrands);
                  // Stop if fewer than limit returned (no has_next flag on this path), or reached safety cap
                  if (pageBrands.length < 200 || page >= 10) break;
                  page += 1;
                }
                final match = collected.cast<dynamic>().firstWhere(
                      (b) =>
                          (b.name as String).trim().toLowerCase() ==
                          brand!.trim().toLowerCase(),
                      orElse: () => null,
                    );
                if (match != null && match.id is int && match.id > 0) {
                  finalBrandIds = [match.id as int];
                } else {
                  // Fallback: try attributes BRAND values map
                  final brandAttrId = valueNameToId[brand!.trim().toLowerCase()];
                  if (brandAttrId != null) {
                    finalBrandIds = [brandAttrId];
                  } else {
                    // Ensure we do not pass a stale/wrong brand id
                    finalBrandIds = [];
                    print(
                        '⚠️ CatalogRepository: Brand "$brand" not found in brands API or attributes; omitting brand_ids');
                  }
                }
              } catch (_) {}
            }
          } else {
            print(
                '✅ CatalogRepository: Using brandIds directly from filter page: $finalBrandIds');
          }

          // Preserve sort parameters if provided directly
          final finalSortByField = sortByField ?? effectiveCriteria.sortByField;
          final finalSortOrder = sortOrder ?? effectiveCriteria.sortOrder;

          effectiveCriteria = effectiveCriteria.copyWith(
            attributeIds: attributeIds.toList(),
            brandIds: finalBrandIds ?? [],
            sortByField: finalSortByField,
            sortOrder: finalSortOrder,
          );

          print('📋 CatalogRepository: Final filter criteria before API call:');
          print('   ==========================================');
          print('   Category IDs: ${effectiveCriteria.categoryIds}');
          print('   Brand IDs: ${effectiveCriteria.brandIds}');
          print('   Attribute Values (IDs): ${effectiveCriteria.attributeIds}');
          print('   Price Range: ${effectiveCriteria.minPrice} - ${effectiveCriteria.maxPrice}');
          print('   Search Query: ${effectiveCriteria.searchQuery ?? "null"}');
          print('   Sort: ${effectiveCriteria.sortByField} (${effectiveCriteria.sortOrder})');
          print('   Pagination: page=${effectiveCriteria.page}, limit=${effectiveCriteria.limit}');
          print('   ==========================================');
        } catch (e) {
          print('⚠️ CatalogRepository: Failed to build dynamic attribute/brand IDs: $e');
          // Category IDs are already in effectiveCriteria.categoryIds and will be sent in category_ids field
          // No need to add them to attribute_values
        }
      } else {
        // No value filters and no need to derive brandIds; just normalize brandIds list.
        finalBrandIds = finalBrandIds ?? [];

        // Preserve sort parameters if provided directly
        final finalSortByField = sortByField ?? effectiveCriteria.sortByField;
        final finalSortOrder = sortOrder ?? effectiveCriteria.sortOrder;

        effectiveCriteria = effectiveCriteria.copyWith(
          attributeIds: attributeIds.toList(),
          brandIds: finalBrandIds,
          sortByField: finalSortByField,
          sortOrder: finalSortOrder,
        );
      }

      // Call the filter-search API
      print('🚀 CatalogRepository: Calling filter-search API...');
      print('   The request body will be printed by FilterCriteria.toJson() and FilterRemoteDataSource');
      final filterResponse = await filterRemoteDataSource.filterProducts(effectiveCriteria);
      
      // Parse the API response
      final result = filterResponse['result'] as Map<String, dynamic>;
      final data = result['data'] as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      final totalCount = data['total_count'] as int;
      final currentPage = data['current_page'] as int;
      final hasNext = data['has_next'] as bool;

      print('✅ CatalogRepository: API response - ${items.length} products, total: $totalCount, hasNext: $hasNext');

      // Convert API response items to HomeProduct.Product on a background isolate
      final products = await parseCatalogProductsInBackground(items);

      // Apply post-processing filters that the API doesn't support
      List<HomeProduct.Product> filtered = products.where((p) {
        final ratingOk = (minRating == null || p.rating >= minRating);
        final saleOk = !onSale || p.hasDiscount;
        final sizesOk = sizes.isEmpty || p.sizes.any((s) => sizes.contains(s));
        return ratingOk && saleOk && sizesOk;
      }).toList();

      return PaginatedProducts(
        items: filtered,
        page: currentPage,
        pageSize: effectiveCriteria.limit,
        hasMore: hasNext,
        totalCount: totalCount,
      );
    } catch (e) {
      print('❌ CatalogRepository: Error in fetchProductsWithFilterSearch: $e');
      rethrow;
    }
  }

  @override
  Future<PaginatedProducts> fetchProductsWithFilterCriteria({
    required FilterCriteria criteria,
  }) async {
    try {
      print('✅✅✅ CatalogRepository.fetchProductsWithFilterCriteria: Using FilterCriteria directly (NO MODIFICATIONS) ✅✅✅');
      print('   ==========================================');
      print('   Category IDs: ${criteria.categoryIds}');
      print('   Brand IDs: ${criteria.brandIds}');
      print('   Product IDs: ${criteria.productIds}');
      print('   Attribute Values (IDs): ${criteria.attributeIds}');
      print('   Price Range: ${criteria.minPrice} - ${criteria.maxPrice}');
      print('   Search Query: ${criteria.searchQuery ?? "null"}');
      print('   Sort: ${criteria.sortByField} (${criteria.sortOrder})');
      print('   Pagination: page=${criteria.page}, limit=${criteria.limit}');
      print('   ==========================================');
      print('   ⚠️ IMPORTANT: This FilterCriteria will be sent AS-IS to the API');
      print('   ⚠️ NO modifications will be made to limit, sort, or any other fields');
      print('   ==========================================');
      
      // Call the filter-search API directly with the FilterCriteria - NO MODIFICATIONS
      // This is the critical point - the FilterCriteria object is passed directly without any changes
      final filterResponse = await filterRemoteDataSource.filterProducts(criteria);
      
      // Parse the API response
      final result = filterResponse['result'] as Map<String, dynamic>;
      final data = result['data'] as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      final totalCount = data['total_count'] as int;
      final currentPage = data['current_page'] as int;
      final hasNext = data['has_next'] as bool;

      print('✅ CatalogRepository: API response - ${items.length} products, total: $totalCount, hasNext: $hasNext');

      // Convert API response items to HomeProduct.Product on a background isolate
      final products = await parseCatalogProductsInBackground(items);

      // Apply post-processing filters that the API doesn't support
      List<HomeProduct.Product> filtered = products.where((p) {
        final ratingOk = (criteria.minRating == null || p.rating >= criteria.minRating!);
        final saleOk = !criteria.onSale || p.hasDiscount;
        final sizesOk = criteria.sizes.isEmpty || p.sizes.any((s) => criteria.sizes.contains(s));
        return ratingOk && saleOk && sizesOk;
      }).toList();

      final effectivePageSize = criteria.omitPaginationInRequest
          ? (filtered.isEmpty ? totalCount : filtered.length)
          : criteria.limit;

      return PaginatedProducts(
        items: filtered,
        page: currentPage,
        pageSize: effectivePageSize,
        hasMore: hasNext,
        totalCount: totalCount,
      );
    } catch (e) {
      print('❌ CatalogRepository: Error in fetchProductsWithFilterCriteria: $e');
      rethrow;
    }
  }

  /// Helper method to find category IDs by name (including nested categories)
  Future<List<int>> _getCategoryIdsByName(String categoryName) async {
    try {
      final categoriesResult = await productRepository.getRootCategories(maxDepth: 3);
      final categories = categoriesResult.fold<List<ProductCategory>>((_) => [], (r) => r);
      
      final foundCategory = _findCategoryByName(categories, categoryName);
      return foundCategory != null ? [foundCategory.id] : [];
    } catch (e) {
      return [];
    }
  }

  ProductCategory? _findCategoryByName(List<ProductCategory> categories, String name) {
    for (final category in categories) {
      if (category.name.toLowerCase() == name.toLowerCase()) {
        return category;
      }
      // Recursively check children
      final found = _findCategoryByName(category.children, name);
      if (found != null) return found;
    }
    return null;
  }

  /// Convert API response item to HomeProduct.Product
  HomeProduct.Product _convertFromApiResponse(Map<String, dynamic> item) {
    // Extract images and construct full URLs based on product type and variant_id
    final images = <String>[];
    final productType = item['type'] as String? ?? 'variant';
    final productId = item['id']?.toString() ?? '';
    
    // Build variant_id to color mapping from variant_combinations
    final Map<String, String> variantIdToColor = {};
    final Map<String, String> canonicalVariantIdByColor = {};
    final variantCombinations = item['variant_combinations'] as List<dynamic>? ?? [];
    
    for (final v in variantCombinations) {
      if (v is Map<String, dynamic>) {
        final variantId = (v['variant_id'] ?? '').toString();
        String? colorName;
        final attrs = (v['attributes'] as List<dynamic>? ?? const []);
        for (final a in attrs) {
          if (a is Map<String, dynamic>) {
            final attrName = (a['attribute_name'] ?? '').toString().toLowerCase();
            if (attrName == 'color' || attrName == 'colour' || attrName == 'اللون' || attrName == 'color name') {
              colorName = (a['value_name'] ?? '').toString();
              break;
            }
          }
        }
        if (variantId.isNotEmpty && colorName != null && colorName.isNotEmpty) {
          variantIdToColor[variantId] = colorName;
          // First variant encountered for a color becomes the canonical one
          canonicalVariantIdByColor.putIfAbsent(colorName, () => variantId);
        }
      }
    }
    
    // Build color to images mapping
    final Map<String, List<String>> colorToImages = {};
    String? templateImage;
    // Keep separate variant/template buckets so we can merge them with
    // variant images first, then template images for catalog product cards.
    final List<String> variantImages = [];
    final List<String> templateImages = [];
    
    if (item['images'] != null && (item['images'] as List).isNotEmpty) {
      final imagesList = item['images'] as List<dynamic>;

      // Handle two API response formats:
      // 1. New format: images array with objects containing 'image' field (no 'type' field)
      // 2. Old format: images array with objects containing 'type', 'variant_id', 'url' fields
      
      bool hasTypeField = false;
      if (imagesList.isNotEmpty && imagesList.first is Map<String, dynamic>) {
        hasTypeField = (imagesList.first as Map<String, dynamic>).containsKey('type');
      }
      
      if (hasTypeField) {
        // Typed format: handle images that carry both `type` and `variant_id`
        for (final img in imagesList) {
          if (img is! Map<String, dynamic>) continue;
          
          final imagePath = (img['url'] as String?) ?? (img['image'] as String?);
          if (imagePath == null || imagePath.isEmpty) continue;
          
          final imageUrl = _constructImageUrl(imagePath);
          if (imageUrl.isEmpty) continue;
          
          final imageType = (img['type'] ?? '').toString().toLowerCase();
          final variantId = (img['variant_id'] ?? '').toString();

          // Classify into variant‑scoped vs template‑scoped buckets.
          final bool isVariantScopedImage =
              imageType == 'variant' ||
              imageType == 'variant_gallery' ||
              (imageType == 'template_gallery' && variantId.isNotEmpty);

          final bool isTemplateScopedImage =
              imageType == 'template' ||
              (imageType == 'template_gallery' && variantId.isEmpty) ||
              imageType.isEmpty;

          // Remember first template image as a generic fallback.
          if (isTemplateScopedImage && templateImage == null) {
            templateImage = imageUrl;
          }

          if (isVariantScopedImage) {
            if (!variantImages.contains(imageUrl)) {
              variantImages.add(imageUrl);
            }
          } else if (isTemplateScopedImage) {
            if (!templateImages.contains(imageUrl)) {
              templateImages.add(imageUrl);
            }
          }
          
          // Map variant-specific images to colors for color swatches
          if (isVariantScopedImage && variantId.isNotEmpty) {
            final color = variantIdToColor[variantId];
            if (color != null && canonicalVariantIdByColor[color] == variantId) {
              colorToImages.putIfAbsent(color, () => <String>[]);
              if (!colorToImages[color]!.contains(imageUrl)) {
                colorToImages[color]!.add(imageUrl);
              }
            }
          }
        }
      } else {
        // Simple format: only an `image` field, no type/variant_id metadata
        for (final img in imagesList) {
          if (img is! Map<String, dynamic>) continue;
          
          final imagePath = (img['image'] as String?);
          if (imagePath == null || imagePath.isEmpty) continue;
          
          final imageUrl = _constructImageUrl(imagePath);
          if (imageUrl.isEmpty) continue;

          // Without type information we treat these as template‑scoped.
          if (!templateImages.contains(imageUrl)) {
            templateImages.add(imageUrl);
          }

          if (templateImage == null) {
            templateImage = imageUrl;
          }
        }
      }

      // Merge into the final images list: variant images first, then template images.
      images
        ..addAll(variantImages)
        ..addAll(templateImages);
    } else if (item['main_image'] != null && item['main_image'].toString().isNotEmpty) {
      // Fallback to main_image if images array is empty
      final mainImageUrl = _constructImageUrl(item['main_image'] as String);
      if (mainImageUrl.isNotEmpty) {
        images.add(mainImageUrl);
      }
    } else if (item['image_1920'] != null && item['image_1920'].toString().isNotEmpty) {
      // Fallback to image_1920 (common in Odoo)
      final imageUrl = _constructImageUrl(item['image_1920'] as String);
      if (imageUrl.isNotEmpty) {
        images.add(imageUrl);
      }
    } else {
      images.add('https://via.placeholder.com/300x300?text=No+Image');
    }

    // If we still don't have any images, fall back to the template image
    // (this is mainly relevant for variant products with incomplete data).
    if (productType == 'variant' && images.isEmpty) {
      final productTemplate = item['product_template'] as Map<String, dynamic>?;
      String? templateImageUrl;

      if (productTemplate != null) {
        // 1) Prefer explicit template image_1920 from product_template
        final templateImagePath =
            productTemplate['image_1920']?.toString() ?? '';
        if (templateImagePath.isNotEmpty) {
          templateImageUrl = _constructImageUrl(templateImagePath);
        } else if (productTemplate['id'] != null) {
          // 2) Fallback: construct from template id as in Postman
          final templateId = productTemplate['id'].toString();
          templateImageUrl = _constructImageUrl(
            '/web/image/product.template/$templateId/image_1920',
          );
        }
      }

      // If we resolved a valid template image URL and have no images yet, add it
      if (templateImageUrl != null && templateImageUrl.isNotEmpty) {
        images.add(templateImageUrl);
        print(
          '  - Added fallback TEMPLATE image: $templateImageUrl',
        );
      }
    }

    // Extract categories
    String category = 'Unknown';
    if (item['categories'] != null && (item['categories'] as List).isNotEmpty) {
      category = (item['categories'] as List).first['name'] as String;
    }

    // Extract attributes for sizes and colors
    final sizes = <String>[];
    final colors = <String>[];
    
    if (item['product_attributes'] != null) {
      final attributes = item['product_attributes'] as List<dynamic>;
      for (final attr in attributes) {
        final attrName = attr['name'] as String;
        final values = attr['values'] as List<dynamic>;
        
        if (attrName.toLowerCase() == 'size') {
          sizes.addAll(values.map((v) => v['name'] as String));
        } else if (attrName.toLowerCase() == 'color') {
          // Extract color names
          colors.addAll(values.map((v) => v['name'] as String));
          
          // Extract color images from product_attributes[COLOR].values[].image
          // Map color name to its image URL
          for (final value in values) {
            if (value is Map<String, dynamic>) {
              final colorName = value['name'] as String?;
              final colorImagePath = value['image'] as String?;
              
              if (colorName != null && colorName.isNotEmpty && 
                  colorImagePath != null && colorImagePath.isNotEmpty) {
                final colorImageUrl = _constructImageUrl(colorImagePath);
                if (colorImageUrl.isNotEmpty) {
                  colorToImages.putIfAbsent(colorName, () => <String>[]);
                  if (!colorToImages[colorName]!.contains(colorImageUrl)) {
                    colorToImages[colorName]!.add(colorImageUrl);
                    print('  - Added color image from product_attributes for "$colorName": $colorImageUrl');
                  }
                }
              }
            }
          }
        }
      }
    }

    // Extract current attributes (selected values)
    if (item['attributes'] != null) {
      final currentAttributes = item['attributes'] as List<dynamic>;
      for (final attr in currentAttributes) {
        final attrName = attr['attribute_name'] as String;
        final valueName = attr['value_name'] as String;
        
        if (attrName.toLowerCase() == 'size' && !sizes.contains(valueName)) {
          sizes.add(valueName);
        } else if (attrName.toLowerCase() == 'color' && !colors.contains(valueName)) {
          colors.add(valueName);
        }
      }
    }

    // productId already declared at the top of the function
    print('📦 Creating Product: ID=$productId, Name=${item['name']}, Images=${images.length}');
    
    // Ensure we always have at least one image
    if (images.isEmpty) {
      // Prefer the product template id (if present) for the fallback,
      // since the template, not the variant id, owns the main image.
      final productTemplate = item['product_template'] as Map<String, dynamic>?;
      final templateId = productTemplate?['id']?.toString();
      final fallbackPath = templateId != null
          ? '/web/image/product.template/$templateId/image_1920'
          : '/web/image/product.template/${item['id']}/image_1920';
      final fallbackImageUrl = _constructImageUrl(fallbackPath);
      images.add(fallbackImageUrl);
      print('  - Added fallback image: $fallbackImageUrl');
    }
    
    // Parse badge/tag data from API
    final tags = <String>[];
    final isOnSale = item['is_on_sale'] as bool? ?? false;
    final saleBadge = item['sale_badge'] as String?;
    // New flag comes directly from API; no date-based fallback.
    final isNew = item['is_new'] as bool? ?? false;
    
    // Extract tags from API response
    if (item['tags'] != null && (item['tags'] as List).isNotEmpty) {
      tags.addAll((item['tags'] as List).map((tag) => tag['name'] as String));
    }
    
    // createdAt is best-effort; not all responses include it.
    final createdAtStr = item['create_date'] as String?;
    final createdAt = createdAtStr != null && createdAtStr.isNotEmpty
        ? DateTime.parse(createdAtStr)
        : DateTime.now();
    
    // Calculate discount based on before-discount price from API
    final price = (item['price'] as num).toDouble();
    final num? rawOriginalPrice =
        (item['original_price'] as num?) ?? (item['price_before_discount'] as num?);
    final hasDiscount = rawOriginalPrice != null && rawOriginalPrice > price;
    final double? finalOriginalPrice =
        hasDiscount ? rawOriginalPrice!.toDouble() : null;
    
    // Build display name with current attribute values when applicable
    String finalName;
    try {
      final attrs = (item['attributes'] as List<dynamic>?) ?? const [];
      final attrValues = <String>[];
      for (final a in attrs) {
        final valueName = (a as Map<String, dynamic>)['value_name']?.toString().trim();
        if (valueName != null && valueName.isNotEmpty) {
          attrValues.add(valueName);
        }
      }
      final productTemplate = item['product_template'] as Map<String, dynamic>?;
      final hasVariantsFlag = (productTemplate != null && (productTemplate['has_variants'] == true)) ||
          ((item['type']?.toString() ?? '').toLowerCase() == 'variant');
      if (hasVariantsFlag && attrValues.isNotEmpty) {
        finalName = '${item['name']} (${attrValues.join(', ')})';
      } else {
        finalName = item['name'] as String;
      }
    } catch (_) {
      finalName = item['name'] as String;
    }
    
    final product = HomeProduct.Product(
      id: productId,
      name: finalName,
      description: item['description'] as String? ?? '',
      price: price,
      originalPrice: finalOriginalPrice,
      images: images,
      category: category,
      brand: item['brand'] as String? ?? 'Unknown',
      type: productType, // Use the actual product type from API response
      rating: 4.5, // Mock rating since it's not in the API response
      reviewCount: 100, // Mock review count
      isAvailable: (item['qty_available'] as num).toDouble() > 0,
      sizes: sizes.isNotEmpty ? sizes : ['S', 'M', 'L'], // Default sizes if none found
      // Do not inject fake colors; leave empty so catalog aggregates true colors only
      colors: colors,
      colorImages: colorToImages.isNotEmpty ? colorToImages : null,
      createdAt: createdAt,
      favourite: false, // Mock favorite status
      tags: tags,
      // New badge is driven solely by is_new from API (no fallback)
      isNew: isNew,
      isOnSale: isOnSale || hasDiscount,
      saleBadge: saleBadge,
    );
    
    return product;
  }

  /// Convert ProductEntity.Product to HomeProduct.Product
  HomeProduct.Product _convertToHomeProduct(ProductEntity.Product productEntity) {
    // Extract sizes and colors from variant attributes
    final sizes = <String>[];
    final colors = <String>[];
    
    for (final attr in productEntity.variantAttributes) {
      if (attr.name.toLowerCase() == 'size') {
        sizes.addAll(attr.values.map((v) => v.name));
      } else if (attr.name.toLowerCase() == 'color') {
        colors.addAll(attr.values.map((v) => v.name));
      }
    }

    // Calculate if product is new based on creation date (within last 10 days)
    // Since ProductEntity doesn't have createdAt, we'll use a mock calculation
    final isNewByDate = false; // Will be determined by API data
    
    // Calculate discount percentage if on sale
    // Since ProductEntity doesn't have originalPrice, we'll use a mock calculation
    final hasDiscount = false; // Will be determined by API data
    
    // Build display name with variant details if applicable
    String finalName = productEntity.name;
    if (productEntity.type == 'variant' && productEntity.variantCombinations.isNotEmpty) {
      // For variants, try to find the matching variant combination and extract attributes
      // Use the first variant combination's attributes as fallback
      final variantCombination = productEntity.variantCombinations.first;
      final attrValues = <String>[];
      for (final attr in variantCombination.attributes) {
        final valueName = attr.valueName.trim();
        if (valueName.isNotEmpty) {
          attrValues.add(valueName);
        }
      }
      if (attrValues.isNotEmpty && productEntity.hasVariants) {
        finalName = '${productEntity.name} (${attrValues.join(', ')})';
      }
    }
    
    return HomeProduct.Product(
      id: productEntity.id.toString(),
      name: finalName,
      description: productEntity.description,
      price: productEntity.price,
      originalPrice: null, // ProductEntity doesn't have originalPrice
      images: () {
        final images = <String>[];
        if (productEntity.images.isNotEmpty) {
          final imageUrls = productEntity.images.map((img) => _constructImageUrl(img.url)).toList();
          images.addAll(imageUrls.where((url) => url.isNotEmpty));
        } else if (productEntity.mainImage != null) {
          final mainImageUrl = _constructImageUrl(productEntity.mainImage!);
          if (mainImageUrl.isNotEmpty) {
            images.add(mainImageUrl);
          }
        }
        
        // Ensure we always have at least one image
        if (images.isEmpty) {
          final fallbackUrl = _constructImageUrl('/web/image/product.template/${productEntity.id}/image_1920');
          images.add(fallbackUrl);
        }
        
        return images;
      }(),
      category: productEntity.category.name,
      brand: productEntity.brand ?? 'Unknown',
      type: productEntity.type, // Pass the actual product type from API
      rating: 4.5, // Mock rating since it's not in the API response
      reviewCount: 100, // Mock review count
      isAvailable: productEntity.inStock,
      sizes: sizes.isNotEmpty ? sizes : ['S', 'M', 'L'], // Default sizes if none found
      // Do not inject fake colors; leave empty so catalog aggregates true colors only
      colors: colors,
      createdAt: DateTime.now(), // ProductEntity doesn't have createdAt
      favourite: false, // Mock favorite status
      tags: null, // ProductEntity doesn't have tags
      isNew: isNewByDate,
      isOnSale: hasDiscount,
      saleBadge: null, // No custom sale badge from this source
    );
  }
}


