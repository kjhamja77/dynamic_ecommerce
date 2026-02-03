import 'package:equatable/equatable.dart';
import '../../../filters/domain/entities/filter_criteria.dart';
import '../../../filters/domain/entities/filter_category.dart';

/// Base class for all filter events
abstract class FiltersEvent extends Equatable {
  const FiltersEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize filters with initial criteria
class FiltersInitialized extends FiltersEvent {
  final FilterCriteria initialCriteria;

  const FiltersInitialized(this.initialCriteria);

  @override
  List<Object?> get props => [initialCriteria];
}

/// Update the entire filter criteria
class FiltersCriteriaUpdated extends FiltersEvent {
  final FilterCriteria criteria;

  const FiltersCriteriaUpdated(this.criteria);

  @override
  List<Object?> get props => [criteria];
}

/// Toggle on sale filter
class FiltersOnSaleToggled extends FiltersEvent {
  const FiltersOnSaleToggled();
}

/// Toggle in stock filter
class FiltersInStockToggled extends FiltersEvent {
  const FiltersInStockToggled();
}

/// Set minimum price
class FiltersMinPriceSet extends FiltersEvent {
  final double? minPrice;

  const FiltersMinPriceSet(this.minPrice);

  @override
  List<Object?> get props => [minPrice];
}

/// Set maximum price
class FiltersMaxPriceSet extends FiltersEvent {
  final double? maxPrice;

  const FiltersMaxPriceSet(this.maxPrice);

  @override
  List<Object?> get props => [maxPrice];
}

/// Set minimum rating
class FiltersMinRatingSet extends FiltersEvent {
  final double? minRating;

  const FiltersMinRatingSet(this.minRating);

  @override
  List<Object?> get props => [minRating];
}

/// Set brand
class FiltersBrandSet extends FiltersEvent {
  final String? brand;

  const FiltersBrandSet(this.brand);

  @override
  List<Object?> get props => [brand];
}

/// Set category
class FiltersCategorySet extends FiltersEvent {
  final String? category;

  const FiltersCategorySet(this.category);

  @override
  List<Object?> get props => [category];
}

/// Set brand IDs
class FiltersBrandIdsSet extends FiltersEvent {
  final List<int> brandIds;

  const FiltersBrandIdsSet(this.brandIds);

  @override
  List<Object?> get props => [brandIds];
}

/// Set category IDs
class FiltersCategoryIdsSet extends FiltersEvent {
  final List<int> categoryIds;

  const FiltersCategoryIdsSet(this.categoryIds);

  @override
  List<Object?> get props => [categoryIds];
}

/// Set sizes
class FiltersSizesSet extends FiltersEvent {
  final List<String> sizes;

  const FiltersSizesSet(this.sizes);

  @override
  List<Object?> get props => [sizes];
}

/// Set colors
class FiltersColorsSet extends FiltersEvent {
  final List<String> colors;

  const FiltersColorsSet(this.colors);

  @override
  List<Object?> get props => [colors];
}

/// Set materials
class FiltersMaterialsSet extends FiltersEvent {
  final List<String> materials;

  const FiltersMaterialsSet(this.materials);

  @override
  List<Object?> get props => [materials];
}

/// Set seasons
class FiltersSeasonsSet extends FiltersEvent {
  final List<String> seasons;

  const FiltersSeasonsSet(this.seasons);

  @override
  List<Object?> get props => [seasons];
}

/// Set genders
class FiltersGendersSet extends FiltersEvent {
  final List<String> genders;

  const FiltersGendersSet(this.genders);

  @override
  List<Object?> get props => [genders];
}

/// Set subcategories for a parent category
class FiltersSubcategoriesSet extends FiltersEvent {
  final int parentId;
  final List<FilterCategory> subcategories;

  const FiltersSubcategoriesSet(this.parentId, this.subcategories);

  @override
  List<Object?> get props => [parentId, subcategories];
}

/// Clear subcategories for a parent category
class FiltersSubcategoriesCleared extends FiltersEvent {
  final int parentId;

  const FiltersSubcategoriesCleared(this.parentId);

  @override
  List<Object?> get props => [parentId];
}

/// Clear all filters (reset to default)
class FiltersCleared extends FiltersEvent {
  const FiltersCleared();
}

/// Set sort field
class FiltersSortFieldSet extends FiltersEvent {
  final String? sortByField;

  const FiltersSortFieldSet(this.sortByField);

  @override
  List<Object?> get props => [sortByField];
}

/// Set sort order
class FiltersSortOrderSet extends FiltersEvent {
  final String? sortOrder;

  const FiltersSortOrderSet(this.sortOrder);

  @override
  List<Object?> get props => [sortOrder];
}

/// Set limit
class FiltersLimitSet extends FiltersEvent {
  final int limit;

  const FiltersLimitSet(this.limit);

  @override
  List<Object?> get props => [limit];
}

/// Set extra attributes
class FiltersExtraAttributesSet extends FiltersEvent {
  final Map<String, List<String>> extraAttributes;

  const FiltersExtraAttributesSet(this.extraAttributes);

  @override
  List<Object?> get props => [extraAttributes];
}

