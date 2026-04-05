part of 'orders_bloc.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const OrdersLoaded(
    this.orders, {
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  OrdersLoaded copyWith({
    List<Order>? orders,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return OrdersLoaded(
      orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [orders, currentPage, hasMore, isLoadingMore];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object> get props => [message];
}

class OrderDetailsLoading extends OrdersState {}

class OrderDetailsLoaded extends OrdersState {
  final Order order;
  final DeliveryStatusDto? deliveryStatus;
  final String? errorMessage;

  const OrderDetailsLoaded({
    required this.order,
    this.deliveryStatus,
    this.errorMessage,
  });

  OrderDetailsLoaded copyWith({
    Order? order,
    DeliveryStatusDto? deliveryStatus,
    String? errorMessage,
  }) {
    return OrderDetailsLoaded(
      order: order ?? this.order,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object> get props => [order, deliveryStatus ?? '', errorMessage ?? ''];
}

class OrderDetailsError extends OrdersState {
  final String message;
  final Order? cachedOrder;

  const OrderDetailsError(this.message, {this.cachedOrder});

  @override
  List<Object> get props => [message, cachedOrder ?? ''];
}

class DeliveryStatusLoading extends OrdersState {
  final Order order;

  const DeliveryStatusLoading(this.order);

  @override
  List<Object> get props => [order];
}

class DeliveryStatusLoaded extends OrdersState {
  final DeliveryStatusDto deliveryStatus;

  const DeliveryStatusLoaded(this.deliveryStatus);

  @override
  List<Object> get props => [deliveryStatus];
}

class DeliveryStatusError extends OrdersState {
  final String message;

  const DeliveryStatusError(this.message);

  @override
  List<Object> get props => [message];
}

/// Shown briefly before [Navigator.pop]; carries API success text (any language).
/// [nonce] must change on every emit so [Bloc] does not drop duplicate [props].
class OrderCancelSuccess extends OrdersState {
  final String message;
  final Order order;
  final int nonce;

  const OrderCancelSuccess(this.message, this.order, {required this.nonce});

  @override
  List<Object> get props => [message, order, nonce];
}

/// Cancel failed; UI stays on order details. [message] is from the API when available.
class OrderCancelFailure extends OrdersState {
  final String message;
  final Order order;
  final DeliveryStatusDto? deliveryStatus;
  final int nonce;

  const OrderCancelFailure(
    this.message,
    this.order, {
    this.deliveryStatus,
    required this.nonce,
  });

  @override
  List<Object> get props => [message, order, deliveryStatus ?? '', nonce];
}
