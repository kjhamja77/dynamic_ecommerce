import '../entities/paginated_products.dart';
import '../repositories/catalog_repository.dart';

class FetchCatalogPage {
  final CatalogRepository repository;
  const FetchCatalogPage(this.repository);

  Future<PaginatedProducts> call({
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
    int? limit, // Limit from FilterCriteria
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
    return repository.fetchProducts(
      page: page,
      pageSize: limit ?? pageSize, // Use limit from FilterCriteria if provided
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
}


