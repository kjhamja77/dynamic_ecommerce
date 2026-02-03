import 'package:equatable/equatable.dart';

enum BiometricType {
  fingerprint,
  faceId,
  none,
}

class BiometricSettings extends Equatable {
  final bool isEnabled;
  final BiometricType biometricType;
  final bool isAvailable;
  final DateTime? lastUsed;

  const BiometricSettings({
    required this.isEnabled,
    required this.biometricType,
    required this.isAvailable,
    this.lastUsed,
  });

  BiometricSettings copyWith({
    bool? isEnabled,
    BiometricType? biometricType,
    bool? isAvailable,
    DateTime? lastUsed,
  }) {
    return BiometricSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      biometricType: biometricType ?? this.biometricType,
      isAvailable: isAvailable ?? this.isAvailable,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  List<Object?> get props => [isEnabled, biometricType, isAvailable, lastUsed];
}
