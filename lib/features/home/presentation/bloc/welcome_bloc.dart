import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_welcome_texts_usecase.dart';

// Events
abstract class WelcomeEvent extends Equatable {
  const WelcomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadWelcomeTexts extends WelcomeEvent {}
class RefreshWelcomeTexts extends WelcomeEvent {}

class UpdateCurrentIndexEvent extends WelcomeEvent {
  final int index;

  const UpdateCurrentIndexEvent(this.index);

  @override
  List<Object> get props => [index];
}

// States
abstract class WelcomeState extends Equatable {
  const WelcomeState();

  @override
  List<Object?> get props => [];
}

class WelcomeInitial extends WelcomeState {}

class WelcomeLoading extends WelcomeState {}

class WelcomeLoaded extends WelcomeState {
  final List<String> messages;
  final int currentIndex;

  const WelcomeLoaded({
    required this.messages,
    this.currentIndex = 0,
  });

  WelcomeLoaded copyWith({
    List<String>? messages,
    int? currentIndex,
  }) {
    return WelcomeLoaded(
      messages: messages ?? this.messages,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [messages, currentIndex];
}

class WelcomeError extends WelcomeState {
  final String message;

  const WelcomeError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  final GetWelcomeTextsUseCase getWelcomeTextsUseCase;

  WelcomeBloc({
    required this.getWelcomeTextsUseCase,
  }) : super(WelcomeInitial()) {
    on<LoadWelcomeTexts>(_onLoadWelcomeTexts);
    on<RefreshWelcomeTexts>(_onRefreshWelcomeTexts);
    on<UpdateCurrentIndexEvent>(_onUpdateCurrentIndex);
  }

  Future<void> _onLoadWelcomeTexts(
    LoadWelcomeTexts event,
    Emitter<WelcomeState> emit,
  ) async {
    emit(WelcomeLoading());

    final result = await getWelcomeTextsUseCase();
    
    result.fold(
      (failure) => emit(WelcomeError(failure.message)),
      (messages) => emit(WelcomeLoaded(messages: messages)),
    );
  }

  Future<void> _onRefreshWelcomeTexts(
    RefreshWelcomeTexts event,
    Emitter<WelcomeState> emit,
  ) async {
    // Preserve current messages while we refresh from the API
    final previousState = state;
    if (previousState is WelcomeLoaded) {
      emit(WelcomeLoading());
    }

    final result = await getWelcomeTextsUseCase(forceRefresh: true);

    result.fold(
      (failure) => emit(WelcomeError(failure.message)),
      (messages) => emit(WelcomeLoaded(messages: messages)),
    );
  }

  void _onUpdateCurrentIndex(
    UpdateCurrentIndexEvent event,
    Emitter<WelcomeState> emit,
  ) {
    if (state is WelcomeLoaded) {
      final currentState = state as WelcomeLoaded;
      emit(currentState.copyWith(currentIndex: event.index));
    }
  }

  void updateCurrentIndex(int index) {
    if (state is WelcomeLoaded) {
      add(UpdateCurrentIndexEvent(index));
    }
  }
}
