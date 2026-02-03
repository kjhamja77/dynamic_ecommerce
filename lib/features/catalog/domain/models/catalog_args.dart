import '../../../filters/domain/entities/filter_criteria.dart';

class CatalogArgs {
  final String title;
  final String? category; // e.g., Shoes, Clothing
  final String? categoryId; // Category ID for API calls
  final String? brand; // e.g., Nike
  final bool featured; // all featured products
  final String? query; // search query
  final FilterCriteria? initialFilters; // Optional initial filter criteria to apply

  const CatalogArgs({
    required this.title,
    this.category,
    this.categoryId,
    this.brand,
    this.featured = false,
    this.query,
    this.initialFilters,
  });
}


