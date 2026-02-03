import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_terms_conditions.dart';
import 'terms_conditions_event.dart';
import 'terms_conditions_state.dart';

class TermsConditionsBloc extends Bloc<TermsConditionsEvent, TermsConditionsState> {
  final GetTermsConditions getTermsConditions;

  TermsConditionsBloc({
    required this.getTermsConditions,
  }) : super(TermsConditionsInitial()) {
    on<LoadTermsConditions>(_onLoadTermsConditions);
  }

  Future<void> _onLoadTermsConditions(
    LoadTermsConditions event,
    Emitter<TermsConditionsState> emit,
  ) async {
    emit(TermsConditionsLoading());

    try {
      final result = await getTermsConditions();
      emit(TermsConditionsLoaded(termsConditions: result));
    } catch (e) {
      emit(TermsConditionsError(message: e.toString()));
    }
  }
}
