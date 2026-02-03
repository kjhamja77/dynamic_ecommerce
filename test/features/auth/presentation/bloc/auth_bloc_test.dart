import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:zalando_clone_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:zalando_clone_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:zalando_clone_app/features/auth/domain/usecases/verify_mobile_code_usecase.dart';
import 'package:zalando_clone_app/features/auth/domain/usecases/resend_mobile_verification_usecase.dart';
import 'package:zalando_clone_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:zalando_clone_app/features/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';
import 'package:zalando_clone_app/core/services/device_service.dart';

class MockDeviceService implements DeviceService {
  @override
  Future<String> getDeviceId() async => 'test-device-id';

  @override
  Future<String?> getFcmToken() async => 'test-fcm-token';

  @override
  Future<String?> refreshFcmToken() async => 'test-fcm-token';

  @override
  Future<Map<String, String?>> getDeviceInfo() async => {
    'device_id': 'test-device-id',
    'device_token': 'test-fcm-token',
  };
}

class FakeAuthRepository implements AuthRepository {
  bool isAuthed = false;
  bool failLogout = false;
  bool failForgot = false;
  User user = User(
    id: '1',
    email: 'john@example.com',
    firstName: 'John',
    lastName: 'Doe',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    mobileVerified: true,
  );

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    if (failForgot) return Left(ServerFailure('fail'));
    return const Right(null);
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    return Right(isAuthed ? user : null);
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    return Right(isAuthed);
  }

  @override
  Future<Either<Failure, User>> login(String email, String password, String deviceId, String? deviceToken) async {
    return Right(user);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (failLogout) return Left(ServerFailure('logout failed'));
    isAuthed = false;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> resetPassword(String token, String newPassword) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> register(String email, String password, String firstName, String lastName, {String? phone}) async {
    return Right(user);
  }

  @override
  Future<Either<Failure, User>> verifyMobileCode({required int userId, required String verificationCode}) async {
    return Right(user);
  }

  @override
  Future<Either<Failure, void>> resendMobileVerification({required int userId}) async {
    return const Right(null);
  }
}

void main() {
  group('AuthBloc', () {
    late FakeAuthRepository repo;
    late AuthBloc bloc;

    setUp(() {
      repo = FakeAuthRepository();
      bloc = AuthBloc(
        loginUseCase: LoginUseCase(repo),
        registerUseCase: RegisterUseCase(repo),
        authRepository: repo,
        deviceService: MockDeviceService(),
        verifyMobileCodeUseCase: VerifyMobileCodeUseCase(repo),
        resendMobileVerificationUseCase: ResendMobileVerificationUseCase(repo),
      );
    });

    test('emits [AuthLoading, Authenticated] on LoginRequested success', () async {
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<Authenticated>(),
        ]),
      );

      bloc.add(const LoginRequested(email: 'john@example.com', password: '123'));
    });

    test('emits [AuthLoading, Unauthenticated] on LogoutRequested success', () async {
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<Unauthenticated>(),
        ]),
      );

      bloc.add(LogoutRequested());
    });

    test('emits [AuthLoading, ForgotPasswordEmailSent] on ForgotPasswordRequested success', () async {
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<ForgotPasswordEmailSent>(),
        ]),
      );

      bloc.add(const ForgotPasswordRequested('john@example.com'));
    });

    test('emits [AuthLoading, AuthError] on ForgotPasswordRequested failure', () async {
      repo.failForgot = true;

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthError>(),
        ]),
      );

      bloc.add(const ForgotPasswordRequested('john@example.com'));
    });

    test('emits [Authenticated] on CheckAuthStatus when authed and user found', () async {
      repo.isAuthed = true;

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<Authenticated>(),
        ]),
      );

      bloc.add(CheckAuthStatus());
    });
  });
}


