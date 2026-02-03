import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/settings_local_data_source.dart';
import '../../domain/entities/settings.dart';
import '../../domain/entities/language.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Settings>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(Settings settings) async {
    try {
      await localDataSource.saveSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLanguage(Language language) async {
    try {
      await localDataSource.saveLanguage(language);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateThemeMode(ThemeMode themeMode) async {
    try {
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
      await localDataSource.saveSettings(updatedSettings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateNotifications(bool enabled) async {
    try {
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(
        notificationsEnabled: enabled,
        pushNotificationsEnabled: enabled,
        emailNotificationsEnabled: enabled,
      );
      await localDataSource.saveSettings(updatedSettings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Language>> getCurrentLanguage() async {
    try {
      final language = await localDataSource.getCurrentLanguage();
      return Right(language);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
