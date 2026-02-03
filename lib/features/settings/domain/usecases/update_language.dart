import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/language.dart';
import '../repositories/settings_repository.dart';

class UpdateLanguage implements UseCase<void, Language> {
  final SettingsRepository repository;

  UpdateLanguage(this.repository);

  @override
  Future<Either<Failure, void>> call(Language language) async {
    return await repository.updateLanguage(language);
  }
}
