part of 'orders_bloc.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object> get props => [];
}

class LoadOrders extends OrdersEvent {
  const LoadOrders();
}

class LoadOrderById extends OrdersEvent {
  final String orderId;

  const LoadOrderById(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class CreateOrderEvent extends OrdersEvent {
  final Order order;

  const CreateOrderEvent(this.order);

  @override
  List<Object> get props => [order];
}

class CancelOrderEvent extends OrdersEvent {
  final String orderId;

  const CancelOrderEvent(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class RefreshOrders extends OrdersEvent {
  const RefreshOrders();
}

class LoadOrdersByStatus extends OrdersEvent {
  final String status;

  const LoadOrdersByStatus(this.status);

  @override
  List<Object> get props => [status];
}

class LoadDeliveryStatus extends OrdersEvent {
  final int orderId;

  const LoadDeliveryStatus(this.orderId);

  @override
  List<Object> get props => [orderId];
}
