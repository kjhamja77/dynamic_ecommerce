import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/splash_repository.dart';

class CheckAppInitialization implements UseCase<bool, NoParams> {
  final SplashRepository repository;

  CheckAppInitialization(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isAppInitialized();
  }
}
