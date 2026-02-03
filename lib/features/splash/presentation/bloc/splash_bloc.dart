import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_app_initialization.dart';
import '../../domain/repositories/splash_repository.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final CheckAppInitialization checkAppInitialization;
  final SplashRepository splashRepository;

  SplashBloc({
    required this.checkAppInitialization,
    required this.splashRepository,
  }) : super(SplashInitial()) {
    on<InitializeApp>(_onInitializeApp);
    on<CheckInitializationStatus>(_onCheckInitializationStatus);
  }

  Future<void> _onInitializeApp(
    InitializeApp event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());
    
    try {
      // Simulate some initialization time
      await Future.delayed(const Duration(seconds: 2));
      
      // Check language selection first - this determines if it's first time opening
      final languageResult = await splashRepository.shouldShowLanguageSelection();
      
      await languageResult.fold(
        (failure) async => emit(SplashError(failure.toString())),
        (shouldShowLanguageSelection) async {
          if (shouldShowLanguageSelection) {
            // First time opening app - show language selection
            emit(const SplashInitialized(
              shouldShowOnboarding: false,
              shouldShowLanguageSelection: true,
            ));
            return;
          }
          
          // Language already selected - check if user is authenticated
          final authResult = await splashRepository.isUserAuthenticated();
          await authResult.fold(
            (failure) async {
              // If auth check fails, assume not authenticated and go to sign in
              emit(const SplashInitialized(shouldShowOnboarding: false));
            },
            (isAuthenticated) async {
              if (isAuthenticated) {
                // User is authenticated - go directly to main app
                emit(const SplashInitialized(shouldShowOnboarding: false));
              } else {
                // User not authenticated - go to sign in page
                emit(const SplashInitialized(shouldShowOnboarding: false));
              }
            },
          );
        },
      );
    } catch (e) {
      emit(SplashError(e.toString()));
    }
  }

  Future<void> _onCheckInitializationStatus(
    CheckInitializationStatus event,
    Emitter<SplashState> emit,
  ) async {
    try {
      final result = await checkAppInitialization(const NoParams());
      result.fold(
        (failure) => emit(SplashError(failure.toString())),
        (isInitialized) {
          if (isInitialized) {
            emit(const SplashInitialized(shouldShowOnboarding: false));
          } else {
            emit(const SplashInitialized(shouldShowOnboarding: true));
          }
        },
      );
    } catch (e) {
      emit(SplashError(e.toString()));
    }
  }
}
