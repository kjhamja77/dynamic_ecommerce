import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';
import '../entities/user_order.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile();
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);
  Future<Either<Failure, List<UserOrder>>> getUserOrders();
  Future<Either<Failure, UserOrder>> getOrderDetails(String orderId);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> deleteAccount();
}
