import 'package:dio/dio.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import 'dart:convert';
import '../../domain/entities/filter_category.dart';
import '../../domain/entities/filter_brand.dart';
import '../../domain/entities/filter_attribute.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/entities/filter_criteria.dart';
import '../../../../core/errors/failures.dart';

class _AttributesCacheEntry {
  final List<FilterAttribute> attributes;
  final DateTime timestamp;

  _AttributesCacheEntry(this.attributes, this.timestamp);
}

abstract class FilterRemoteDataSource {
  Future<List<FilterCategory>> getCategories({
    int page = 1,
    int limit = 6,
    int? parentId,
  });
  
  Future<List<FilterCategory>> getCategoriesWithChildren({
    int? parentId,
    int maxDepth = 3,
  });
  
  Future<List<FilterBrand>> getBrands({
    int page = 1,
    int limit = 7,
  });
  
  Future<List<FilterAttribute>> getAttributes({
    int page = 1,
    int limit = 50,
    List<int>? categoryIds,
  });
  
  /// Clears any in-memory cache related to attributes so that subsequent
  /// calls to [getAttributes] are forced to hit the backend again.
  void clearAttributesCache();
  
  Future<FilterOptions> getFilterOptions();
  
  Future<Map<String, dynamic>> filterProducts(
    FilterCriteria criteria, {
    Map<int, List<int>>? parentChildMap,
  });
}

class FilterRemoteDataSourceImpl implements FilterRemoteDataSource {
  final ApiClient apiClient;

  FilterRemoteDataSourceImpl({required this.apiClient});

  final Map<String, _AttributesCacheEntry> _attributesCache = {};
  static const Duration _attributesCacheTtl = Duration(minutes: 5);

