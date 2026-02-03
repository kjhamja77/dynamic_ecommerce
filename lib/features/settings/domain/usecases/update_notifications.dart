import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class UpdateNotifications implements UseCase<void, bool> {
  final SettingsRepository repository;

  UpdateNotifications(this.repository);

  @override
  Future<Either<Failure, void>> call(bool enabled) async {
    return await repository.updateNotifications(enabled);
  }
}
