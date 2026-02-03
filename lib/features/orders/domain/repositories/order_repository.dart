import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/errors/failures.dart';
import '../entities/order.dart';
import '../../data/datasources/order_remote_data_source.dart';

abstract class OrderRepository {
  Future<dartz.Either<Failure, List<Order>>> getOrders();
  Future<dartz.Either<Failure, Order>> getOrderById(String orderId);
  Future<dartz.Either<Failure, Order>> createOrder(Order order);
  Future<dartz.Either<Failure, Order>> updateOrderStatus(String orderId, String status);
  Future<dartz.Either<Failure, Order>> cancelOrder(String orderId);
  Future<dartz.Either<Failure, List<Order>>> getOrdersByStatus(String status);
  Future<dartz.Either<Failure, void>> deleteOrder(String orderId);
  Future<dartz.Either<Failure, DeliveryStatusDto>> getDeliveryStatus({required int orderId});
}
