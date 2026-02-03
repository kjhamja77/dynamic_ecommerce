import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/biometric_settings.dart';
import '../../domain/repositories/biometric_repository.dart';
import '../datasources/biometric_local_data_source.dart';

class BiometricRepositoryImpl implements BiometricRepository {
  final BiometricLocalDataSource localDataSource;

  const BiometricRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> isBiometricAvailable() async {
    try {
      final isAvailable = await localDataSource.isBiometricAvailable();
      return Right(isAvailable);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BiometricType>> getAvailableBiometricType() async {
    try {
      final biometricType = await localDataSource.getAvailableBiometricType();
      return Right(biometricType);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateWithBiometric() async {
    try {
      final success = await localDataSource.authenticateWithBiometric();
      return Right(success);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BiometricSettings>> getBiometricSettings() async {
    try {
      final settings = await localDataSource.getBiometricSettings();
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BiometricSettings>> updateBiometricSettings(BiometricSettings settings) async {
    try {
      final updatedSettings = await localDataSource.updateBiometricSettings(settings);
      return Right(updatedSettings);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> enableBiometric() async {
    try {
      final currentSettings = await localDataSource.getBiometricSettings();
      final updatedSettings = currentSettings.copyWith(
        isEnabled: true,
        lastUsed: DateTime.now(),
      );
      await localDataSource.updateBiometricSettings(updatedSettings);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> disableBiometric() async {
    try {
      final currentSettings = await localDataSource.getBiometricSettings();
      final updatedSettings = currentSettings.copyWith(
        isEnabled: false,
        lastUsed: null,
      );
      await localDataSource.updateBiometricSettings(updatedSettings);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
