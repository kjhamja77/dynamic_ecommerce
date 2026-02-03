import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/biometric_settings.dart';
import '../repositories/biometric_repository.dart';

class GetBiometricSettings implements UseCase<BiometricSettings, NoParams> {
  final BiometricRepository repository;

  const GetBiometricSettings(this.repository);

  @override
  Future<Either<Failure, BiometricSettings>> call(NoParams params) async {
    return await repository.getBiometricSettings();
  }
}
