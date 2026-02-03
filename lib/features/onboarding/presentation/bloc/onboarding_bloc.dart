import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_onboarding_status.dart';
import '../../domain/usecases/complete_onboarding.dart' as domain;
import '../../domain/repositories/onboarding_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CheckOnboardingStatus checkOnboardingStatus;
  final domain.CompleteOnboarding completeOnboarding;
  final OnboardingRepository onboardingRepository;

  OnboardingBloc({
    required this.checkOnboardingStatus,
    required this.completeOnboarding,
    required this.onboardingRepository,
  }) : super(OnboardingInitial()) {
    on<LoadOnboardingPages>(_onLoadOnboardingPages);
    on<NextPage>(_onNextPage);
    on<PreviousPage>(_onPreviousPage);
    on<SetPageIndex>(_onSetPageIndex);
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
    on<SkipOnboarding>(_onSkipOnboarding);
  }

  Future<void> _onLoadOnboardingPages(
    LoadOnboardingPages event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());
    
    try {
      final pagesResult = await onboardingRepository.getOnboardingPages();
      pagesResult.fold(
        (failure) => emit(OnboardingError(failure.toString())),
        (pages) => emit(OnboardingLoaded(pages: pages, currentPageIndex: 0)),
      );
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  void _onNextPage(
    NextPage event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is! OnboardingLoaded) return;
    final currentState = state as OnboardingLoaded;
    final nextIndex = currentState.currentPageIndex + 1;
    if (nextIndex < currentState.pages.length) {
      emit(currentState.copyWith(currentPageIndex: nextIndex));
    }
  }

  void _onPreviousPage(
    PreviousPage event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is! OnboardingLoaded) return;
    final currentState = state as OnboardingLoaded;
    final prevIndex = currentState.currentPageIndex - 1;
    if (prevIndex >= 0) {
      emit(currentState.copyWith(currentPageIndex: prevIndex));
    }
  }

  void _onSetPageIndex(
    SetPageIndex event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is! OnboardingLoaded) return;
    final currentState = state as OnboardingLoaded;
    final bounded = event.index.clamp(0, currentState.pages.length - 1);
    if (bounded != currentState.currentPageIndex) {
      emit(currentState.copyWith(currentPageIndex: bounded));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      final result = await completeOnboarding(const NoParams());
      result.fold(
        (failure) => emit(OnboardingError(failure.toString())),
        (_) => emit(OnboardingCompleted()),
      );
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onSkipOnboarding(
    SkipOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      final result = await completeOnboarding(const NoParams());
      result.fold(
        (failure) => emit(OnboardingError(failure.toString())),
        (_) => emit(OnboardingCompleted()),
      );
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }
}
