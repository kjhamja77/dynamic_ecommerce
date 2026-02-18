import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password, String deviceId, String? deviceToken); // email can be email or phone number
  Future<Either<Failure, User>> register(String email, String password, String firstName, String lastName, {String? phone, String? countryCode});
  Future<Either<Failure, User>> loginWithGoogle({required String idToken, required String deviceId, String? deviceToken});
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> isAuthenticated();
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> resetPassword(String token, String newPassword);
  Future<Either<Failure, User>> verifyMobileCode({required int userId, required String verificationCode});
  Future<Either<Failure, void>> resendMobileVerification({required int userId});
  Future<Either<Failure, void>> resendEmailVerification({required int userId, required String apiToken});
  Future<Either<Failure, void>> resendEmailVerificationByEmail({required String email});
  Future<Either<Failure, User>> guestLogin({required String deviceId, String? deviceToken});
}
