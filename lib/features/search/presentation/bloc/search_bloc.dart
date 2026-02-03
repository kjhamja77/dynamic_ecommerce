import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/search_subcategory.dart';
import '../../domain/entities/search_tab.dart';
import '../../domain/usecases/get_search_categories.dart';
import '../../domain/usecases/get_search_tabs.dart';
import '../../domain/usecases/get_subcategories.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/repositories/search_repository.dart';
import '../../data/models/search_params_model.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GetSearchCategories _getSearchCategories;
  final GetSearchTabs _getSearchTabs;
  final GetSubcategories _getSubcategories;
  final SearchProductsUseCase _searchProductsUseCase;
  final SearchRepository _searchRepository;
  
  // Store the last search query for retry functionality
  String? _lastSearchQuery;

  SearchBloc({
    required GetSearchCategories getSearchCategories,
    required GetSearchTabs getSearchTabs,
    required GetSubcategories getSubcategories,
    required SearchProductsUseCase searchProductsUseCase,
    required SearchRepository searchRepository,
  })  : _getSearchCategories = getSearchCategories,
        _getSearchTabs = getSearchTabs,
        _getSubcategories = getSubcategories,
        _searchProductsUseCase = searchProductsUseCase,
        _searchRepository = searchRepository,
        super(SearchInitial()) {
    
    on<LoadSearchData>(_onLoadSearchData);
    on<LoadSubcategories>(_onLoadSubcategories);
    on<LoadNestedSubcategories>(_onLoadNestedSubcategories);
    on<LoadAllSubcategories>(_onLoadAllSubcategories);
    on<SelectSearchTab>(_onSelectSearchTab);
    on<SearchProducts>(_onSearchProducts);
    on<ClearSearch>(_onClearSearch);
    on<RetrySearch>(_onRetrySearch);
  }

  Future<void> _onLoadSearchData(
    LoadSearchData event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());

    try {
      // Load both categories and tabs concurrently
      // NOTE: Requests are queued globally (one-by-one) to keep the app smooth.
      // That means these futures can legitimately take longer than the API's raw response time.
      // Avoid throwing TimeoutException; instead return a failure on timeout.
      final categoriesResult = await _getSearchCategories(const NoParams()).timeout(
        const Duration(seconds: 45),
        onTimeout: () => Left(ServerFailure('Request timeout')),
      );
      final tabsResult = await _getSearchTabs(const NoParams()).timeout(
        const Duration(seconds: 45),
        onTimeout: () => Left(ServerFailure('Request timeout')),
      );

      if (categoriesResult.isRight() && tabsResult.isRight()) {
        final categories = categoriesResult.getOrElse(() => []);
        final tabs = tabsResult.getOrElse(() => []);
        
        emit(SearchLoaded(
          categories: categories,
          tabs: tabs,
          loadingSubcategories: const {},
        ));
      } else if (categoriesResult.isRight() && tabsResult.isLeft()) {
        // If tabs failed but categories succeeded, derive tabs from categories
        // to keep IDs consistent (numeric IDs) and allow subcategories to load.
        final categories = categoriesResult.getOrElse(() => []);
        final List<SearchTab> derivedTabs = categories.asMap().entries.map((entry) {
          final idx = entry.key;
          final c = entry.value;
          return SearchTab(
            id: c.id,
            title: c.title,
            isSelected: idx == 0,
            sortOrder: c.sortOrder,
          );
        }).toList();

        emit(SearchLoaded(
          categories: categories,
          tabs: derivedTabs,
          loadingSubcategories: const {},
        ));
      } else {
        final errorMessage = categoriesResult.fold(
          (failure) => failure.toString(),
          (_) => tabsResult.fold(
            (failure) => failure.toString(),
            (_) => 'Failed to load search data',
          ),
        );
        emit(SearchError(errorMessage));
      }
    } catch (e) {
      emit(SearchError('Failed to load search data: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSubcategories(
    LoadSubcategories event,
    Emitter<SearchState> emit,
  ) async {
    if (state is! SearchLoaded) return;

    final currentState = state as SearchLoaded;

    // Guard against duplicate loads that are currently in-flight (can happen due to tab rebuilds + refresh).
    // IMPORTANT: We intentionally do NOT short‑circuit when subcategories already exist
    // because the user may be explicitly tapping "Refresh" to retry a failed/empty load.
    if (currentState.loadingSubcategories.contains(event.categoryId)) {
      return;
    }

    // Add to loading set
    final updatedLoadingSet = Set<String>.from(currentState.loadingSubcategories)
      ..add(event.categoryId);

    emit(currentState.copyWith(loadingSubcategories: updatedLoadingSet));
    
    // Always hit the API so that manual refresh truly reloads data.
    final result = await _getSubcategories(event.categoryId);
    final latest = state;
    if (latest is! SearchLoaded) return;
    result.fold(
      (failure) {
        // Remove from loading set
        final errorLoadingSet = Set<String>.from(latest.loadingSubcategories)
          ..remove(event.categoryId);
        emit(latest.copyWith(loadingSubcategories: errorLoadingSet));
        emit(SearchError(failure.toString()));
      },
      (subcategories) {
        // Create updated subcategories map
        final updatedSubcategories = Map<String, List<SearchSubcategory>>.from(latest.subcategories)
          ..[event.categoryId] = subcategories;

        final completedLoadingSet = Set<String>.from(latest.loadingSubcategories)
          ..remove(event.categoryId);

        emit(latest.copyWith(
          subcategories: updatedSubcategories,
          loadingSubcategories: completedLoadingSet,
        ));
      },
    );
  }

  Future<void> _onSelectSearchTab(
    SelectSearchTab event,
    Emitter<SearchState> emit,
  ) async {
    if (state is! SearchLoaded) return;
    
    final currentState = state as SearchLoaded;
    
    // Update the repository
    await _searchRepository.updateSelectedTab(event.tabId);
    
    // Update local state
    final updatedTabs = currentState.tabs.map((tab) {
      return tab.copyWith(isSelected: tab.id == event.tabId);
    }).toList();
    
    emit(currentState.copyWith(
      tabs: updatedTabs,
      selectedTabId: event.tabId,
    ));
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final searchQuery = event.params.searchTerm ?? '';
      _lastSearchQuery = searchQuery;
      
      print('SearchBloc - Starting search for: "$searchQuery"');
      emit(ProductSearchLoading(searchQuery: searchQuery));
      
      // Add timeout to prevent hanging
      final result = await _searchProductsUseCase(event.params)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        print('SearchBloc - Search timeout after 30 seconds');
        throw Exception('Search request timed out');
      });
      
      result.fold(
        (failure) {
          print('SearchBloc - Search failed: ${failure.message}');
          emit(ProductSearchError(
            message: failure.message,
            searchQuery: searchQuery,
          ));
        },
        (results) {
          print('SearchBloc - Search completed: ${results.products.length} results');
          emit(ProductSearchLoaded(
            results: results,
            searchQuery: searchQuery,
          ));
        },
      );
    } catch (e) {
      print('SearchBloc - Search exception: ${e.toString()}');
      final searchQuery = event.params.searchTerm ?? '';
      emit(ProductSearchError(
        message: 'Search failed: ${e.toString()}',
        searchQuery: searchQuery,
      ));
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) async {
    _lastSearchQuery = null;
    
    // Return to initial state and reload data
    emit(SearchLoading());
    
    try {
      final categoriesResult = await _getSearchCategories(const NoParams()).timeout(
        const Duration(seconds: 45),
        onTimeout: () => Left(ServerFailure('Request timeout')),
      );
      final tabsResult = await _getSearchTabs(const NoParams()).timeout(
        const Duration(seconds: 45),
        onTimeout: () => Left(ServerFailure('Request timeout')),
      );

      if (categoriesResult.isRight() && tabsResult.isRight()) {
        final categories = categoriesResult.getOrElse(() => []);
        final tabs = tabsResult.getOrElse(() => []);
        
        emit(SearchLoaded(
          categories: categories,
          tabs: tabs,
          loadingSubcategories: const {},
        ));
      } else if (categoriesResult.isRight() && tabsResult.isLeft()) {
        final categories = categoriesResult.getOrElse(() => []);
        final List<SearchTab> derivedTabs = categories.asMap().entries.map((entry) {
          final idx = entry.key;
          final c = entry.value;
          return SearchTab(
            id: c.id,
            title: c.title,
            isSelected: idx == 0,
            sortOrder: c.sortOrder,
          );
        }).toList();

        emit(SearchLoaded(
          categories: categories,
          tabs: derivedTabs,
          loadingSubcategories: const {},
        ));
      } else {
        emit(SearchError('Failed to load search data'));
      }
    } catch (e) {
      emit(SearchError('Failed to load search data: ${e.toString()}'));
    }
  }

  Future<void> _onRetrySearch(
    RetrySearch event,
    Emitter<SearchState> emit,
  ) async {
    if (_lastSearchQuery != null) {
      print('SearchBloc - Retrying search for: "$_lastSearchQuery"');
      add(SearchProducts(SearchParams(searchTerm: _lastSearchQuery!)));
    }
  }

  Future<void> _onLoadNestedSubcategories(
    LoadNestedSubcategories event,
    Emitter<SearchState> emit,
  ) async {
    if (state is! SearchLoaded) return;
    
    final currentState = state as SearchLoaded;
    
    // Add to loading set
    final updatedLoadingSet = Set<String>.from(currentState.loadingSubcategories);
    updatedLoadingSet.add(event.subcategoryId);
    
    emit(currentState.copyWith(
      loadingSubcategories: updatedLoadingSet,
    ));
    
    final result = await _getSubcategories(event.subcategoryId);
    result.fold(
      (failure) {
        // Remove from loading set and show error
        final errorLoadingSet = Set<String>.from(currentState.loadingSubcategories);
        errorLoadingSet.remove(event.subcategoryId);
        
        emit(currentState.copyWith(
          loadingSubcategories: errorLoadingSet,
        ));
        emit(SearchError(failure.toString()));
      },
      (subcategories) {
        // Create updated subcategories map
        final updatedSubcategories = <String, List<SearchSubcategory>>{};
        
        // Copy all existing subcategories
        for (final entry in currentState.subcategories.entries) {
          updatedSubcategories[entry.key] = entry.value;
        }
        
        // Add the new subcategories
        updatedSubcategories[event.subcategoryId] = subcategories;
        
        // Remove from loading set
        final completedLoadingSet = Set<String>.from(currentState.loadingSubcategories);
        completedLoadingSet.remove(event.subcategoryId);
        
        emit(currentState.copyWith(
          subcategories: updatedSubcategories,
          loadingSubcategories: completedLoadingSet,
        ));
      },
    );
  }

  Future<void> _onLoadAllSubcategories(
    LoadAllSubcategories event,
    Emitter<SearchState> emit,
  ) async {
    if (state is! SearchLoaded) return;
    
    final currentState = state as SearchLoaded;
    
    // Load subcategories for all categories that don't have them yet
    final categoriesToLoad = currentState.categories
        .where((category) =>
            !currentState.subcategories.containsKey(category.id) &&
            !currentState.loadingSubcategories.contains(category.id))
        .map((category) => category.id)
        .toList();
    
    if (categoriesToLoad.isEmpty) return;
    
    // Add all categories to loading set
    final updatedLoadingSet = Set<String>.from(currentState.loadingSubcategories);
    for (final categoryId in categoriesToLoad) {
      updatedLoadingSet.add(categoryId);
    }
    
    emit(currentState.copyWith(
      loadingSubcategories: updatedLoadingSet,
    ));
    
    // Load subcategories for each category
    final updatedSubcategories = <String, List<SearchSubcategory>>{};
    
    // Copy all existing subcategories
    for (final entry in currentState.subcategories.entries) {
      updatedSubcategories[entry.key] = entry.value;
    }
    
    // Load new subcategories
    for (final categoryId in categoriesToLoad) {
      final result = await _getSubcategories(categoryId);
      result.fold(
        (failure) {
          // Remove from loading set
          updatedLoadingSet.remove(categoryId);
        },
        (subcategories) {
          // Add the new subcategories
          updatedSubcategories[categoryId] = subcategories;
          // Remove from loading set
          updatedLoadingSet.remove(categoryId);
        },
      );
    }
    
    emit(currentState.copyWith(
      subcategories: updatedSubcategories,
      loadingSubcategories: updatedLoadingSet,
    ));
  }
}