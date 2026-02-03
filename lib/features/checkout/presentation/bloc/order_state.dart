part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderSubmitting extends OrderState {
  const OrderSubmitting();
}

class OrderSuccess extends OrderState {
  final String orderReference;
  final int orderId;

  const OrderSuccess({
    required this.orderReference,
    required this.orderId,
  });

  @override
  List<Object?> get props => [orderReference, orderId];
}

class OrderFailure extends OrderState {
  final String message;

  const OrderFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AlQasehPaymentCreating extends OrderState {
  const AlQasehPaymentCreating();
}

class AlQasehPaymentCreated extends OrderState {
  final String paymentUrl;
  final String paymentId;
  final String token;
  final int orderId;
  final String addressId;

  const AlQasehPaymentCreated({
    required this.paymentUrl,
    required this.paymentId,
    required this.token,
    required this.orderId,
    required this.addressId,
  });

  @override
  List<Object?> get props => [paymentUrl, paymentId, token, orderId, addressId];
}

class AlQasehPaymentSuccess extends OrderState {
  final String orderReference;

  const AlQasehPaymentSuccess(this.orderReference);

  @override
  List<Object?> get props => [orderReference];
}

class AlQasehPaymentFailure extends OrderState {
  final String message;

  const AlQasehPaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}


