import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GoogleLoginParams {
  final String idToken;
  final String deviceId;
  final String? deviceToken;

  GoogleLoginParams({required this.idToken, required this.deviceId, this.deviceToken});
}

class GoogleLoginUseCase {
  final AuthRepository repository;
  GoogleLoginUseCase(this.repository);

  Future<Either<Failure, User>> call(GoogleLoginParams params) {
    return repository.loginWithGoogle(
      idToken: params.idToken,
      deviceId: params.deviceId,
      deviceToken: params.deviceToken,
    );
  }
}


