import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/settings.dart';
import '../repositories/settings_repository.dart';

class UpdateTheme implements UseCase<void, ThemeMode> {
  final SettingsRepository repository;

  UpdateTheme(this.repository);

  @override
  Future<Either<Failure, void>> call(ThemeMode themeMode) async {
    return await repository.updateThemeMode(themeMode);
  }
}
