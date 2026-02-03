import 'package:dartz/dartz.dart';
import '../../domain/entities/search_category.dart';
import '../../domain/entities/search_tab.dart';
import '../../domain/entities/search_subcategory.dart';
import '../../domain/entities/subcategory_details.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/services/category_service.dart';
import '../models/search_tab_model.dart';
import '../models/search_subcategory_model.dart';
import '../models/subcategory_details_model.dart';
import '../models/search_params_model.dart';
import '../models/search_results_model.dart';
import '../datasources/search_remote_data_source.dart';
import '../datasources/search_local_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../product/domain/entities/product_category.dart';

class SearchRepositoryImpl implements SearchRepository {
  final CategoryService _categoryService;
  final SearchRemoteDataSource _searchRemoteDataSource;
  final SearchLocalDataSource _searchLocalDataSource;

  SearchRepositoryImpl({
    required CategoryService categoryService,
    required SearchRemoteDataSource searchRemoteDataSource,
    required SearchLocalDataSource searchLocalDataSource,
  })  : _categoryService = categoryService,
        _searchRemoteDataSource = searchRemoteDataSource,
        _searchLocalDataSource = searchLocalDataSource;

  @override
  Future<List<SearchCategory>> getSearchCategories() async {
    try {
      // Get root categories from the real API with timeout
      final result = await _categoryService.getRootCategories(maxDepth: 1)
          .timeout(
            // With global request queueing enabled, this call may wait behind other requests.
            // Use a larger timeout to avoid falling back unnecessarily.
            const Duration(seconds: 30),
            onTimeout: () => Left(ServerFailure('Request timeout')),
          );
      
      return result.fold(
        (failure) {
          // If API fails, return fallback categories
          return _getFallbackCategories();
        },
        (productCategories) {
          // Convert ProductCategory to SearchCategory
          final categories = productCategories
              .map((category) => SearchCategory.fromProductCategory(category))
              .toList();
          
          // If API returns empty list, use fallback categories
          if (categories.isEmpty) {
            return _getFallbackCategories();
          }
          
          return categories;
        },
      );
    } catch (e) {
      // Return fallback categories on error
      return _getFallbackCategories();
    }
  }

  List<SearchCategory> _getFallbackCategories() {
    return [
      const SearchCategory(
        id: 'women',
        title: 'Women',
        iconName: 'person',
        colorHex: '#E91E63',
        sortOrder: 1,
      ),
      const SearchCategory(
        id: 'men',
        title: 'Men',
        iconName: 'person',
        colorHex: '#2196F3',
        sortOrder: 2,
      ),
      const SearchCategory(
        id: 'kids',
        title: 'Kids',
        iconName: 'child_care',
        colorHex: '#4CAF50',
        sortOrder: 3,
      ),
    ];
  }

