import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/errors/failures.dart';
import '../entities/order.dart';
import '../entities/cancel_order_result.dart';
import '../entities/refund_request.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../usecases/create_refund_request.dart';

abstract class OrderRepository {
  Future<dartz.Either<Failure, List<Order>>> getOrders({
    int page,
    int limit,
  });
  Future<dartz.Either<Failure, Order>> getOrderById(String orderId);
  Future<dartz.Either<Failure, Order>> createOrder(Order order);
  Future<dartz.Either<Failure, Order>> updateOrderStatus(String orderId, String status);
  Future<dartz.Either<Failure, CancelOrderResult>> cancelOrder(String orderId);
  Future<dartz.Either<Failure, List<Order>>> getOrdersByStatus(String status);
  Future<dartz.Either<Failure, void>> deleteOrder(String orderId);
  Future<dartz.Either<Failure, DeliveryStatusDto>> getDeliveryStatus({required int orderId});
  Future<dartz.Either<Failure, RefundRequest>> createRefundRequest({
    required int orderId,
    required List<RefundLineInput> refundLines,
    required String reason,
  });
  Future<dartz.Either<Failure, List<RefundRequest>>> getRefundRequests({
    int page,
  });
  Future<dartz.Either<Failure, RefundRequest>> getRefundRequestDetails({
    required int refundRequestId,
  });
  Future<dartz.Either<Failure, void>> cancelRefundRequest({
    required int requestId,
  });
}
