

import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:zalando_clone_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:zalando_clone_app/features/auth/domain/entities/user.dart';
import 'package:zalando_clone_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';

class FakeAuthRepository implements AuthRepository {
  bool shouldFailLogin = false;
  User? userToReturn;

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    return Right(userToReturn);
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    return Right(userToReturn != null);
  }

  @override
  Future<Either<Failure, User>> login(String email, String password, String deviceId, String? deviceToken) async {
    if (shouldFailLogin) {
      return Left(ServerFailure('Login failed'));
    }
    return Right(
      userToReturn ??
          User(
            id: '1',
            email: email,
            firstName: 'John',
            lastName: 'Doe',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            mobileVerified: true,
          ),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> resetPassword(String token, String newPassword) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> register(String email, String password, String firstName, String lastName, {String? phone}) async {
    return Right(
      userToReturn ??
          User(
            id: '2',
            email: email,
            firstName: firstName,
            lastName: lastName,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            mobileVerified: false,
          ),
    );
  }

  @override
  Future<Either<Failure, User>> verifyMobileCode({required int userId, required String verificationCode}) async {
    return Right(
      User(
        id: userId.toString(),
        email: 'verified@example.com',
        firstName: 'Verified',
        lastName: 'User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        mobileVerified: true,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> resendMobileVerification({required int userId}) async {
    return const Right(null);
  }
}

void main() {
  group('LoginUseCase', () {
    test('returns User on success', () async {
      final repo = FakeAuthRepository();
      final useCase = LoginUseCase(repo);

      final result = await useCase(const LoginParams(email: 'john@example.com', password: '123', deviceId: 'device123', deviceToken: 'token123'));

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right(User)'),
        (user) {
          expect(user.email, 'john@example.com');
          expect(user.firstName, 'John');
        },
      );
    });

    test('returns Failure on repository error', () async {
      final repo = FakeAuthRepository()..shouldFailLogin = true;
      final useCase = LoginUseCase(repo);

      final result = await useCase(const LoginParams(email: 'bad@example.com', password: 'wrong', deviceId: 'device123', deviceToken: 'token123'));

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left(Failure)'),
      );
    });
  });
}


