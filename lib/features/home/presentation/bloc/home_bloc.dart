import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/page.dart';
import '../../domain/entities/component.dart';


import '../../domain/usecases/get_featured_products_usecase.dart';
import '../../domain/usecases/get_pages_usecase.dart';
import '../../domain/usecases/get_page_components_usecase.dart';
import '../../../product/domain/usecases/get_root_categories.dart';
import '../../../../core/services/app_localization_service.dart';
import '../../../../core/services/language_service.dart';
import 'dart:async';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeaturedProducts extends HomeEvent {}

class LoadCategories extends HomeEvent {}

class LoadPages extends HomeEvent {
  final int userId;

  const LoadPages(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadPageComponents extends HomeEvent {
  final int componentId;
  final int page;
  final int pageSize;

  const LoadPageComponents({
    required this.componentId,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object> get props => [componentId, page, pageSize];
}

class SearchProducts extends HomeEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object> get props => [query];
}

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Product> featuredProducts;
  final List<String> categories;
  final List<Page> pages;
  final Map<int, PageComponents> componentsByPageId;
  final List<Product> searchResults;
  final bool hasReachedMax;
  final bool isFetchingPages;
  final bool isFetchingComponents;
  final int? fetchingComponentsForPageId;

  const HomeLoaded({
    required this.featuredProducts,
    required this.categories,
    this.pages = const [],
    this.componentsByPageId = const {},
    this.searchResults = const [],
    this.hasReachedMax = false,
    this.isFetchingPages = false,
    this.isFetchingComponents = false,
    this.fetchingComponentsForPageId,
  });

  HomeLoaded copyWith({
    List<Product>? featuredProducts,
    List<String>? categories,
    List<Page>? pages,
    Map<int, PageComponents>? componentsByPageId,
    List<Product>? searchResults,
    bool? hasReachedMax,
    bool? isFetchingPages,
    bool? isFetchingComponents,
    int? fetchingComponentsForPageId,
  }) {
    return HomeLoaded(
      featuredProducts: featuredProducts ?? this.featuredProducts,
      categories: categories ?? this.categories,
      pages: pages ?? this.pages,
      componentsByPageId: componentsByPageId ?? this.componentsByPageId,
      searchResults: searchResults ?? this.searchResults,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingPages: isFetchingPages ?? this.isFetchingPages,
      isFetchingComponents: isFetchingComponents ?? this.isFetchingComponents,
      fetchingComponentsForPageId: fetchingComponentsForPageId ?? this.fetchingComponentsForPageId,
    );
  }

  @override
  List<Object?> get props => [
        featuredProducts,
        categories,
        pages,
        componentsByPageId,
        searchResults,
        hasReachedMax,
        isFetchingPages,
        isFetchingComponents,
        fetchingComponentsForPageId,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetFeaturedProductsUseCase getFeaturedProductsUseCase;
  final GetPagesUseCase getPagesUseCase;
  final GetPageComponentsUseCase getPageComponentsUseCase;
  final GetRootCategoriesUseCase getRootCategoriesUseCase;

  // Throttle search to avoid emitting too frequently and causing UI jank
  DateTime? _lastSearchAt;
  String _lastQuery = '';

  HomeBloc({
    required this.getFeaturedProductsUseCase,
    required this.getPagesUseCase,
    required this.getPageComponentsUseCase,
    required this.getRootCategoriesUseCase,
  })  :
        super(HomeInitial()) {
    on<LoadFeaturedProducts>(_onLoadFeaturedProducts);
    on<LoadCategories>(_onLoadCategories);
    on<LoadPages>(_onLoadPages);
    on<LoadPageComponents>(_onLoadPageComponents);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onLoadFeaturedProducts(
    LoadFeaturedProducts event,
    Emitter<HomeState> emit,
  ) async {
    // Always emit a loading state while fetching featured products so that
    // Home can show its skeleton loader even during refreshes (e.g. after
    // changing the locale). Preserve the previous data so we can restore
    // other fields when the load completes.
    final previousState = state;
    emit(HomeLoading());

    final result = await getFeaturedProductsUseCase(NoParams());

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (products) {
        // If we had a HomeLoaded state before loading, restore its fields
        // while updating only the featuredProducts list. Otherwise, create
        // a fresh HomeLoaded state.
        if (previousState is HomeLoaded) {
          emit(previousState.copyWith(featuredProducts: products));
        } else {
          emit(HomeLoaded(
            featuredProducts: products,
            categories: const [],
            componentsByPageId: const {},
          ));
        }
        // Load categories after products are loaded
        // This ensures proper state management
        add(LoadCategories());
      },
    );
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Use real category API to get root categories
      final result = await getRootCategoriesUseCase(GetRootCategoriesParams(maxDepth: 1));
      
      result.fold(
        (failure) {
          // On error, use empty categories list but don't crash the UI
          if (state is HomeLoaded) {
            final currentState = state as HomeLoaded;
            emit(currentState.copyWith(categories: []));
          }
        },
        (categories) {
          // Convert ProductCategory entities to simple string names
          final categoryNames = categories.map((category) => category.name).toList();
          
          if (state is HomeLoaded) {
            final currentState = state as HomeLoaded;
            emit(currentState.copyWith(categories: categoryNames));
          }
        },
      );
    } catch (e) {
      // Fallback to empty categories on exception
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(currentState.copyWith(categories: []));
      }
    }
  }

  Future<void> _onLoadPages(
    LoadPages event,
    Emitter<HomeState> emit,
  ) async {
    var currentState = state;

    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(isFetchingPages: true));
    } else {
      // If not in HomeLoaded state, emit HomeLoading first
      emit(HomeLoading());
    }

