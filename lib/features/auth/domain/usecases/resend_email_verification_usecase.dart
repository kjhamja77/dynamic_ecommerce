import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';
import 'login_usecase.dart';

class ResendEmailVerificationUseCase implements UseCase<void, ResendEmailVerificationParams> {
  final AuthRepository repository;

  ResendEmailVerificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResendEmailVerificationParams params) async {
    debugPrint('ResendEmailVerificationUseCase: call email=${params.email}');
    final result = await repository.resendEmailVerificationByEmail(email: params.email);
    result.fold(
      (failure) => debugPrint('ResendEmailVerificationUseCase: repository returned Left: ${failure.message}'),
      (_) => debugPrint('ResendEmailVerificationUseCase: repository returned Right (success)'),
    );
    return result;
  }
}

class ResendEmailVerificationParams extends Equatable {
  final String email;

  const ResendEmailVerificationParams({required this.email});

  @override
  List<Object> get props => [email];
}
