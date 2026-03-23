import '../entities/paginated_products.dart';
import '../../../filters/domain/entities/filter_criteria.dart';

abstract class CatalogRepository {
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
  });
  
  /// Fetch products using FilterCriteria directly - preserves exact values from filters page
  Future<PaginatedProducts> fetchProductsWithFilterCriteria({
    required FilterCriteria criteria,
  });

  /// Clear any in-memory catalog cache (used on language change so that
  /// product lists are always reloaded in the newly selected language).
  void clearCache();
}


