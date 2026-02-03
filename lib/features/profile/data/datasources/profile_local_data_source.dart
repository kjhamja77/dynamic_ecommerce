import '../models/user_profile_model.dart';
import '../models/user_order_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel?> getUserProfile();
  Future<void> cacheUserProfile(UserProfileModel profile);
  Future<void> clearUserProfile();
  Future<List<UserOrderModel>> getUserOrders();
  Future<void> cacheUserOrders(List<UserOrderModel> orders);
  Future<void> clearUserOrders();
}
