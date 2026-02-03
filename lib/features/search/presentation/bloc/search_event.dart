import 'package:equatable/equatable.dart';
import '../../data/models/search_params_model.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial search data (categories and tabs)
class LoadSearchData extends SearchEvent {
  const LoadSearchData();
}

/// Load subcategories for a specific category
class LoadSubcategories extends SearchEvent {
  final String categoryId;

  const LoadSubcategories(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Select a search tab
class SelectSearchTab extends SearchEvent {
  final String tabId;

  const SelectSearchTab(this.tabId);

  @override
  List<Object?> get props => [tabId];
}

/// Search for products with specific parameters
class SearchProducts extends SearchEvent {
  final SearchParams params;

  const SearchProducts(this.params);

  @override
  List<Object?> get props => [params];
}

/// Clear current search results and return to initial state
class ClearSearch extends SearchEvent {
  const ClearSearch();
}

/// Retry the last search operation
class RetrySearch extends SearchEvent {
  const RetrySearch();
}

/// Load nested subcategories for a specific subcategory
class LoadNestedSubcategories extends SearchEvent {
  final String subcategoryId;

  const LoadNestedSubcategories(this.subcategoryId);

  @override
  List<Object?> get props => [subcategoryId];
}

/// Load all subcategories at once
class LoadAllSubcategories extends SearchEvent {
  const LoadAllSubcategories();
}