import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_method.dart';

abstract class PaymentMethodState extends Equatable {
  const PaymentMethodState();

  @override
  List<Object?> get props => [];
}

class PaymentMethodInitial extends PaymentMethodState {}

class PaymentMethodLoading extends PaymentMethodState {}

class PaymentMethodsLoaded extends PaymentMethodState {
  final List<PaymentMethod> paymentMethods;
  const PaymentMethodsLoaded(this.paymentMethods);

  @override
  List<Object?> get props => [paymentMethods];
}

class PaymentMethodUpdating extends PaymentMethodState {
  final List<PaymentMethod> paymentMethods;
  const PaymentMethodUpdating(this.paymentMethods);

  @override
  List<Object?> get props => [paymentMethods];
}

class PaymentMethodSuccess extends PaymentMethodState {
  final String message;
  final List<PaymentMethod>? paymentMethods;
  const PaymentMethodSuccess(this.message, {this.paymentMethods});

  @override
  List<Object?> get props => [message, paymentMethods];
}

class PaymentMethodError extends PaymentMethodState {
  final String message;
  const PaymentMethodError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentCardPreviewState extends PaymentMethodState {
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvv;
  final PaymentMethodType type;

  const PaymentCardPreviewState({
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvv,
    required this.type,
  });

  @override
  List<Object?> get props => [cardNumber, expiryDate, cardHolderName, cvv, type];
}
