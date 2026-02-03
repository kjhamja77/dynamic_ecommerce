import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/filter_criteria.dart';
import '../domain/entities/filter_category.dart';

class FiltersState {
  final FilterCriteria criteria;
  final Map<int, List<FilterCategory>> subcategories; // parentId -> subcategories
  const FiltersState(this.criteria, {this.subcategories = const {}});
}

class FiltersCubit extends Cubit<FiltersState> {
  FiltersCubit(FilterCriteria initial) : super(FiltersState(initial));

  void update(FilterCriteria criteria) => emit(FiltersState(criteria, subcategories: state.subcategories));

  void toggleOnSale() => emit(FiltersState(state.criteria.copyWith(onSale: !state.criteria.onSale), subcategories: state.subcategories));
  void toggleInStock() => emit(FiltersState(state.criteria.copyWith(inStock: !state.criteria.inStock), subcategories: state.subcategories));
  void setMinPrice(double? v) => emit(FiltersState(state.criteria.copyWith(minPrice: v), subcategories: state.subcategories));
  void setMaxPrice(double? v) => emit(FiltersState(state.criteria.copyWith(maxPrice: v), subcategories: state.subcategories));
  void setMinRating(double? v) => emit(FiltersState(state.criteria.copyWith(minRating: v), subcategories: state.subcategories));
  void setBrand(String? v) => emit(FiltersState(state.criteria.copyWith(brand: v), subcategories: state.subcategories));
  void setCategory(String? v) => emit(FiltersState(state.criteria.copyWith(category: v), subcategories: state.subcategories));
  void setBrandIds(List<int> v) => emit(FiltersState(state.criteria.copyWith(brandIds: v, brand: null), subcategories: state.subcategories));
  void setCategoryIds(List<int> v) => emit(FiltersState(state.criteria.copyWith(categoryIds: v, category: null), subcategories: state.subcategories));
  void setSizes(List<String> v) => emit(FiltersState(state.criteria.copyWith(sizes: v), subcategories: state.subcategories));
  void setColors(List<String> v) => emit(FiltersState(state.criteria.copyWith(colors: v), subcategories: state.subcategories));
  void setMaterials(List<String> v) => emit(FiltersState(state.criteria.copyWith(materials: v), subcategories: state.subcategories));
  void setSeasons(List<String> v) => emit(FiltersState(state.criteria.copyWith(seasons: v), subcategories: state.subcategories));
  void setGenders(List<String> v) => emit(FiltersState(state.criteria.copyWith(genders: v), subcategories: state.subcategories));
  
  void setSubcategories(int parentId, List<FilterCategory> subcategories) {
    final updated = Map<int, List<FilterCategory>>.from(state.subcategories);
    updated[parentId] = subcategories;
    emit(FiltersState(state.criteria, subcategories: updated));
  }
  
  void clearSubcategories(int parentId) {
    final updated = Map<int, List<FilterCategory>>.from(state.subcategories);
    updated.remove(parentId);
    emit(FiltersState(state.criteria, subcategories: updated));
  }
}


