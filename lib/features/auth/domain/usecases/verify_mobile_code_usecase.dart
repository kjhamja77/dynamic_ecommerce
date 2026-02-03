import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';
import '../entities/user.dart';
import 'login_usecase.dart';

class VerifyMobileCodeUseCase implements UseCase<User, VerifyMobileCodeParams> {
  final AuthRepository repository;

  VerifyMobileCodeUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(VerifyMobileCodeParams params) async {
    return repository.verifyMobileCode(
      userId: params.userId,
      verificationCode: params.verificationCode,
    );
  }
}

class VerifyMobileCodeParams extends Equatable {
  final int userId;
  final String verificationCode;

  const VerifyMobileCodeParams({required this.userId, required this.verificationCode});

  @override
  List<Object> get props => [userId, verificationCode];
}


