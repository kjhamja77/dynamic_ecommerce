import 'package:equatable/equatable.dart';
import '../../domain/models/catalog_args.dart';
import '../../../filters/domain/entities/filter_criteria.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();
  @override
  List<Object?> get props => [];
}

class LoadCatalog extends CatalogEvent {
  final CatalogArgs args;
  const LoadCatalog(this.args);

  @override
  List<Object?> get props => [args];
}

class UpdateCatalogFilters extends CatalogEvent {
  final FilterCriteria? filterCriteria; // Pass FilterCriteria directly to preserve exact values
  final String? category;
  final List<int>? categoryIds; // Support multiple category IDs from filter page
  final String? brand;
  final List<int>? brandIds; // Support brand IDs directly from filter page (preserves original selection)
  final String? sortBy; // Sort option ID from API (e.g., 'price_low_high', 'newest_first', 'best_selling')
  final String? sortByField; // Direct sort field from FilterCriteria (e.g., 'list_price', 'create_date')
  final String? sortOrder; // Direct sort order from FilterCriteria (e.g., 'asc', 'desc')
  final int? limit; // Limit from FilterCriteria (preserves original selection)
  final String? query;
  final double? minPrice;
  final double? maxPrice;
  final bool? clearMinPrice;
  final bool? clearMaxPrice;
  final double? minRating;
  final bool? onSale;
  final bool? inStock;
  final List<String>? sizes;
  final List<String>? colors;
  final List<String>? selectedColors;
  final List<String>? materials;
  final List<String>? seasons;
  final List<String>? genders;
  final Map<String, List<String>>? extraAttributes;
  
  const UpdateCatalogFilters({
    this.filterCriteria, // If provided, this takes precedence over individual parameters
    this.category,
    this.categoryIds,
    this.brand,
    this.brandIds,
    this.sortBy, 
    this.sortByField,
    this.sortOrder,
    this.limit,
    this.query, 
    this.minPrice, 
    this.maxPrice, 
    this.clearMinPrice,
    this.clearMaxPrice,
    this.minRating, 
    this.onSale, 
    this.inStock, 
    this.sizes, 
    this.colors,
    this.selectedColors,
    this.materials,
    this.seasons,
    this.genders,
    this.extraAttributes,
  });
}

class LoadMoreCatalog extends CatalogEvent {
  const LoadMoreCatalog();
}

class UpdateSortOption extends CatalogEvent {
  final String sortBy;
  const UpdateSortOption(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}


