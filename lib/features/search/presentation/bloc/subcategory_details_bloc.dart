import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_subcategory_details.dart';
import 'subcategory_details_event.dart';
import 'subcategory_details_state.dart';

class SubcategoryDetailsBloc extends Bloc<SubcategoryDetailsEvent, SubcategoryDetailsState> {
  final GetSubcategoryDetails _getSubcategoryDetails;

  SubcategoryDetailsBloc({
    required GetSubcategoryDetails getSubcategoryDetails,
  })  : _getSubcategoryDetails = getSubcategoryDetails,
        super(SubcategoryDetailsInitial()) {
    on<LoadSubcategoryDetails>(_onLoadSubcategoryDetails);
    on<NavigateToSubcategory>(_onNavigateToSubcategory);
  }

  Future<void> _onLoadSubcategoryDetails(
    LoadSubcategoryDetails event,
    Emitter<SubcategoryDetailsState> emit,
  ) async {
    emit(SubcategoryDetailsLoading());

    final result = await _getSubcategoryDetails(event.subcategoryId);
    result.fold(
      (failure) => emit(SubcategoryDetailsError(failure.toString())),
      (subcategoryDetails) => emit(SubcategoryDetailsLoaded(
        subcategoryDetails: subcategoryDetails,
      )),
    );
  }

  Future<void> _onNavigateToSubcategory(
    NavigateToSubcategory event,
    Emitter<SubcategoryDetailsState> emit,
  ) async {
    // This could trigger navigation logic or load new subcategory details
    emit(SubcategoryDetailsLoading());

    final result = await _getSubcategoryDetails(event.subcategoryId);
    result.fold(
      (failure) => emit(SubcategoryDetailsError(failure.toString())),
      (subcategoryDetails) => emit(SubcategoryDetailsLoaded(
        subcategoryDetails: subcategoryDetails,
      )),
    );
  }
}
