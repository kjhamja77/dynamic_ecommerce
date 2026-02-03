import 'package:equatable/equatable.dart';
import '../../domain/entities/search_category.dart';
import '../../domain/entities/search_tab.dart';
import '../../domain/entities/search_subcategory.dart';
import '../../data/models/search_results_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state when search page loads
class SearchInitial extends SearchState {}

/// Loading state when fetching categories or initial data
class SearchLoading extends SearchState {}

/// Loaded state with categories and tabs
class SearchLoaded extends SearchState {
  final List<SearchCategory> categories;
  final List<SearchTab> tabs;
  final Map<String, List<SearchSubcategory>> subcategories;
  final Set<String> loadingSubcategories;
  final String? selectedTabId;
  final String? searchQuery;

  const SearchLoaded({
    required this.categories,
    required this.tabs,
    this.subcategories = const {},
    this.loadingSubcategories = const {},
    this.selectedTabId,
    this.searchQuery,
  });

  SearchLoaded copyWith({
    List<SearchCategory>? categories,
    List<SearchTab>? tabs,
    Map<String, List<SearchSubcategory>>? subcategories,
    Set<String>? loadingSubcategories,
    String? selectedTabId,
    String? searchQuery,
  }) {
    return SearchLoaded(
      categories: categories ?? this.categories,
      tabs: tabs ?? this.tabs,
      subcategories: subcategories ?? this.subcategories,
      loadingSubcategories: loadingSubcategories ?? this.loadingSubcategories,
      selectedTabId: selectedTabId ?? this.selectedTabId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [categories, tabs, subcategories, loadingSubcategories, selectedTabId, searchQuery];
}

/// Error state for search operations
class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loading state when searching for products
class ProductSearchLoading extends SearchState {
  final String searchQuery;

  const ProductSearchLoading({required this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

/// Loaded state with search results
class ProductSearchLoaded extends SearchState {
  final SearchResults results;
  final String searchQuery;

  const ProductSearchLoaded({
    required this.results,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [results, searchQuery];
}

/// Error state for product search
class ProductSearchError extends SearchState {
  final String message;
  final String searchQuery;

  const ProductSearchError({
    required this.message,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [message, searchQuery];
}