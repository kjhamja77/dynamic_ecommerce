import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/filter_criteria.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/entities/filter_category.dart';
import '../../domain/entities/filter_brand.dart';
import '../../domain/entities/filter_attribute.dart';
import '../../domain/repositories/filter_repository.dart';
import '../../../../core/errors/failures.dart';

// Events
abstract class FilterEvent extends Equatable {
  const FilterEvent();

  @override
  List<Object?> get props => [];
}

class LoadFilterOptions extends FilterEvent {
  final String? category;
  final String? brand;
  final String? query;

  const LoadFilterOptions({
    this.category,
    this.brand,
    this.query,
  });

  @override
  List<Object?> get props => [category, brand, query];
}

class LoadCategories extends FilterEvent {
  final int page;
  final int limit;
  final int? parentId;

  const LoadCategories({
    this.page = 1,
    this.limit = 6,
    this.parentId,
  });

  @override
  List<Object?> get props => [page, limit, parentId];
}

class LoadBrands extends FilterEvent {
  final int page;
  final int limit;

  const LoadBrands({
    this.page = 1,
    this.limit = 7,
  });

  @override
  List<Object?> get props => [page, limit];
}

class LoadAttributes extends FilterEvent {
  final int page;
  final int limit;
  final List<int>? categoryIds;

  const LoadAttributes({
    this.page = 1,
    this.limit = 50,
    this.categoryIds,
  });

  @override
  List<Object?> get props => [page, limit, categoryIds];
}

class ApplyFilters extends FilterEvent {
  final FilterCriteria criteria;

  const ApplyFilters(this.criteria);

  @override
  List<Object?> get props => [criteria];
}

class UpdateFilterCriteria extends FilterEvent {
  final FilterCriteria criteria;

  const UpdateFilterCriteria(this.criteria);

  @override
  List<Object?> get props => [criteria];
}

class ClearFilters extends FilterEvent {}

// States
abstract class FilterState extends Equatable {
  const FilterState();

  @override
  List<Object?> get props => [];
}

class FilterInitial extends FilterState {}

class FilterLoading extends FilterState {}

class FilterOptionsLoaded extends FilterState {
  final FilterOptions options;
  final FilterCriteria currentCriteria;

  const FilterOptionsLoaded({
    required this.options,
    required this.currentCriteria,
  });

  @override
  List<Object?> get props => [options, currentCriteria];
}

class CategoriesLoaded extends FilterState {
  final List<FilterCategory> categories;
  final bool hasMore;

