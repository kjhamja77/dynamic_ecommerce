import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GuestLoginUseCase {
  final AuthRepository repository;
  const GuestLoginUseCase(this.repository);

  Future<Either<Failure, User>> call(GuestLoginParams params) {
    return repository.guestLogin(deviceId: params.deviceId, deviceToken: params.deviceToken);
  }
}

class GuestLoginParams {
  final String deviceId;
  final String? deviceToken;
  const GuestLoginParams({required this.deviceId, this.deviceToken});
}


