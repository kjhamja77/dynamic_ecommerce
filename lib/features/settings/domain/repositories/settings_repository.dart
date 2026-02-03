import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/settings.dart';
import '../entities/language.dart';

abstract class SettingsRepository {
  Future<Either<Failure, Settings>> getSettings();
  Future<Either<Failure, void>> updateSettings(Settings settings);
  Future<Either<Failure, void>> updateLanguage(Language language);
  Future<Either<Failure, void>> updateThemeMode(ThemeMode themeMode);
  Future<Either<Failure, void>> updateNotifications(bool enabled);
  Future<Either<Failure, Language>> getCurrentLanguage();
}