  const CategoriesLoaded({
    required this.categories,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [categories, hasMore];
}

class BrandsLoaded extends FilterState {
  final List<FilterBrand> brands;
  final bool hasMore;

  const BrandsLoaded({
    required this.brands,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [brands, hasMore];
}

class AttributesLoaded extends FilterState {
  final List<FilterAttribute> attributes;
  final bool hasMore;

  const AttributesLoaded({
    required this.attributes,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [attributes, hasMore];
}

class FilterProductsLoading extends FilterState {}

class FilterProductsLoaded extends FilterState {
  final Map<String, dynamic> results;
  final FilterCriteria appliedCriteria;

  const FilterProductsLoaded({
    required this.results,
    required this.appliedCriteria,
  });

  @override
  List<Object?> get props => [results, appliedCriteria];
}

class FilterEmpty extends FilterState {
  final String message;

  const FilterEmpty({required this.message});

  @override
  List<Object?> get props => [message];
}

class FilterError extends FilterState {
  final String message;

  const FilterError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class FilterBloc extends Bloc<FilterEvent, FilterState> {
  final FilterRepository repository;
  FilterCriteria _currentCriteria = const FilterCriteria();

  FilterBloc({required this.repository}) : super(FilterInitial()) {
    on<LoadFilterOptions>(_onLoadFilterOptions);
    on<LoadCategories>(_onLoadCategories);
    on<LoadBrands>(_onLoadBrands);
    on<LoadAttributes>(_onLoadAttributes);
    on<ApplyFilters>(_onApplyFilters);
    on<UpdateFilterCriteria>(_onUpdateFilterCriteria);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadFilterOptions(
    LoadFilterOptions event,
    Emitter<FilterState> emit,
  ) async {
    emit(FilterLoading());
    
    // Extract categoryId from current criteria if available (first selected category ID)
    final int? categoryId = _currentCriteria.categoryIds.isNotEmpty 
        ? _currentCriteria.categoryIds.first 
        : null;
    
    // Load filter options (price range, etc.)
    final filterOptionsResult = await repository.getAvailableFilters(
      category: event.category,
      brand: event.brand,
      query: event.query,
      categoryId: categoryId, // Pass categoryId to fetch category-specific attributes
    );

    if (filterOptionsResult.isLeft()) {
      final failure = filterOptionsResult.fold((l) => l, (r) => throw Exception('Unexpected'));
      emit(FilterError(message: _mapFailureToMessage(failure)));
      return;
    }

    final filterOptions = filterOptionsResult.fold((l) => throw Exception('Unexpected'), (r) => r);
    
    // Load categories
    final categoriesResult = await repository.getCategories(page: 1, limit: 50);
    final categories = categoriesResult.fold(
      (failure) {
        emit(FilterError(message: 'Failed to load categories: ${failure.message}'));
        return <FilterCategory>[];
      },
      (categories) => categories,
    );

    // Load brands
    final brandsResult = await repository.getBrands(page: 1, limit: 50);
    final brands = brandsResult.fold(
      (failure) {
        emit(FilterError(message: 'Failed to load brands: ${failure.message}'));
        return <FilterBrand>[];
      },
      (brands) => brands,
    );

    // Load attributes
    final attributesResult = await repository.getAttributes(page: 1, limit: 50);
    final attributes = attributesResult.fold(
      (failure) {
        emit(FilterError(message: 'Failed to load attributes: ${failure.message}'));
        return <FilterAttribute>[];
      },
      (attributes) => attributes,
    );

    // Create complete FilterOptions with all loaded data
    if (filterOptions.priceRange == null) {
      emit(FilterError(message: 'Failed to load price range from API'));
      return;
    }
    
    final completeOptions = FilterOptions.withLoadedData(
      priceRange: filterOptions.priceRange!,
      categories: categories,
      brands: brands,
      attributes: attributes,
      availableSizes: filterOptions.availableSizes,
      availableColors: filterOptions.availableColors,
      availableMaterials: filterOptions.availableMaterials,
      availableSeasons: filterOptions.availableSeasons,
      availableGenders: filterOptions.availableGenders,
    );

    emit(FilterOptionsLoaded(
      options: completeOptions,
      currentCriteria: _currentCriteria,
    ));
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<FilterState> emit,
  ) async {
    emit(FilterLoading());
    
    final result = await repository.getCategories(
      page: event.page,
      limit: event.limit,
      parentId: event.parentId,
    );

    result.fold(
      (failure) => emit(FilterError(message: _mapFailureToMessage(failure))),
      (categories) => emit(CategoriesLoaded(
        categories: categories,
        hasMore: categories.length == event.limit,
      )),
    );
  }

  Future<void> _onLoadBrands(
    LoadBrands event,
    Emitter<FilterState> emit,
  ) async {
    emit(FilterLoading());
    
    final result = await repository.getBrands(
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(FilterError(message: _mapFailureToMessage(failure))),
      (brands) => emit(BrandsLoaded(
        brands: brands,
        hasMore: brands.length == event.limit,
      )),
    );
  }

  Future<void> _onLoadAttributes(
    LoadAttributes event,
    Emitter<FilterState> emit,
  ) async {
    emit(FilterLoading());
    
    final result = await repository.getAttributes(
      page: event.page,
      limit: event.limit,
      categoryIds: event.categoryIds,
    );

    result.fold(
      (failure) => emit(FilterError(message: _mapFailureToMessage(failure))),
      (attributes) => emit(AttributesLoaded(
        attributes: attributes,
        hasMore: attributes.length == event.limit,
      )),
    );
  }

  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<FilterState> emit,
  ) async {
    emit(FilterProductsLoading());
    
    _currentCriteria = event.criteria;
    
    final result = await repository.filterProducts(event.criteria);

    result.fold(
      (failure) => emit(FilterError(message: _mapFailureToMessage(failure))),
      (results) {
        if (results.isEmpty) {
          emit(const FilterEmpty(message: 'No products found matching your criteria'));
        } else {
          emit(FilterProductsLoaded(
            results: results,
            appliedCriteria: event.criteria,
          ));
        }
      },
    );
  }

  void _onUpdateFilterCriteria(
    UpdateFilterCriteria event,
    Emitter<FilterState> emit,
  ) {
    _currentCriteria = event.criteria;
    
    if (state is FilterOptionsLoaded) {
      final currentState = state as FilterOptionsLoaded;
      emit(FilterOptionsLoaded(
        options: currentState.options,
        currentCriteria: _currentCriteria,
      ));
    }
  }

  void _onClearFilters(
    ClearFilters event,
    Emitter<FilterState> emit,
  ) {
    _currentCriteria = const FilterCriteria();
    
    if (state is FilterOptionsLoaded) {
      final currentState = state as FilterOptionsLoaded;
      emit(FilterOptionsLoaded(
        options: currentState.options,
        currentCriteria: _currentCriteria,
      ));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  FilterCriteria get currentCriteria => _currentCriteria;
}
