import 'package:equatable/equatable.dart';

abstract class BiometricEvent extends Equatable {
  const BiometricEvent();

  @override
  List<Object?> get props => [];
}

class CheckBiometricAvailability extends BiometricEvent {}

class AuthenticateWithBiometric extends BiometricEvent {}

class GetBiometricSettings extends BiometricEvent {}

class UpdateBiometricSettings extends BiometricEvent {
  final bool isEnabled;

  const UpdateBiometricSettings({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class EnableBiometric extends BiometricEvent {}

class DisableBiometric extends BiometricEvent {}
