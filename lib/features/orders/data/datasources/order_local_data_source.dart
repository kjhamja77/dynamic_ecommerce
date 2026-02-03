import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';
import '../models/order_model.dart';

abstract class OrderLocalDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel?> getOrderById(String orderId);
  Future<void> saveOrder(OrderModel order);
  Future<void> saveOrders(List<OrderModel> orders);
  Future<void> deleteOrder(String orderId);
  Future<void> clearOrders();
}

const String cachedOrdersKey = 'CACHED_ORDERS';

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  final SharedPreferences sharedPreferences;

  OrderLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final jsonString = sharedPreferences.getString(cachedOrdersKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        return orderModelListFromJson(jsonString);
      }
      return [];
    } catch (e) {
      throw CacheFailure('Failed to get orders from cache');
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final orders = await getOrders();
      try {
        return orders.firstWhere((order) => order.id == orderId);
      } catch (e) {
        return null; // Order not found
      }
    } catch (e) {
      throw CacheFailure('Failed to get order by ID from cache');
    }
  }

  @override
  Future<void> saveOrder(OrderModel order) async {
    try {
      final orders = await getOrders();
      
      // Check if order already exists
      final existingIndex = orders.indexWhere((o) => o.id == order.id);
      
      if (existingIndex != -1) {
        // Update existing order
        orders[existingIndex] = order;
      } else {
        // Add new order
        orders.add(order);
      }
      
      await saveOrders(orders);
    } catch (e) {
      throw CacheFailure('Failed to save order to cache');
    }
  }

  @override
  Future<void> saveOrders(List<OrderModel> orders) async {
    try {
      final jsonString = orderModelListToJson(orders);
      await sharedPreferences.setString(cachedOrdersKey, jsonString);
    } catch (e) {
      throw CacheFailure('Failed to save orders to cache');
    }
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    try {
      final orders = await getOrders();
      orders.removeWhere((order) => order.id == orderId);
      await saveOrders(orders);
    } catch (e) {
      throw CacheFailure('Failed to delete order from cache');
    }
  }

  @override
  Future<void> clearOrders() async {
    try {
      await sharedPreferences.remove(cachedOrdersKey);
    } catch (e) {
      throw CacheFailure('Failed to clear orders from cache');
    }
  }
}
