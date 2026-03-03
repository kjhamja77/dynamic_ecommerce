import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/clear_user_caches_on_logout_service.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage storage;
  final SharedPreferences sharedPreferences;
  final ClearUserCachesOnLogoutService _logoutCacheClearService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storage,
    required this.sharedPreferences,
    required ClearUserCachesOnLogoutService logoutCacheClearService,
  }) : _logoutCacheClearService = logoutCacheClearService;

  @override
  Future<Either<Failure, User>> login(String email, String password, String deviceId, String? deviceToken) async { // email can be email or phone number
    try {
      final userModel = await remoteDataSource.login(email, password, deviceId, deviceToken);
      
      // Store currency data in cache
      if (userModel.currency != null) {
        await storage.write(key: AppConstants.currencyKey, value: userModel.currency!);
      }
      if (userModel.currencyId != null) {
        await storage.write(key: AppConstants.currencyIdKey, value: userModel.currencyId.toString());
      }
      // Cache user
      await storage.write(key: AppConstants.userKey, value: UserModel.fromEntity(userModel).toJson().toString());
      
      // Mark onboarding as completed when user successfully signs in
      await _markOnboardingCompleted();
      
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle({required String idToken, required String deviceId, String? deviceToken}) async {
    try {
      final userModel = await remoteDataSource.loginWithGoogle(idToken: idToken, deviceId: deviceId, deviceToken: deviceToken);
      if (userModel.currency != null) {
        await storage.write(key: AppConstants.currencyKey, value: userModel.currency!);
      }
      if (userModel.currencyId != null) {
        await storage.write(key: AppConstants.currencyIdKey, value: userModel.currencyId.toString());
      }
      await storage.write(key: AppConstants.userKey, value: UserModel.fromEntity(userModel).toJson().toString());
      
      // Mark onboarding as completed when user successfully signs in with Google
      await _markOnboardingCompleted();
      
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(String email, String password, String firstName, String lastName, {String? phone, String? countryCode}) async {
    try {
      // Enforce phone and country code presence at repository level
      if (phone == null || phone.isEmpty || countryCode == null || countryCode.isEmpty) {
        return Left(ServerFailure('Phone number and country code are required for registration'));
      }

      final userModel = await remoteDataSource.register(
        email,
        password,
        firstName,
        lastName,
        phone: phone,
        countryCode: countryCode,
      );
      await storage.write(key: AppConstants.userKey, value: UserModel.fromEntity(userModel).toJson().toString());
      
      // Mark onboarding as completed when user successfully registers
      await _markOnboardingCompleted();
      
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> guestLogin({required String deviceId, String? deviceToken}) async {
    try {
      final userModel = await remoteDataSource.guestLogin(deviceId: deviceId, deviceToken: deviceToken);
      // Do not save token for guest users and avoid caching currency/token-sensitive data
      await storage.write(key: AppConstants.userKey, value: UserModel.fromEntity(userModel).toJson().toString());

      // Clear favorites cache - guests cannot have server-side wishlist; prevents stale data from previous user
      await sharedPreferences.remove(AppConstants.favoritesKey);

      // Mark onboarding as completed when user logs in as guest
      await _markOnboardingCompleted();

      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      debugPrint('AuthRepositoryImpl.logout → start');
      try {
        debugPrint('AuthRepositoryImpl.logout → calling remoteDataSource.logout');
        await remoteDataSource.logout();
        debugPrint('AuthRepositoryImpl.logout → remote logout done');
      } catch (e) {
        debugPrint('AuthRepositoryImpl.logout → remote logout failed: $e (continuing with local cleanup)');
      }

      final beforeToken = await storage.read(key: AppConstants.tokenKey);
      debugPrint('AuthRepositoryImpl.logout → token before delete = ${beforeToken != null && beforeToken.isNotEmpty ? beforeToken : 'NULL/EMPTY'}');

      await storage.delete(key: AppConstants.tokenKey);
      await storage.delete(key: AppConstants.userKey);
      await storage.delete(key: AppConstants.currencyKey);
      await storage.delete(key: AppConstants.currencyIdKey);
      debugPrint('AuthRepositoryImpl.logout → deleted keys: ${AppConstants.tokenKey}, ${AppConstants.userKey}, ${AppConstants.currencyKey}, ${AppConstants.currencyIdKey}');

      // Clear user-specific cached data (favorites belong to the logged-in user)
      await sharedPreferences.remove(AppConstants.favoritesKey);

      // Clear all cached images (memory + disk) so next user/session starts clean
      await ImageCacheUtils.clearImageCache();

      // Clear all role/user-specific caches (cart, orders, home, addresses, payment methods, filters)
      await _logoutCacheClearService.clearAll();

      await storage.deleteAll();
      debugPrint('AuthRepositoryImpl.logout → deleteAll complete');

      final afterToken = await storage.read(key: AppConstants.tokenKey);
      debugPrint('AuthRepositoryImpl.logout → token after delete = ${afterToken != null && afterToken.isNotEmpty ? afterToken : 'NULL/EMPTY'}');

      return const Right(null);
    } catch (e) {
      debugPrint('AuthRepositoryImpl.logout → ERROR: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Try remote if available; fallback to cached storage
      final userModel = await remoteDataSource.getCurrentUser();
      if (userModel != null) {
        return Right(userModel);
      }
      final cached = await storage.read(key: AppConstants.userKey);
      if (cached != null && cached.isNotEmpty) {
        try {
          // Cached value was stored using toString(); rebuild a map safely
          final normalized = cached
              .replaceAll('{', '')
              .replaceAll('}', '')
              .split(',')
              .map((e) => e.split(':'))
              .where((kv) => kv.length >= 2)
              .fold<Map<String, String>>({}, (acc, kv) {
            final key = kv.first.trim().replaceAll("'", "");
            final value = kv.sublist(1).join(':').trim();
            acc[key] = value;
            return acc;
          });
          final json = <String, dynamic>{
            'id': normalized['id'],
            'email': normalized['email'],
            'first_name': normalized['first_name'],
            'last_name': normalized['last_name'],
            'profile_image': normalized['profile_image'],
            'phone_number': normalized['phone_number'],
            'created_at': normalized['created_at'],
            'updated_at': normalized['updated_at'],
            'currency': normalized['currency'],
            'currency_id': int.tryParse((normalized['currency_id'] ?? '').replaceAll(RegExp(r'[^0-9]'), '')),
            'mobile_verified': (normalized['mobile_verified'] ?? 'false').toLowerCase().contains('true'),
            'guest': (normalized['guest'] ?? 'false').toLowerCase().contains('true'),
          };
          return Right(UserModel.fromJson(json));
        } catch (_) {
          return const Right(null);
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await storage.read(key: AppConstants.tokenKey);
      if (token == null || token.isEmpty) {
        debugPrint('AuthRepositoryImpl.isAuthenticated → no token found');
        return const Right(false);
      }
      
      debugPrint('AuthRepositoryImpl.isAuthenticated → token found, validating with server');
      // Validate token with server by trying to get current user
      try {
        final user = await remoteDataSource.getCurrentUser();
        if (user != null) {
          debugPrint('AuthRepositoryImpl.isAuthenticated → server validation success, user: ${user.email}');
          return const Right(true);
        } else {
          debugPrint('AuthRepositoryImpl.isAuthenticated → server validation failed: no user data');
          return const Right(false);
        }
      } catch (e) {
        debugPrint('AuthRepositoryImpl.isAuthenticated → server validation failed: $e');
        return const Right(false);
      }
    } catch (e) {
      debugPrint('AuthRepositoryImpl.isAuthenticated → error: $e');
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String token, String newPassword) async {
    try {
      await remoteDataSource.resetPassword(token, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyMobileCode({required int userId, required String verificationCode}) async {
    try {
      final userModel = await remoteDataSource.verifyMobileCode(userId: userId, verificationCode: verificationCode);
      
      // Store currency data in cache
      if (userModel.currency != null) {
        await storage.write(key: AppConstants.currencyKey, value: userModel.currency!);
      }
      if (userModel.currencyId != null) {
        await storage.write(key: AppConstants.currencyIdKey, value: userModel.currencyId.toString());
      }
      
      // Cache user (similar to login flow)
      await storage.write(key: AppConstants.userKey, value: UserModel.fromEntity(userModel).toJson().toString());
      
      // Mark onboarding as completed when user successfully verifies mobile
      await _markOnboardingCompleted();
      
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendMobileVerification({required int userId}) async {
    try {
      await remoteDataSource.resendMobileVerification(userId: userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendEmailVerification({required int userId, required String apiToken}) async {
    debugPrint('AuthRepositoryImpl.resendEmailVerification: start userId=$userId, apiToken length=${apiToken.length}');
    try {
      await remoteDataSource.resendEmailVerification(userId: userId, apiToken: apiToken);
      debugPrint('AuthRepositoryImpl.resendEmailVerification: remoteDataSource success, returning Right');
      return const Right(null);
    } catch (e) {
      debugPrint('AuthRepositoryImpl.resendEmailVerification: catch e=$e, returning Left(ServerFailure)');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendEmailVerificationByEmail({required String email}) async {
    debugPrint('AuthRepositoryImpl.resendEmailVerificationByEmail: start email=$email');
    try {
      await remoteDataSource.resendEmailVerificationByEmail(email: email);
      debugPrint('AuthRepositoryImpl.resendEmailVerificationByEmail: remoteDataSource success, returning Right');
      return const Right(null);
    } catch (e) {
      debugPrint('AuthRepositoryImpl.resendEmailVerificationByEmail: catch e=$e, returning Left(ServerFailure)');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Helper method to mark onboarding as completed
  Future<void> _markOnboardingCompleted() async {
    try {
      await sharedPreferences.setBool('onboarding_completed', true);
      debugPrint('AuthRepositoryImpl: Marked onboarding as completed');
    } catch (e) {
      debugPrint('AuthRepositoryImpl: Failed to mark onboarding as completed: $e');
    }
  }
}
