import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:zalando_clone_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:zalando_clone_app/features/auth/domain/entities/user.dart';
import 'package:zalando_clone_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';

class FakeAuthRepository implements AuthRepository {
  bool shouldFailRegister = false;

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    return const Right(false);
  }

  @override
  Future<Either<Failure, User>> login(String email, String password, String deviceId, String? deviceToken) async {
    return Left(ServerFailure('not used'));
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
    if (shouldFailRegister) {
      return Left(ServerFailure('Register failed'));
    }
    return Right(
      User(
        id: '10',
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
  group('RegisterUseCase', () {
    test('returns User on success', () async {
      final repo = FakeAuthRepository();
      final useCase = RegisterUseCase(repo);

      final result = await useCase(const RegisterParams(
        email: 'jane@example.com',
        password: '123',
        firstName: 'Jane',
        lastName: 'Doe',
      ));

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right(User)'),
        (user) {
          expect(user.email, 'jane@example.com');
          expect(user.firstName, 'Jane');
          expect(user.lastName, 'Doe');
        },
      );
    });

    test('returns Failure on repository error', () async {
      final repo = FakeAuthRepository()..shouldFailRegister = true;
      final useCase = RegisterUseCase(repo);

      final result = await useCase(const RegisterParams(
        email: 'bad@example.com',
        password: 'wrong',
        firstName: 'X',
        lastName: 'Y',
      ));

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left(Failure)'),
      );
    });
  });
}


