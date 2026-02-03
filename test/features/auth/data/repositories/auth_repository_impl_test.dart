import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zalando_clone_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:zalando_clone_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:zalando_clone_app/features/auth/domain/entities/user.dart';
import 'package:zalando_clone_app/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';

class FakeRemote implements AuthRemoteDataSource {
  bool failLogin = false;
  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<UserModel?> getCurrentUser() async => UserModel(
        id: '1',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        mobileVerified: true,
      );

  @override
  Future<UserModel> login(String email, String password, String deviceId, String? deviceToken) async {
    if (failLogin) throw Exception('bad');
    return UserModel(
      id: '1',
      email: 'john@example.com',
      firstName: 'John',
      lastName: 'Doe',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      mobileVerified: true,
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> resetPassword(String token, String newPassword) async {}

  @override
  Future<UserModel> register(String email, String password, String firstName, String lastName, {String? phone}) async {
    return UserModel(
      id: '2',
      email: 'jane@example.com',
      firstName: 'Jane',
      lastName: 'Doe',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      mobileVerified: false,
    );
  }

  @override
  Future<UserModel> verifyMobileCode({required int userId, required String verificationCode}) async {
    return UserModel(
      id: userId.toString(),
      email: 'verified@example.com',
      firstName: 'Verified',
      lastName: 'User',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      mobileVerified: true,
    );
  }

  @override
  Future<void> resendMobileVerification({required int userId}) async {}
}

class InMemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> delete({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll({IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    _store.clear();
  }

  @override
  Future<String?> read({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    return _store[key];
  }

  @override
  Future<Map<String, String>> readAll({IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    return Map<String, String>.from(_store);
  }

  @override
  Future<void> write({required String key, required String? value, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }
}

void main() {
  group('AuthRepositoryImpl', () {
    late FakeRemote remote;
    late InMemorySecureStorage storage;
    late AuthRepository repo;

    setUp(() {
      remote = FakeRemote();
      storage = InMemorySecureStorage();
      repo = AuthRepositoryImpl(remoteDataSource: remote, storage: storage);
    });

    test('login returns Right(User) on success', () async {
      final result = await repo.login('john@example.com', '123', 'device123', 'token123');
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected Right'),
        (user) => expect(user, isA<User>()),
      );
    });

    test('login returns Left(ServerFailure) on exception', () async {
      remote.failLogin = true;
      final result = await repo.login('bad@example.com', 'x', 'device123', 'token123');
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}


