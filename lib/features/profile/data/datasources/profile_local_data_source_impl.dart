import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';
import '../models/user_order_model.dart';
import 'profile_local_data_source.dart';

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String _profileKey = 'user_profile';
  static const String _ordersKey = 'user_orders';

  @override
  Future<UserProfileModel?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    if (profileJson != null) {
      try {
        final profileMap = json.decode(profileJson) as Map<String, dynamic>;
        return UserProfileModel.fromJson(profileMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> cacheUserProfile(UserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = json.encode(profile.toJson());
    await prefs.setString(_profileKey, profileJson);
  }

  @override
  Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  @override
  Future<List<UserOrderModel>> getUserOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString(_ordersKey);
    if (ordersJson != null) {
      try {
        final ordersList = json.decode(ordersJson) as List<dynamic>;
        return ordersList
            .map((orderJson) => UserOrderModel.fromJson(orderJson as Map<String, dynamic>))
            .toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> cacheUserOrders(List<UserOrderModel> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = json.encode(orders.map((order) => order.toJson()).toList());
    await prefs.setString(_ordersKey, ordersJson);
  }

  @override
  Future<void> clearUserOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersKey);
  }
}
