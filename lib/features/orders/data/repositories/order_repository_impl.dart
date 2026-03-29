import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/refund_request.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/create_refund_request.dart';
import '../datasources/order_local_data_source.dart';
import '../models/order_model.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;
  final OrderRemoteDataSource? remoteDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.localDataSource,
    required this.networkInfo,
    this.remoteDataSource,
  });

  @override
  Future<dartz.Either<Failure, List<Order>>> getOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Always try to fetch from API first if connected
      if (remoteDataSource != null && await networkInfo.isConnected) {
        try {
          // Fetch requested page of orders for "My Orders" pagination
          final remoteOrders = await remoteDataSource!.getOrderHistory(
            page: page,
            limit: limit,
          );
          // Save and return API orders (even if empty)
          if (page == 1) {
            await localDataSource.saveOrders(remoteOrders);
          } else {
            // Keep cache as merged list while paginating.
            final existing = await localDataSource.getOrders();
            final merged = <OrderModel>[
              ...existing.whereType<OrderModel>(),
              ...remoteOrders.where(
                (r) => !existing.any((e) => e.id == r.id),
              ),
            ];
            await localDataSource.saveOrders(merged);
          }
          return dartz.Right(remoteOrders);
        } catch (e) {
          // Only fall back to cache if API fails, never to demo data
          final localOrders = await localDataSource.getOrders();
          if (localOrders.isNotEmpty) {
            return dartz.Right(localOrders);
          }
          // Return error instead of demo data
          return dartz.Left(ServerFailure('Failed to fetch orders from API: ${e.toString()}'));
        }
      }

      // If not connected, try local cache
      final localOrders = await localDataSource.getOrders();
      if (localOrders.isNotEmpty) {
        return dartz.Right(localOrders);
      }

      // Only return demo orders if explicitly in offline mode and no cache
      // This should rarely happen in production
      return dartz.Left(CacheFailure('No orders available. Please check your internet connection.'));
    } catch (e) {
      return dartz.Left(CacheFailure('Failed to get orders: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> getOrderById(String orderId) async {
    try {
      final parsedOrderId = int.tryParse(orderId);
      if (remoteDataSource != null && parsedOrderId != null && await networkInfo.isConnected) {
        try {
          final remoteOrder = await remoteDataSource!.getOrderDetails(orderId: parsedOrderId);
          await localDataSource.saveOrder(remoteOrder);
          return dartz.Right(remoteOrder);
        } catch (_) {
          // fallback to local cache
        }
      }

      final order = await localDataSource.getOrderById(orderId);
      if (order != null) {
        return dartz.Right(order);
      } else {
        return dartz.Left(CacheFailure('Order not found'));
      }
    } catch (e) {
      return dartz.Left(CacheFailure('Failed to get order by ID: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> createOrder(Order order) async {
    try {
      final orderModel = OrderModel.fromEntity(order);
      await localDataSource.saveOrder(orderModel);
      return dartz.Right(orderModel);
    } catch (e) {
      return dartz.Left(CacheFailure('Failed to create order: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> updateOrderStatus(String orderId, String status) async {
    try {
      final orderResult = await getOrderById(orderId);
      
      return orderResult.fold(
        (failure) => dartz.Left(failure),
        (order) async {
          OrderStatus newStatus;
          try {
            newStatus = OrderStatus.values.firstWhere(
              (e) => e.toString().split('.').last == status,
            );
          } catch (e) {
            return dartz.Left(CacheFailure('Invalid order status: $status'));
          }
          
          final updatedOrder = order.copyWith(status: newStatus);
          final orderModel = OrderModel.fromEntity(updatedOrder);
          await localDataSource.saveOrder(orderModel);
          return dartz.Right(updatedOrder);
        },
      );
    } catch (e) {
      return dartz.Left(CacheFailure('Failed to update order status: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> cancelOrder(String orderId) async {
    try {
      final orderResult = await getOrderById(orderId);
      final parsedOrderId = int.tryParse(orderId);
      
      return orderResult.fold(
        (failure) => dartz.Left(failure),
        (order) async {
          if (!order.canBeCancelled) {
            return dartz.Left(CacheFailure('Order cannot be cancelled'));
          }

          // First, attempt to cancel the order on the backend if possible.
          if (remoteDataSource != null &&
              parsedOrderId != null &&
              await networkInfo.isConnected) {
            try {
              await remoteDataSource!.cancelOrder(orderId: parsedOrderId);
            } catch (e) {
              return dartz.Left(
                ServerFailure('Failed to cancel order: ${e.toString()}'),
              );
            }
          }

          final cancelledOrder = order.copyWith(status: OrderStatus.cancelled);
          final orderModel = OrderModel.fromEntity(cancelledOrder);
          await localDataSource.saveOrder(orderModel);
          return dartz.Right(cancelledOrder);
        },
      );
    } catch (e) {
      return dartz.Left(CacheFailure('Failed to cancel order: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, List<Order>>> getOrdersByStatus(String status) async {
    try {
      final ordersResult = await getOrders();
      
      return ordersResult.fold(
        (failure) => dartz.Left(failure),
        (orders) {
          try {
            final targetStatus = OrderStatus.values.firstWhere(
              (e) => e.toString().split('.').last == status,
            );
            
            final filteredOrders = orders.where((order) => order.status == targetStatus).toList();
            return dartz.Right(filteredOrders);
          } catch (e) {
            return dartz.Left(CacheFailure('Invalid order status: $status'));
          }
        },
      );
    } catch (e) {
      return dartz.Left(CacheFailure('Failed to get orders by status: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> deleteOrder(String orderId) async {
    try {
      await localDataSource.deleteOrder(orderId);
      return const dartz.Right(null);
    } catch (e) {
      return dartz.Left(CacheFailure('Failed to delete order: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, DeliveryStatusDto>> getDeliveryStatus({required int orderId}) async {
    try {
      if (remoteDataSource != null && await networkInfo.isConnected) {
        try {
          final deliveryStatus = await remoteDataSource!.getDeliveryStatus(orderId: orderId);
          return dartz.Right(deliveryStatus);
        } catch (e) {
          return dartz.Left(ServerFailure('Failed to fetch delivery status: ${e.toString()}'));
        }
      }
      return dartz.Left(ServerFailure('No internet connection'));
    } catch (e) {
      return dartz.Left(ServerFailure('Failed to get delivery status: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, RefundRequest>> createRefundRequest({
    required int orderId,
    required List<RefundLineInput> refundLines,
    required String reason,
  }) async {
    try {
      if (remoteDataSource != null && await networkInfo.isConnected) {
        try {
          final linesPayload = refundLines
              .map<Map<String, dynamic>>(
                (line) => <String, dynamic>{
                  'line_id': line.lineId,
                  'quantity': line.quantity,
                },
              )
              .toList();

          final result = await remoteDataSource!.createRefundRequest(
            orderId: orderId,
            refundLines: linesPayload,
            reason: reason,
          );

          return dartz.Right(result);
        } catch (e) {
          return dartz.Left(
            ServerFailure('Failed to create refund request: ${e.toString()}'),
          );
        }
      }

      return dartz.Left(ServerFailure('No internet connection'));
    } catch (e) {
      return dartz.Left(
        ServerFailure('Failed to create refund request: ${e.toString()}'),
      );
    }
  }

  @override
  Future<dartz.Either<Failure, List<RefundRequest>>> getRefundRequests({
    int page = 1,
  }) async {
    try {
      if (remoteDataSource != null && await networkInfo.isConnected) {
        try {
          final results =
              await remoteDataSource!.getRefundRequests(page: page);
          return dartz.Right(results);
        } catch (e) {
          return dartz.Left(
            ServerFailure('Failed to fetch refund requests: ${e.toString()}'),
          );
        }
      }

      return dartz.Left(ServerFailure('No internet connection'));
    } catch (e) {
      return dartz.Left(
        ServerFailure('Failed to fetch refund requests: ${e.toString()}'),
      );
    }
  }

  @override
  Future<dartz.Either<Failure, RefundRequest>> getRefundRequestDetails({
    required int refundRequestId,
  }) async {
    try {
      if (remoteDataSource != null && await networkInfo.isConnected) {
        try {
          final result = await remoteDataSource!
              .getRefundRequestDetails(refundRequestId: refundRequestId);
          return dartz.Right(result);
        } catch (e) {
          return dartz.Left(
            ServerFailure(
              'Failed to fetch refund request details: ${e.toString()}',
            ),
          );
        }
      }

      return dartz.Left(ServerFailure('No internet connection'));
    } catch (e) {
      return dartz.Left(
        ServerFailure('Failed to fetch refund request details: ${e.toString()}'),
      );
    }
  }

  @override
  Future<dartz.Either<Failure, void>> cancelRefundRequest({
    required int requestId,
  }) async {
    try {
      if (remoteDataSource != null && await networkInfo.isConnected) {
        try {
          await remoteDataSource!.cancelRefundRequest(requestId: requestId);
          return const dartz.Right(null);
        } catch (e) {
          return dartz.Left(
            ServerFailure(
              'Failed to cancel refund request: ${e.toString()}',
            ),
          );
        }
      }

      return dartz.Left(ServerFailure('No internet connection'));
    } catch (e) {
      return dartz.Left(
        ServerFailure('Failed to cancel refund request: ${e.toString()}'),
      );
    }
  }
}
