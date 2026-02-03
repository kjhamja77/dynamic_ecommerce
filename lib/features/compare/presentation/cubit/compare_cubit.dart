import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/entities/product.dart';

class CompareState {
  final List<Product> selected;
  const CompareState(this.selected);

  CompareState copyWith({List<Product>? selected}) => CompareState(selected ?? this.selected);
}

class CompareCubit extends Cubit<CompareState> {
  final int maxItems;
  CompareCubit({this.maxItems = 4}) : super(const CompareState([]));

  bool isSelected(String productId) => state.selected.any((p) => p.id == productId);

  void toggle(Product product) {
    final exists = isSelected(product.id);
    if (exists) {
      emit(CompareState(state.selected.where((p) => p.id != product.id).toList()));
    } else {
      if (state.selected.length >= maxItems) return;
      emit(CompareState([...state.selected, product]));
    }
  }

  void remove(String productId) {
    emit(CompareState(state.selected.where((p) => p.id != productId).toList()));
  }

  void clear() => emit(const CompareState([]));
}



