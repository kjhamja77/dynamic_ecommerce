import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/biometric_repository.dart';

class CheckBiometricAvailability implements UseCase<bool, NoParams> {
  final BiometricRepository repository;

  const CheckBiometricAvailability(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isBiometricAvailable();
  }
}
