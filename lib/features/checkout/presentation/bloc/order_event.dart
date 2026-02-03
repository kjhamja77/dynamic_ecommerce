part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class PlaceOrderRequested extends OrderEvent {
  final int orderId;
  final String addressId;

  const PlaceOrderRequested({
    required this.orderId,
    required this.addressId,
  });

  @override
  List<Object?> get props => [orderId, addressId];
}

class CreateAlQasehPaymentRequested extends OrderEvent {
  final int orderId;
  final String addressId;

  const CreateAlQasehPaymentRequested({
    required this.orderId,
    required this.addressId,
  });

  @override
  List<Object?> get props => [orderId, addressId];
}

class AlQasehPaymentCompleted extends OrderEvent {
  final int orderId;
  final String addressId;
  final bool success;

  const AlQasehPaymentCompleted({
    required this.orderId,
    required this.addressId,
    required this.success,
  });

  @override
  List<Object?> get props => [orderId, addressId, success];
}