  @override
  Future<List<SearchTab>> getSearchTabs() async {
    try {
      // Get categories and create tabs from them with timeout
      final categories = await getSearchCategories()
          .timeout(
            // Allow enough time when requests are queued
            const Duration(seconds: 30),
            onTimeout: () => _getFallbackCategories(),
          );
      
      // Convert categories to tabs
      return categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        
        return SearchTabModel(
          id: category.id,
          title: category.title,
          isSelected: index == 0, // Default to first tab
          sortOrder: category.sortOrder,
        );
      }).toList();
    } catch (e) {
      // Return fallback tabs if API fails
      return [
        const SearchTabModel(
          id: 'women',
          title: 'Women',
          isSelected: false,
          sortOrder: 1,
        ),
        const SearchTabModel(
          id: 'men',
          title: 'Men',
          isSelected: true,
          sortOrder: 2,
        ),
        const SearchTabModel(
          id: 'kids',
          title: 'Kids',
          isSelected: false,
          sortOrder: 3,
        ),
      ];
    }
  }

  @override
  Future<List<SearchSubcategory>> getSubcategories(String categoryId) async {
    try {
      // Convert categoryId string to int.
      // Some fallback tabs use non-numeric IDs like "women"/"men"/"kids".
      // In that case, resolve to the real numeric root category ID by name.
      int? parentId = int.tryParse(categoryId);
      if (parentId == null) {
        final normalized = categoryId.trim().toLowerCase();
        // "kids" fallback should map to "children" in this backend.
        final candidates = <String>{
          normalized,
          if (normalized == 'kids') 'children',
        };

        final rootsResult = await _categoryService
            .getRootCategories(maxDepth: 1)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => Left(ServerFailure('Request timeout')),
            );

        rootsResult.fold(
          (_) => parentId = null,
          (roots) {
            for (final c in roots) {
              final name = c.name.trim().toLowerCase();
              if (candidates.contains(name)) {
                parentId = c.id;
                break;
              }
            }
          },
        );
      }

      if (parentId == null) {
        // Cannot resolve to a valid numeric category ID → no subcategories
        return <SearchSubcategory>[];
      }

      // Fetch children categories using the API with increased depth
      final int resolvedParentId = parentId!;
      final result = await _categoryService.getCategoriesByParentId(
        parentId: resolvedParentId,
        maxDepth: 3, // Increased depth to support multi-level categories
      ).timeout(
        // Allow enough time when requests are queued + deeper fetching
        const Duration(seconds: 30),
        onTimeout: () => Left(ServerFailure('Request timeout')),
      );

      return result.fold(
        (failure) {
          // If API fails, return empty list
          return <SearchSubcategory>[];
        },
        (productCategories) {
          // Convert ProductCategory to SearchSubcategory recursively
          return _convertProductCategoriesToSubcategories(productCategories, categoryId);
        },
      );
    } catch (e) {
      // Return empty list if category not found or API fails
      return <SearchSubcategory>[];
    }
  }

  /// Recursively convert ProductCategory to SearchSubcategory with nested children
  List<SearchSubcategory> _convertProductCategoriesToSubcategories(
    List<ProductCategory> productCategories,
    String parentCategoryId,
  ) {
    return productCategories.map((category) {
      final hasChildren = category.hasChildren || category.children.isNotEmpty;
      
      // Construct image URL from category image path
      String? imageUrl;
      if (category.image != null && category.image!.isNotEmpty) {
        if (category.image!.startsWith('http')) {
          imageUrl = category.image;
        } else {
          imageUrl = '${AppConstants.baseUrl}${category.image!.startsWith('/') ? category.image : '/${category.image}'}';
        }
      }
      
      return SearchSubcategoryModel(
        id: category.id.toString(),
        title: category.name,
        categoryId: parentCategoryId,
        imageUrl: imageUrl,
        sortOrder: category.sequence,
        hasChildren: hasChildren,
        productCount: category.productCount,
        children: hasChildren 
            ? _convertProductCategoriesToSubcategories(category.children, category.id.toString())
            : const [],
      );
    }).toList();
  }

  @override
  Future<List<SearchSubcategory>> getNestedSubcategories(String subcategoryId) async {
    try {
      // Convert subcategoryId string to int
      final parentId = int.tryParse(subcategoryId);
      if (parentId == null) {
        return <SearchSubcategory>[];
      }

      // Fetch children categories using the API
      final result = await _categoryService.getCategoriesByParentId(
        parentId: parentId,
        maxDepth: 2, // Limit depth for nested subcategories
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => Left(ServerFailure('Request timeout')),
      );

      return result.fold(
        (failure) {
          // If API fails, return empty list
          return <SearchSubcategory>[];
        },
        (productCategories) {
          // Convert ProductCategory to SearchSubcategory recursively
          return _convertProductCategoriesToSubcategories(productCategories, subcategoryId);
        },
      );
    } catch (e) {
      // Return empty list if subcategory not found or API fails
      return <SearchSubcategory>[];
    }
  }

  @override
  Future<void> updateSelectedTab(String tabId) async {
    // This is handled by the BLoC, no need for repository implementation
    // The BLoC manages the selected tab state
  }

  @override
  Future<List<SearchCategory>> searchCategories(String query) async {
    // Get all categories and filter them
    final allCategories = await getSearchCategories();
    if (query.isEmpty) return allCategories;
    
    final lowercaseQuery = query.toLowerCase();
    return allCategories.where((category) {
      return category.title.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  Future<SubcategoryDetails> getSubcategoryDetails(String subcategoryId) async {
    // For now, return a basic subcategory details
    // This can be enhanced later to fetch from API
    return SubcategoryDetailsModel(
      id: subcategoryId,
      title: 'Subcategory Details',
      parentCategoryId: 'unknown', // Default parent category ID
      items: [],
    );
  }

  @override
  Future<SearchResults> searchProducts(SearchParams params) async {
    try {
      print('SearchRepository - Searching with params: ${params.toJson()}');
      
      // Add timeout and retry logic
      final results = await _searchRemoteDataSource.searchProducts(params)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        print('SearchRepository - Search timeout after 30 seconds');
        throw Exception('Search request timed out');
      });
      
      print('SearchRepository - Search completed, results count: ${results.products.length}');
      return results;
    } catch (e) {
      print('SearchRepository - Search failed with error: ${e.toString()}');
      // Re-throw the error instead of returning empty results
      // This will allow the BLoC to handle it properly
      rethrow;
    }
  }
}