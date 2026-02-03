import 'package:equatable/equatable.dart';
import '../../domain/entities/biometric_settings.dart';

abstract class BiometricState extends Equatable {
  const BiometricState();

  @override
  List<Object?> get props => [];
}

class BiometricInitial extends BiometricState {}

class BiometricLoading extends BiometricState {}

class BiometricAvailable extends BiometricState {
  final bool isAvailable;
  final BiometricType biometricType;

  const BiometricAvailable({
    required this.isAvailable,
    required this.biometricType,
  });

  @override
  List<Object?> get props => [isAvailable, biometricType];
}

class BiometricSettingsLoaded extends BiometricState {
  final BiometricSettings settings;

  const BiometricSettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class BiometricAuthenticationSuccess extends BiometricState {}

class BiometricAuthenticationFailure extends BiometricState {
  final String message;

  const BiometricAuthenticationFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class BiometricSettingsUpdated extends BiometricState {
  final BiometricSettings settings;

  const BiometricSettingsUpdated({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class BiometricError extends BiometricState {
  final String message;

  const BiometricError({required this.message});

  @override
  List<Object?> get props => [message];
}
