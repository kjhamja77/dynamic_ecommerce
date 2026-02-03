import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/biometric_settings.dart';
import '../../domain/usecases/authenticate_with_biometric.dart' as auth_usecase;
import '../../domain/usecases/check_biometric_availability.dart' as check_usecase;
import '../../domain/usecases/get_biometric_settings.dart' as get_usecase;
import '../../domain/usecases/update_biometric_settings.dart' as update_usecase;
import 'biometric_event.dart';
import 'biometric_state.dart';

class BiometricBloc extends Bloc<BiometricEvent, BiometricState> {
  final check_usecase.CheckBiometricAvailability checkBiometricAvailability;
  final auth_usecase.AuthenticateWithBiometric authenticateWithBiometric;
  final get_usecase.GetBiometricSettings getBiometricSettings;
  final update_usecase.UpdateBiometricSettings updateBiometricSettings;

  BiometricBloc({
    required this.checkBiometricAvailability,
    required this.authenticateWithBiometric,
    required this.getBiometricSettings,
    required this.updateBiometricSettings,
  }) : super(BiometricInitial()) {
    on<CheckBiometricAvailability>(_onCheckBiometricAvailability);
    on<AuthenticateWithBiometric>(_onAuthenticateWithBiometric);
    on<GetBiometricSettings>(_onGetBiometricSettings);
    on<UpdateBiometricSettings>(_onUpdateBiometricSettings);
    on<EnableBiometric>(_onEnableBiometric);
    on<DisableBiometric>(_onDisableBiometric);
  }

  Future<void> _onCheckBiometricAvailability(
    CheckBiometricAvailability event,
    Emitter<BiometricState> emit,
  ) async {
    emit(BiometricLoading());
    
    try {
      final result = await checkBiometricAvailability(NoParams());
      
      result.fold(
        (failure) => emit(BiometricError(message: failure.message)),
        (isAvailable) {
          if (isAvailable) {
            // For now, assume fingerprint is available
            // In a real implementation, you'd check the actual type
            emit(const BiometricAvailable(
              isAvailable: true,
              biometricType: BiometricType.fingerprint,
            ));
          } else {
            emit(const BiometricAvailable(
              isAvailable: false,
              biometricType: BiometricType.none,
            ));
          }
        },
      );
    } catch (e) {
      emit(BiometricError(message: e.toString()));
    }
  }

  Future<void> _onAuthenticateWithBiometric(
    AuthenticateWithBiometric event,
    Emitter<BiometricState> emit,
  ) async {
    emit(BiometricLoading());
    
    try {
      final result = await authenticateWithBiometric(NoParams());
      
      await result.fold(
        (failure) async {
          emit(BiometricAuthenticationFailure(message: failure.message));
          // Restore settings so UI can show the button again
          final settingsResult = await getBiometricSettings(NoParams());
          settingsResult.fold(
            (f) => emit(BiometricError(message: f.message)),
            (settings) => emit(BiometricSettingsLoaded(settings: settings)),
          );
        },
        (success) async {
          if (success) {
            emit(BiometricAuthenticationSuccess());
          } else {
            emit(const BiometricAuthenticationFailure(message: 'Authentication was canceled or failed'));
            // Restore settings so UI can show the button again
            final settingsResult = await getBiometricSettings(NoParams());
            settingsResult.fold(
              (f) => emit(BiometricError(message: f.message)),
              (settings) => emit(BiometricSettingsLoaded(settings: settings)),
            );
          }
        },
      );
    } catch (e) {
      emit(BiometricError(message: e.toString()));
      final settingsResult = await getBiometricSettings(NoParams());
      settingsResult.fold(
        (f) => emit(BiometricError(message: f.message)),
        (settings) => emit(BiometricSettingsLoaded(settings: settings)),
      );
    }
  }

  Future<void> _onGetBiometricSettings(
    GetBiometricSettings event,
    Emitter<BiometricState> emit,
  ) async {
    emit(BiometricLoading());
    
    try {
      final result = await getBiometricSettings(NoParams());
      
      result.fold(
        (failure) => emit(BiometricError(message: failure.message)),
        (settings) => emit(BiometricSettingsLoaded(settings: settings)),
      );
    } catch (e) {
      emit(BiometricError(message: e.toString()));
    }
  }

  Future<void> _onUpdateBiometricSettings(
    UpdateBiometricSettings event,
    Emitter<BiometricState> emit,
  ) async {
    emit(BiometricLoading());
    
    try {
      // Get current settings first
      final currentResult = await getBiometricSettings(NoParams());
      
      if (currentResult.isLeft()) {
        final failure = currentResult.fold((f) => f, (_) => throw Exception('Unexpected state'));
        emit(BiometricError(message: failure.message));
        return;
      }
      
      final currentSettings = currentResult.fold((_) => throw Exception('Unexpected state'), (s) => s);
      final updatedSettings = currentSettings.copyWith(
        isEnabled: event.isEnabled,
        lastUsed: event.isEnabled ? DateTime.now() : null,
      );
      
      final result = await updateBiometricSettings(updatedSettings);
      
      result.fold(
        (failure) => emit(BiometricError(message: failure.message)),
        (settings) => emit(BiometricSettingsUpdated(settings: settings)),
      );
    } catch (e) {
      emit(BiometricError(message: e.toString()));
    }
  }

  Future<void> _onEnableBiometric(
    EnableBiometric event,
    Emitter<BiometricState> emit,
  ) async {
    emit(BiometricLoading());
    
    try {
      // Load current settings and available type
      final currentResult = await getBiometricSettings(NoParams());
      final typeResult = await checkBiometricAvailability(NoParams());
      
      BiometricType biometricType = BiometricType.none;
      if (typeResult.isRight()) {
        // Best-effort: if available, keep existing type or default to fingerprint
        biometricType = (state is BiometricAvailable && (state as BiometricAvailable).isAvailable)
            ? (state as BiometricAvailable).biometricType
            : BiometricType.fingerprint;
      }
      
      if (currentResult.isLeft()) {
        final failure = currentResult.fold((f) => f, (_) => throw Exception('Unexpected'));
        emit(BiometricError(message: failure.message));
        return;
      }
      final currentSettings = currentResult.fold((_) => throw Exception('Unexpected'), (s) => s);
      final result = await updateBiometricSettings(
        currentSettings.copyWith(
          isEnabled: true,
          biometricType: biometricType,
          lastUsed: DateTime.now(),
        ),
      );
      
      result.fold(
        (failure) => emit(BiometricError(message: failure.message)),
        (settings) => emit(BiometricSettingsUpdated(settings: settings)),
      );
    } catch (e) {
      emit(BiometricError(message: e.toString()));
    }
  }

  Future<void> _onDisableBiometric(
    DisableBiometric event,
    Emitter<BiometricState> emit,
  ) async {
    emit(BiometricLoading());
    
    try {
      final currentResult = await getBiometricSettings(NoParams());
      if (currentResult.isLeft()) {
        final failure = currentResult.fold((f) => f, (_) => throw Exception('Unexpected'));
        emit(BiometricError(message: failure.message));
        return;
      }
      final currentSettings = currentResult.fold((_) => throw Exception('Unexpected'), (s) => s);
      final result = await updateBiometricSettings(
        currentSettings.copyWith(
          isEnabled: false,
          lastUsed: null,
        ),
      );
      
      result.fold(
        (failure) => emit(BiometricError(message: failure.message)),
        (settings) => emit(BiometricSettingsUpdated(settings: settings)),
      );
    } catch (e) {
      emit(BiometricError(message: e.toString()));
    }
  }
}
