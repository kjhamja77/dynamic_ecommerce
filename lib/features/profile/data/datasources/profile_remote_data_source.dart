import '../models/user_profile_model.dart';
import '../models/user_order_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);
  Future<List<UserOrderModel>> getUserOrders();
  Future<UserOrderModel> getOrderDetails(String orderId);
  Future<void> logout();
  Future<void> deleteAccount();
}
