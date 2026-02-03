import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';
import 'login_usecase.dart';

class ResendMobileVerificationUseCase implements UseCase<void, ResendMobileVerificationParams> {
  final AuthRepository repository;

  ResendMobileVerificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResendMobileVerificationParams params) async {
    return repository.resendMobileVerification(userId: params.userId);
  }
}

class ResendMobileVerificationParams extends Equatable {
  final int userId;

  const ResendMobileVerificationParams({required this.userId});

  @override
  List<Object> get props => [userId];
}


