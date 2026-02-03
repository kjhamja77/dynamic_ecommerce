import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.email, params.password, params.deviceId, params.deviceToken);
  }
}

class LoginParams extends Equatable {
  final String email; // Can be either email address or phone number
  final String password;
  final String deviceId;
  final String? deviceToken;

  const LoginParams({
    required this.email, 
    required this.password,
    required this.deviceId,
    this.deviceToken,
  });

  @override
  List<Object?> get props => [email, password, deviceId, deviceToken];
}

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