    final result = await getPagesUseCase(GetPagesParams(userId: event.userId));
    currentState = state; // re-read after await

    result.fold(
      (failure) {
        if (currentState is HomeLoaded) {
          emit(currentState.copyWith(isFetchingPages: false));
        } else {
          emit(HomeError(failure.message));
        }
      },
      (pages) {
        if (currentState is HomeLoaded) {
          emit(currentState.copyWith(pages: pages, isFetchingPages: false));
        } else {
          emit(HomeLoaded(
            featuredProducts: const [],
            categories: const [],
            pages: pages,
            isFetchingPages: false,
            componentsByPageId: const {},
          ));
        }
      },
    );
  }

  Future<void> _onLoadPageComponents(
    LoadPageComponents event,
    Emitter<HomeState> emit,
  ) async {
    debugPrint('🔄 HomeBloc:_onLoadPageComponents → componentId: ${event.componentId}, page: ${event.page}, pageSize: ${event.pageSize}');
    
    // Ensure API language is synced with current app language before loading page components
    try {
      final localizationService = AppLocalizationService();
      final currentLanguage = localizationService.currentLocale.languageCode;
      await LanguageService().setFromAppLanguageCode(currentLanguage);
      debugPrint('🌐 HomeBloc:_onLoadPageComponents → Synced API language to: $currentLanguage');
    } catch (e) {
      debugPrint('⚠️ HomeBloc:_onLoadPageComponents → Error syncing language: $e');
    }
    
    var currentState = state;
    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(isFetchingComponents: true, fetchingComponentsForPageId: event.componentId));
    }
    final result = await getPageComponentsUseCase(GetPageComponentsParams(
      componentId: event.componentId,
      page: event.page,
      pageSize: event.pageSize,
    ));
    currentState = state; // re-read after await

    result.fold(
      (failure) {
        debugPrint('❌ HomeBloc:_onLoadPageComponents → Failed: ${failure.message}');
        if (currentState is HomeLoaded) {
          emit(currentState.copyWith(isFetchingComponents: false, fetchingComponentsForPageId: null));
        } else {
          emit(HomeError(failure.message));
        }
      },
      (pageComponents) {
        debugPrint('✅ HomeBloc:_onLoadPageComponents → Success: ${pageComponents.pageComponents.length} components for page ${event.componentId}');
        if (currentState is HomeLoaded) {
          final Map<int, PageComponents> next = Map<int, PageComponents>.from(currentState.componentsByPageId);
          next[event.componentId] = pageComponents;
          emit(currentState.copyWith(
            componentsByPageId: next,
            isFetchingComponents: false,
            fetchingComponentsForPageId: null,
          ));
        } else {
          emit(HomeLoaded(
            featuredProducts: const [],
            categories: const [],
            componentsByPageId: {event.componentId: pageComponents},
            isFetchingComponents: false,
          ));
        }
      },
    );
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    final String raw = event.query;
    final String query = raw.trim();

    // If empty: clear results and short-circuit
    if (query.isEmpty) {
      if (currentState.searchResults.isNotEmpty) {
        emit(currentState.copyWith(searchResults: []));
      }
      _lastQuery = '';
      return;
    }

    // Throttle: ignore if last search was very recent with the same query
    final DateTime now = DateTime.now();
    final bool tooSoon = _lastSearchAt != null && now.difference(_lastSearchAt!) < const Duration(milliseconds: 200);
    final bool sameQuery = _lastQuery == query;
    if (tooSoon && sameQuery) {
      return;
    }
    _lastSearchAt = now;
    _lastQuery = query;

    // Perform local search on featured products (replace with repo when available)
    final String q = query.toLowerCase();
    final List<Product> searchResults = currentState.featuredProducts.where((product) {
      final name = product.name.toLowerCase();
      final brand = product.brand.toLowerCase();
      final category = product.category.toLowerCase();
      return name.contains(q) || brand.contains(q) || category.contains(q);
    }).toList();

    // Emit without switching to a loading state to avoid blinking
    emit(currentState.copyWith(searchResults: searchResults));
  }
}
