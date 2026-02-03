import 'package:dartz/dartz.dart';
import '../entities/biometric_settings.dart';
import '../../../../core/errors/failures.dart';

abstract class BiometricRepository {
  /// Check if biometric authentication is available on the device
  Future<Either<Failure, bool>> isBiometricAvailable();
  
  /// Get the type of biometric available (fingerprint, face ID, or none)
  Future<Either<Failure, BiometricType>> getAvailableBiometricType();
  
  /// Authenticate user using biometric
  Future<Either<Failure, bool>> authenticateWithBiometric();
  
  /// Get current biometric settings
  Future<Either<Failure, BiometricSettings>> getBiometricSettings();
  
  /// Update biometric settings
  Future<Either<Failure, BiometricSettings>> updateBiometricSettings(BiometricSettings settings);
  
  /// Enable biometric authentication
  Future<Either<Failure, bool>> enableBiometric();
  
  /// Disable biometric authentication
  Future<Either<Failure, bool>> disableBiometric();
}
