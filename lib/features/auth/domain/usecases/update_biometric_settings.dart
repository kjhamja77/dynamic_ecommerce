import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/biometric_settings.dart';
import '../repositories/biometric_repository.dart';

class UpdateBiometricSettings implements UseCase<BiometricSettings, BiometricSettings> {
  final BiometricRepository repository;

  const UpdateBiometricSettings(this.repository);

  @override
  Future<Either<Failure, BiometricSettings>> call(BiometricSettings params) async {
    return await repository.updateBiometricSettings(params);
  }
}
