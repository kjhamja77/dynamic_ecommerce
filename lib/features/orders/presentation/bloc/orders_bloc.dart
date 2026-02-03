import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as developer;
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/get_orders.dart';
import '../../domain/usecases/get_order_by_id.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/get_delivery_status.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../core/constants/order_constants.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrders getOrders;
  final GetOrderById getOrderById;
  final CreateOrder createOrder;
  final CancelOrder cancelOrder;
  final GetDeliveryStatus getDeliveryStatus;

  OrdersBloc({
    required this.getOrders,
    required this.getOrderById,
    required this.createOrder,
    required this.cancelOrder,
    required this.getDeliveryStatus,
  }) : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadOrderById>(_onLoadOrderById);
    on<CreateOrderEvent>(_onCreateOrder);
    on<CancelOrderEvent>(_onCancelOrder);
    on<RefreshOrders>(_onRefreshOrders);
    on<LoadOrdersByStatus>(_onLoadOrdersByStatus);
    on<LoadDeliveryStatus>(_onLoadDeliveryStatus);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    developer.log('📋 Loading orders...');
    emit(OrdersLoading());
    
    try {
      final result = await getOrders(NoParams());
      
      result.fold(
        (failure) {
          developer.log('❌ Failed to load orders: ${failure.message}');
          emit(OrdersError(failure.message));
        },
        (orders) {
          developer.log('✅ Orders loaded successfully: ${orders.length} orders');
          emit(OrdersLoaded(orders));
        },
      );
    } catch (e) {
      developer.log('💥 Exception while loading orders: $e');
      emit(OrdersError('Failed to load orders: ${e.toString()}'));
    }
  }

  Future<void> _onLoadOrderById(
    LoadOrderById event,
    Emitter<OrdersState> emit,
  ) async {
    developer.log('📋 Loading order by ID: ${event.orderId}');
    emit(OrderDetailsLoading());
    
    try {
      final result = await getOrderById(GetOrderByIdParams(event.orderId));
      
      result.fold(
        (failure) {
          developer.log('❌ Failed to load order: ${failure.message}');
          // Try to get cached order from current state if available
          Order? cachedOrder;
          if (state is OrderDetailsLoaded) {
            cachedOrder = (state as OrderDetailsLoaded).order;
          }
          emit(OrderDetailsError(failure.message, cachedOrder: cachedOrder));
        },
        (order) {
          developer.log('✅ Order loaded successfully: ${order.orderNumber}');
          emit(OrderDetailsLoaded(order: order, deliveryStatus: null));
          // After order details load, automatically load delivery status
          final parsedId = int.tryParse(order.id);
          if (parsedId != null) {
            add(LoadDeliveryStatus(parsedId));
          }
        },
      );
    } catch (e) {
      developer.log('💥 Exception while loading order: $e');
      Order? cachedOrder;
      if (state is OrderDetailsLoaded) {
        cachedOrder = (state as OrderDetailsLoaded).order;
      }
      emit(OrderDetailsError('Failed to load order: ${e.toString()}', cachedOrder: cachedOrder));
    }
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    developer.log('📋 Creating order...');
    emit(OrdersLoading());
    
    try {
      final result = await createOrder(CreateOrderParams(event.order));
      
      result.fold(
        (failure) {
          developer.log('❌ Failed to create order: ${failure.message}');
          emit(OrdersError(failure.message));
        },
        (order) {
          developer.log('✅ Order created successfully: ${order.orderNumber}');
          // Reload orders to show the new order
          add(LoadOrders());
        },
      );
    } catch (e) {
      developer.log('💥 Exception while creating order: $e');
      emit(OrdersError('Failed to create order: ${e.toString()}'));
    }
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    developer.log('📋 Cancelling order: ${event.orderId}');
    
    try {
      final result = await cancelOrder(CancelOrderParams(event.orderId));
      
      result.fold(
        (failure) {
          developer.log('❌ Failed to cancel order: ${failure.message}');
          emit(OrdersError(failure.message));
        },
        (order) {
          developer.log('✅ Order cancelled successfully: ${order.orderNumber}');
          // Reload orders to show the updated status
          add(LoadOrders());
        },
      );
    } catch (e) {
      developer.log('💥 Exception while cancelling order: $e');
      emit(OrdersError('Failed to cancel order: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshOrders(
    RefreshOrders event,
    Emitter<OrdersState> emit,
  ) async {
    developer.log('📋 Refreshing orders...');
    add(LoadOrders());
  }

  Future<void> _onLoadOrdersByStatus(
    LoadOrdersByStatus event,
    Emitter<OrdersState> emit,
  ) async {
    developer.log('📋 Loading orders by status: ${event.status}');
    emit(OrdersLoading());
    
    try {
      final result = await getOrders(NoParams());
      
      result.fold(
        (failure) {
          developer.log('❌ Failed to load orders by status: ${failure.message}');
          emit(OrdersError(failure.message));
        },
        (orders) {
          final filteredOrders = orders.where((order) => 
            order.status.toString().split('.').last == event.status
          ).toList();
          
          developer.log('✅ Orders filtered by status successfully: ${filteredOrders.length} orders');
          emit(OrdersLoaded(filteredOrders));
        },
      );
    } catch (e) {
      developer.log('💥 Exception while loading orders by status: $e');
      emit(OrdersError('Failed to load orders by status: ${e.toString()}'));
    }
  }

  Future<void> _onLoadDeliveryStatus(
    LoadDeliveryStatus event,
    Emitter<OrdersState> emit,
  ) async {
    developer.log('📦 Loading delivery status for order: ${event.orderId}');
    // Only load delivery status if we already have order details
    if (state is! OrderDetailsLoaded) {
      developer.log('⚠️ Skipping delivery status load – order details not loaded yet');
      return;
    }

    // Preserve current order from details state
    final currentOrder = (state as OrderDetailsLoaded).order;
    emit(DeliveryStatusLoading(currentOrder));
    
    try {
      final result = await getDeliveryStatus(GetDeliveryStatusParams(event.orderId));
      
      result.fold(
        (failure) {
          developer.log('❌ Failed to load delivery status: ${failure.message}');
          // Update order details with delivery status error, but keep the order
          if (currentOrder != null) {
            emit(OrderDetailsLoaded(
              order: currentOrder.copyWith(trackingPage: null),
              deliveryStatus: null,
              errorMessage: null,
            ));
          } else {
            emit(DeliveryStatusError(failure.message));
          }
        },
        (deliveryStatus) {
          developer.log('✅ Delivery status loaded successfully');
          // Map delivery status to order fields
          final deliveryState = OrderConstants.mapApiStatusToDeliveryState(deliveryStatus.status);
          
          // Extract dates from status history
          DateTime? shippedDate;
          DateTime? outForDeliveryDate;
          DateTime? deliveredDate;
          String? carrierMessage;
          
          for (final statusHistory in deliveryStatus.lastStatuses) {
            final statusSlug = statusHistory.slug.toLowerCase();
            final statusTitle = statusHistory.title.toLowerCase();
            
            // Extract shipped date
            if ((statusSlug.contains('shipped') || 
                 statusSlug.contains('in_transit') ||
                 statusSlug.contains('in transit') ||
                 statusTitle.contains('shipped') ||
                 statusTitle.contains('in transit')) &&
                shippedDate == null) {
              shippedDate = statusHistory.createdAt;
            }
            
            // Extract out for delivery date
            if ((statusSlug.contains('out_for_delivery') ||
                 statusSlug.contains('out for delivery') ||
                 statusSlug.contains('on_the_way') ||
                 statusSlug.contains('on the way') ||
                 statusTitle.contains('out for delivery') ||
                 statusTitle.contains('on the way')) &&
                outForDeliveryDate == null) {
              outForDeliveryDate = statusHistory.createdAt;
            }
            
            // Extract delivered date
            if ((statusSlug.contains('delivered') ||
                 statusSlug.contains('completed') ||
                 statusTitle.contains('delivered') ||
                 statusTitle.contains('completed')) &&
                deliveredDate == null) {
              deliveredDate = statusHistory.createdAt;
            }
            
            // Extract carrier message from pivot if available
            if (statusHistory.pivot?.carrierMessage != null &&
                carrierMessage == null &&
                statusHistory.pivot!.carrierMessage!.isNotEmpty) {
              carrierMessage = statusHistory.pivot!.carrierMessage;
            }
          }
          
          // Update order details with delivery status
          if (currentOrder != null) {
            emit(OrderDetailsLoaded(
              order: currentOrder.copyWith(
                trackingPage: deliveryStatus.trackingPage,
                deliveryState: deliveryState,
                shippedDate: shippedDate,
                outForDeliveryDate: outForDeliveryDate,
                deliveredDate: deliveredDate,
                deliveryNotes: carrierMessage,
              ),
              deliveryStatus: deliveryStatus,
              errorMessage: null,
            ));
          } else {
            emit(DeliveryStatusLoaded(deliveryStatus));
          }
        },
      );
    } catch (e) {
      developer.log('💥 Exception while loading delivery status: $e');
      if (currentOrder != null) {
        emit(OrderDetailsLoaded(
          order: currentOrder,
          deliveryStatus: null,
          errorMessage: null,
        ));
      } else {
        emit(DeliveryStatusError('Failed to load delivery status: ${e.toString()}'));
      }
    }
  }
}
