import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../filters/domain/entities/filter_criteria.dart';
import '../../../filters/domain/entities/filter_category.dart';
import 'filters_event.dart';
import 'filters_state.dart';

/// BLoC for managing filter state
class FiltersBloc extends Bloc<FiltersEvent, FiltersState> {
  FiltersBloc(FilterCriteria initialCriteria)
      : super(FiltersLoaded(
          criteria: initialCriteria,
          subcategories: const {},
        )) {
    on<FiltersInitialized>(_onInitialized);
    on<FiltersCriteriaUpdated>(_onCriteriaUpdated);
    on<FiltersOnSaleToggled>(_onOnSaleToggled);
    on<FiltersInStockToggled>(_onInStockToggled);
    on<FiltersMinPriceSet>(_onMinPriceSet);
    on<FiltersMaxPriceSet>(_onMaxPriceSet);
    on<FiltersMinRatingSet>(_onMinRatingSet);
    on<FiltersBrandSet>(_onBrandSet);
    on<FiltersCategorySet>(_onCategorySet);
    on<FiltersBrandIdsSet>(_onBrandIdsSet);
    on<FiltersCategoryIdsSet>(_onCategoryIdsSet);
    on<FiltersSizesSet>(_onSizesSet);
    on<FiltersColorsSet>(_onColorsSet);
    on<FiltersMaterialsSet>(_onMaterialsSet);
    on<FiltersSeasonsSet>(_onSeasonsSet);
    on<FiltersGendersSet>(_onGendersSet);
    on<FiltersSubcategoriesSet>(_onSubcategoriesSet);
    on<FiltersSubcategoriesCleared>(_onSubcategoriesCleared);
    on<FiltersCleared>(_onCleared);
    on<FiltersSortFieldSet>(_onSortFieldSet);
    on<FiltersSortOrderSet>(_onSortOrderSet);
    on<FiltersLimitSet>(_onLimitSet);
    on<FiltersExtraAttributesSet>(_onExtraAttributesSet);
  }

  void _onInitialized(
    FiltersInitialized event,
    Emitter<FiltersState> emit,
  ) {
    emit(FiltersLoaded(
      criteria: event.initialCriteria,
      subcategories: const {},
    ));
  }

  void _onCriteriaUpdated(
    FiltersCriteriaUpdated event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(criteria: event.criteria));
    }
  }

  void _onOnSaleToggled(
    FiltersOnSaleToggled event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(
          onSale: !currentState.criteria.onSale,
        ),
      ));
    }
  }

  void _onInStockToggled(
    FiltersInStockToggled event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(
          inStock: !currentState.criteria.inStock,
        ),
      ));
    }
  }

  void _onMinPriceSet(
    FiltersMinPriceSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(minPrice: event.minPrice),
      ));
    }
  }

  void _onMaxPriceSet(
    FiltersMaxPriceSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(maxPrice: event.maxPrice),
      ));
    }
  }

  void _onMinRatingSet(
    FiltersMinRatingSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(minRating: event.minRating),
      ));
    }
  }

  void _onBrandSet(
    FiltersBrandSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(brand: event.brand),
      ));
    }
  }

  void _onCategorySet(
    FiltersCategorySet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(category: event.category),
      ));
    }
  }

  void _onBrandIdsSet(
    FiltersBrandIdsSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(
          brandIds: event.brandIds,
          brand: null,
        ),
      ));
    }
  }

  void _onCategoryIdsSet(
    FiltersCategoryIdsSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(
          categoryIds: event.categoryIds,
          category: null,
        ),
      ));
    }
  }

  void _onSizesSet(
    FiltersSizesSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(sizes: event.sizes),
      ));
    }
  }

  void _onColorsSet(
    FiltersColorsSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(colors: event.colors),
      ));
    }
  }

  void _onMaterialsSet(
    FiltersMaterialsSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(materials: event.materials),
      ));
    }
  }

  void _onSeasonsSet(
    FiltersSeasonsSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(seasons: event.seasons),
      ));
    }
  }

  void _onGendersSet(
    FiltersGendersSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(genders: event.genders),
      ));
    }
  }

  void _onSubcategoriesSet(
    FiltersSubcategoriesSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      final updatedSubcategories = Map<int, List<FilterCategory>>.from(
        currentState.subcategories,
      );
      updatedSubcategories[event.parentId] = event.subcategories;
      emit(currentState.copyWith(subcategories: updatedSubcategories));
    }
  }

  void _onSubcategoriesCleared(
    FiltersSubcategoriesCleared event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      final updatedSubcategories = Map<int, List<FilterCategory>>.from(
        currentState.subcategories,
      );
      updatedSubcategories.remove(event.parentId);
      emit(currentState.copyWith(subcategories: updatedSubcategories));
    }
  }

  void _onCleared(
    FiltersCleared event,
    Emitter<FiltersState> emit,
  ) {
    emit(const FiltersLoaded(
      criteria: FilterCriteria(),
      subcategories: {},
    ));
  }

  void _onSortFieldSet(
    FiltersSortFieldSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(
          sortByField: event.sortByField,
        ),
      ));
    }
  }

  void _onSortOrderSet(
    FiltersSortOrderSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(
          sortOrder: event.sortOrder,
        ),
      ));
    }
  }

  void _onLimitSet(
    FiltersLimitSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(limit: event.limit),
      ));
    }
  }

  void _onExtraAttributesSet(
    FiltersExtraAttributesSet event,
    Emitter<FiltersState> emit,
  ) {
    if (state is FiltersLoaded) {
      final currentState = state as FiltersLoaded;
      emit(currentState.copyWith(
        criteria: currentState.criteria.copyWith(
          extraAttributes: event.extraAttributes,
        ),
      ));
    }
  }
}