  @override
  Future<List<FilterCategory>> getCategories({
    int page = 1,
    int limit = 6,
    int? parentId,
  }) async {
    try {
      print('🌐 FilterRemoteDataSource: GET /ecom/get/product/categories');
      print('   Params: page=$page, limit=$limit, parentId=$parentId');
      
      final response = await apiClient.requestRpc(
        '/ecom/get/product/categories',
        method: 'GET',
        params: {
          'page': page,
          'limit': limit,
          if (parentId != null) 'parent_id': parentId,
        },
      );
      print('response from the get filer data ${response.data}');

      print('📡 FilterRemoteDataSource: Response status: ${response.statusCode}');
      print('📡 FilterRemoteDataSource: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final responseData = data['data'];
          List<dynamic> categoriesData;
          
          // Handle both direct array and items wrapper structures
          if (responseData is List<dynamic>) {
            categoriesData = responseData;
            print('📊 FilterRemoteDataSource: Found ${categoriesData.length} categories in direct array');
          } else if (responseData is Map<String, dynamic> && responseData.containsKey('items')) {
            categoriesData = responseData['items'] as List<dynamic>? ?? [];
            print('📊 FilterRemoteDataSource: Found ${categoriesData.length} categories in items array');
          } else {
            categoriesData = [];
            print('⚠️ FilterRemoteDataSource: No categories found in response');
          }
          
          final categories = categoriesData
              .map((category) => FilterCategory.fromJson(category as Map<String, dynamic>))
              .toList();
          print('get categories from filters $categories');
          print('✅ FilterRemoteDataSource: Parsed ${categories.length} categories');
          return categories;
        }
        print('⚠️ FilterRemoteDataSource: No data field in response');
        return [];
      } else {
        print('❌ FilterRemoteDataSource: HTTP error ${response.statusCode}');
        throw ServerFailure('Failed to fetch categories: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ FilterRemoteDataSource: DioException: ${e.message}');
      throw ServerFailure('Network error: ${e.message}');
    } catch (e) {
      print('❌ FilterRemoteDataSource: Unexpected error: $e');
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<List<FilterCategory>> getCategoriesWithChildren({
    int? parentId,
    int maxDepth = 3,
  }) async {
    try {
      print('🌐 FilterRemoteDataSource: POST /ecom/get/product-category');
      print('   Params: parentId=$parentId, maxDepth=$maxDepth');
      
      final requestParams = {
        if (parentId != null) 'parent_id': parentId,
        'max_depth': maxDepth,
      };
      print('📤 Request body will be: {"params": $requestParams}');
      
      final response = await apiClient.requestRpc(
        '/ecom/get/product-category',
        method: 'POST',
        params: requestParams,
      );

      print('📡 FilterRemoteDataSource: Response status: ${response.statusCode}');
      print('📡 FilterRemoteDataSource: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        dynamic categoriesData;
        
        // Handle different response formats
        if (data is Map<String, dynamic>) {
          if (data.containsKey('result') && data['result'] is Map) {
            final result = data['result'] as Map;
            if (result.containsKey('data')) {
              final responseData = result['data'];
              if (responseData is List<dynamic>) {
                categoriesData = responseData;
              } else if (responseData is Map<String, dynamic> && responseData.containsKey('items')) {
                categoriesData = responseData['items'] as List<dynamic>? ?? [];
              }
            }
          } else if (data.containsKey('data')) {
            final responseData = data['data'];
            if (responseData is List<dynamic>) {
              categoriesData = responseData;
            } else if (responseData is Map<String, dynamic> && responseData.containsKey('items')) {
              categoriesData = responseData['items'] as List<dynamic>? ?? [];
            }
          }
        }
        
        if (categoriesData == null) {
          print('⚠️ FilterRemoteDataSource: No categories found in response');
          return [];
        }
        
        final categories = (categoriesData as List<dynamic>)
            .map((category) => FilterCategory.fromJson(category as Map<String, dynamic>))
            .toList();
        
        print('✅ FilterRemoteDataSource: Parsed ${categories.length} categories with nested children');
        return categories;
      } else {
        print('❌ FilterRemoteDataSource: HTTP error ${response.statusCode}');
        throw ServerFailure('Failed to fetch categories: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ FilterRemoteDataSource: DioException: ${e.message}');
      throw ServerFailure('Network error: ${e.message}');
    } catch (e) {
      print('❌ FilterRemoteDataSource: Unexpected error: $e');
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<List<FilterBrand>> getBrands({
    int page = 1,
    int limit = 7,
  }) async {
    // Retry logic for brands endpoint (sometimes times out)
    int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        if (retryCount > 0) {
          print('🔄 FilterRemoteDataSource: Retrying brands request (attempt ${retryCount + 1}/$maxRetries)');
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
        
        print('🌐 FilterRemoteDataSource: GET /ecom/get/product/brands');
        print('   Params: page=$page, limit=$limit');
        
        final response = await apiClient.requestRpc(
          '/ecom/get/product/brands',
          method: 'GET',
          params: {
            'page': page,
            'limit': limit,
          },
        );

      print('📡 FilterRemoteDataSource: Response status: ${response.statusCode}');
      print('📡 FilterRemoteDataSource: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final responseData = data['data'];
          List<dynamic> brandsData;
          
          // Handle both direct array and items wrapper structures
          if (responseData is List<dynamic>) {
            brandsData = responseData;
            print('📊 FilterRemoteDataSource: Found ${brandsData.length} brands in direct array');
          } else if (responseData is Map<String, dynamic> && responseData.containsKey('items')) {
            brandsData = responseData['items'] as List<dynamic>? ?? [];
            print('📊 FilterRemoteDataSource: Found ${brandsData.length} brands in items array');
          } else {
            brandsData = [];
            print('⚠️ FilterRemoteDataSource: No brands found in response');
          }
          
          final brands = brandsData
              .map((brand) => FilterBrand.fromJson(brand as Map<String, dynamic>))
              .toList();
          
          print('✅ FilterRemoteDataSource: Parsed ${brands.length} brands');
          return brands;
        }
        print('⚠️ FilterRemoteDataSource: No data field in response');
        return [];
      } else {
        print('❌ FilterRemoteDataSource: HTTP error ${response.statusCode}');
        throw ServerFailure('Failed to fetch brands: ${response.statusCode}');
      }
      } on DioException catch (e) {
        // Check if it's a timeout error and we have retries left
        if ((e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout ||
            (e.message?.contains('timeout') ?? false)) &&
            retryCount < maxRetries - 1) {
          retryCount++;
          print('⏱️ FilterRemoteDataSource: Timeout error, will retry (${retryCount}/$maxRetries)');
          continue; // Retry the request
        }
        // If no retries left or different error, throw
        print('❌ FilterRemoteDataSource: DioException: ${e.message}');
        throw ServerFailure('Network error: ${e.message}');
      } catch (e) {
        // For non-DioException errors, check if we should retry
        if (retryCount < maxRetries - 1 && e.toString().contains('timeout')) {
          retryCount++;
          print('⏱️ FilterRemoteDataSource: Timeout error, will retry (${retryCount}/$maxRetries)');
          continue;
        }
        print('❌ FilterRemoteDataSource: Unexpected error: $e');
        throw ServerFailure('Unexpected error: $e');
      }
    }
    
    // If we exhausted all retries, return empty list as fallback
    print('⚠️ FilterRemoteDataSource: Brands request failed after $maxRetries attempts, returning empty list');
    return [];
  }

  @override
  Future<List<FilterAttribute>> getAttributes({
    int page = 1,
    int limit = 50,
    List<int>? categoryIds,
  }) async {
    try {
      // Attributes are heavily reused between filter openings; add a small
      // in-memory cache keyed by (page, limit, categoryIds) to avoid
      // unnecessary network calls when data is still fresh.
      final sortedCategoryIds =
          categoryIds == null ? null : (List<int>.from(categoryIds)..sort());
      final cacheKey =
          'p:$page|l:$limit|c:${sortedCategoryIds?.join(",") ?? "null"}';
      final now = DateTime.now();
      final cachedEntry = _attributesCache[cacheKey];

      if (cachedEntry != null &&
          now.difference(cachedEntry.timestamp) <= _attributesCacheTtl) {
        print(
          '💾 FilterRemoteDataSource: Returning cached attributes for key=$cacheKey',
        );
        return cachedEntry.attributes;
      }

      print('🌐 FilterRemoteDataSource: GET /ecom/get/product/attributes');
      print('   ➤ Endpoint: /ecom/get/product/attributes');
      print('   ➤ HTTP Method: GET');
      print('   ➤ High-level params: page=$page, limit=$limit, categoryIds=$categoryIds');

      // IMPORTANT:
      // This backend expects GET parameters as "attributes" in the request body (form-data),
      // not as query parameters wrapped in params[...].
      // Example (Postman/Dio):
      //   FormData: { page, limit, category_ids: [560, 561] }
      // Note: Dio FormData handles lists by sending multiple entries with the same key,
      // but if backend expects JSON array, we send it as JSON string.
      final formDataMap = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      // Send category_id as a JSON-encoded string if provided.
      // Backend expects category_id as a JSON array string in form-data: category_id: "[559]" or "[559,560]".
      // (See Postman collection where the key is `category_id`, not `category_ids`.)
      // Dio FormData.fromMap() with a list would send multiple entries (category_id[]=559&category_id[]=560),
      // but the backend expects a single JSON array string, so we encode it.
      if (categoryIds != null && categoryIds.isNotEmpty) {
        // Send as JSON-encoded string: "[559]" or "[559,560]"
        final json = jsonEncode(categoryIds);
        formDataMap['category_id'] = json;
        print('📤 FilterRemoteDataSource: category_id payload (JSON string) → $json');
      }
      
      // Log the exact body we are about to send
      print('📤 FilterRemoteDataSource: Final request body for /ecom/get/product/attributes:');
      print('   FormData map: $formDataMap');
      
      final formData = FormData.fromMap(formDataMap);

      final response = await apiClient.requestRaw(
        '/ecom/get/product/attributes',
        method: 'GET',
        data: formData,
      );

      // Log response right after the request so we see full round-trip for this endpoint.
      print('📡 FilterRemoteDataSource: Response from /ecom/get/product/attributes');
      print('   Status: ${response.statusCode}');
      print('   Raw data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('📡 FilterRemoteDataSource: Raw response data type: ${data.runtimeType}');
        if (data is Map) {
          print('📡 FilterRemoteDataSource: Raw response data keys: ${data.keys.toList()}');
        }
        
        // Handle RPC-wrapped response: { "result": { "data": { "items": [...] } } }
        Map<String, dynamic>? responseData;
        if (data is Map<String, dynamic> && data.containsKey('result')) {
          final result = data['result'];
          if (result is Map<String, dynamic> && result.containsKey('data')) {
            final dataField = result['data'];
            if (dataField is Map<String, dynamic>) {
              responseData = dataField;
              print('📊 FilterRemoteDataSource: Found RPC-wrapped response');
            }
          }
        }
        // Handle direct response: { "data": { "items": [...] } }
        else if (data is Map<String, dynamic> && data.containsKey('data')) {
          responseData = data['data'] as Map<String, dynamic>?;
          print('📊 FilterRemoteDataSource: Found direct response');
        }
        
        if (responseData != null) {
          final attributesData = responseData['items'] as List<dynamic>? ?? [];
          print('📊 FilterRemoteDataSource: Found ${attributesData.length} attributes in items array');
          
          final attributes = attributesData
              .map((attr) =>
                  FilterAttribute.fromApiResponse(attr as Map<String, dynamic>))
              .toList();
          
          print('✅ FilterRemoteDataSource: Parsed ${attributes.length} attributes');
          // Debug: Print first attribute details
          if (attributes.isNotEmpty) {
            print('📊 FilterRemoteDataSource: First attribute - name: "${attributes.first.name}", type: "${attributes.first.type}", values: ${attributes.first.values.length}');
          }
          
          _attributesCache[cacheKey] =
              _AttributesCacheEntry(attributes, DateTime.now());
          return attributes;
        }
        print('⚠️ FilterRemoteDataSource: No data field in response');
        return [];
      } else {
        print('❌ FilterRemoteDataSource: HTTP error ${response.statusCode}');
        throw ServerFailure('Failed to fetch attributes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ FilterRemoteDataSource: DioException: ${e.message}');
      throw ServerFailure('Network error: ${e.message}');
    } catch (e) {
      print('❌ FilterRemoteDataSource: Unexpected error: $e');
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<FilterOptions> getFilterOptions() async {
    try {
      print('🌐 FilterRemoteDataSource: GET /ecom/get/product/filter-options');
      final response = await apiClient.requestRpc(
        '/ecom/get/product/filter-options',
        method: 'GET',
        params: const {},
      );

      print('📡 FilterRemoteDataSource: Response status: ${response.statusCode}');
      print('📡 FilterRemoteDataSource: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          // Use entity factory geared for this API shape
          final options = FilterOptions.fromApiResponse(data);
          var pr = options.priceRange ?? const FilterPriceRange(minPrice: 0, maxPrice: 1000);
          
          // Validate price range: if min >= max or both are 0, use defaults
          if (pr.minPrice >= pr.maxPrice || (pr.minPrice == 0 && pr.maxPrice == 0)) {
            print('⚠️ FilterRemoteDataSource: Invalid price range from API (${pr.minPrice} - ${pr.maxPrice}), using defaults (0 - 1000)');
            pr = const FilterPriceRange(minPrice: 0, maxPrice: 1000);
            // Create new FilterOptions with corrected price range
            return FilterOptions.withLoadedData(
              priceRange: pr,
              categories: options.categories,
              brands: options.brands,
              attributes: options.attributes,
              availableSizes: options.availableSizes,
              availableColors: options.availableColors,
              availableMaterials: options.availableMaterials,
              availableSeasons: options.availableSeasons,
              availableGenders: options.availableGenders,
              sortingOptions: options.sortingOptions,
            );
          }
          
          print('💰 FilterRemoteDataSource: Price range from API: ${pr.minPrice} - ${pr.maxPrice}');
          return options;
        }
        print('⚠️ FilterRemoteDataSource: No data field in response');
        return const FilterOptions();
      } else {
        print('❌ FilterRemoteDataSource: HTTP error ${response.statusCode}');
        throw ServerFailure('Failed to fetch filter options: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ FilterRemoteDataSource: DioException: ${e.message}');
      throw ServerFailure('Network error: ${e.message}');
    } catch (e) {
      print('❌ FilterRemoteDataSource: Unexpected error: $e');
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> filterProducts(
    FilterCriteria criteria, {
    Map<int, List<int>>? parentChildMap,
  }) async {
    try {
      // CRITICAL: If parentChildMap is not provided but criteria has multiple categoryIds,
      // we need to build it by fetching category hierarchy to ensure only deepest IDs are sent
      Map<int, List<int>>? effectiveParentChildMap = parentChildMap;
      
      // CRITICAL SAFEGUARD: If parentChildMap is null and we have multiple categoryIds,
      // build it from API to ensure only deepest IDs are sent
      if (effectiveParentChildMap == null && criteria.categoryIds.length > 1) {
        print('⚠️ filterProducts: parentChildMap is null but multiple categoryIds detected: ${criteria.categoryIds}');
        print('⚠️ filterProducts: Building parentChildMap from API to ensure only deepest IDs are sent...');
        
        // Build parentChildMap by fetching categories with children
        effectiveParentChildMap = <int, List<int>>{};
        try {
          // Fetch all categories with children to build the map
          // Use maxDepth=3 to cover all hierarchy levels
          final allCategories = await getCategoriesWithChildren(parentId: null, maxDepth: 3);
          
          // Build parent-child map from fetched categories
          // This recursively builds the map for all levels
          void buildMapRecursive(List<FilterCategory> categories) {
            for (final category in categories) {
              if (category.children.isNotEmpty) {
                effectiveParentChildMap![category.id] = category.children.map((c) => c.id).toList();
                // Recursively process children
                buildMapRecursive(category.children);
              }
            }
          }
          
          buildMapRecursive(allCategories);
          
          print('✅ filterProducts: Built parentChildMap with ${effectiveParentChildMap.length} entries');
          if (effectiveParentChildMap.isNotEmpty) {
            print('✅ filterProducts: ParentChildMap sample: ${effectiveParentChildMap.entries.take(3).map((e) => '${e.key}->${e.value}').join(', ')}');
          }
        } catch (e) {
          print('❌ filterProducts: Failed to build parentChildMap: $e');
          print('❌ filterProducts: Will use categoryIds as-is (may include parent IDs if children are selected)');
          // Continue without parentChildMap - toJson() will use categoryIds as-is
          // This is a fallback, but ideally should not happen
        }
      }
      
      // Debug: Log the exact body being sent to filter-search
      // Use parentChildMap if provided to extract only deepest category IDs
      print('🔵 filterProducts ENTRY: criteria.categoryIds=${criteria.categoryIds}, parentChildMap provided=${effectiveParentChildMap != null && effectiveParentChildMap.isNotEmpty}');
      final jsonBody = criteria.toJson(parentChildMap: effectiveParentChildMap);
      print('🔵 filterProducts AFTER toJson: jsonBody contains category_ids=${jsonBody['category_ids']}');
      
      // Build the final request body (after Endpoints.withParams wrapping)
      final finalRequestBody = {'params': jsonBody};
      final jsonString = jsonEncode(finalRequestBody);
      
      print('🛰️ FilterRemoteDataSource.filterProducts() - Sending filter request:');
      print('   Endpoint: POST /ecom/get/product/filter-search');
      print('   ==========================================');
      print('   📤 EXACT REQUEST BODY (JSON String):');
      print('   $jsonString');
      print('   ==========================================');
      print('   📋 Request Body (Map structure):');
      print('   $finalRequestBody');
      print('   📋 Params object (what goes inside "params"):');
      print('   $jsonBody');
      print('   Category IDs: ${criteria.categoryIds}');
      print('   Brand IDs: ${criteria.brandIds}');
      print('   Product IDs: ${criteria.productIds}');
      print('   Attribute Values (IDs): ${criteria.attributeIds}');
      print('   Price Range: ${criteria.minPrice} - ${criteria.maxPrice}');
      print('   Search Query: ${criteria.searchQuery ?? "null"}');
      print('   Sort: ${criteria.sortByField} (${criteria.sortOrder})');
      print('   Pagination: page=${criteria.page}, limit=${criteria.limit}');

      final response = await apiClient.requestRpc(
        '/ecom/get/product/filter-search',
        method: 'POST',
        params: jsonBody,
      );

      // Log response right after calling the filter-search endpoint.
      print('📡 FilterRemoteDataSource: Response from /ecom/get/product/filter-search');
      print('   Status: ${response.statusCode}');
      print('   Raw data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Lightweight debug: print total_count if present
          int? total;
          final result = data['result'];
          if (result is Map) {
            final rData = result['data'];
            if (rData is Map && rData['total_count'] is int) {
              total = rData['total_count'] as int;
            } else if (result['total_count'] is int) {
              total = result['total_count'] as int;
            }
          }
          if (total == null) {
            final d = data['data'];
            if (d is Map && d['total_count'] is int) {
              total = d['total_count'] as int;
            }
          }
          if (total != null) {
            print('🧮 filter-search total_count: $total');
          }
          return data;
        }
        return {};
      } else {
        throw ServerFailure('Failed to filter products: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerFailure('Network error: ${e.message}');
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  void clearAttributesCache() {
    _attributesCache.clear();
    print('🧹 FilterRemoteDataSource: Cleared attributes cache');
  }
}
