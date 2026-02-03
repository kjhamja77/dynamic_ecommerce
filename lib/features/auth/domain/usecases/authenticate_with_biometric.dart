import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/biometric_repository.dart';

class AuthenticateWithBiometric implements UseCase<bool, NoParams> {
  final BiometricRepository repository;

  const AuthenticateWithBiometric(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.authenticateWithBiometric();
  }
}
