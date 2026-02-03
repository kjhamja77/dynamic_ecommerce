import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_method.dart';

abstract class PaymentMethodEvent extends Equatable {
  const PaymentMethodEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentMethods extends PaymentMethodEvent {}

class AddPaymentMethod extends PaymentMethodEvent {
  final PaymentMethod paymentMethod;
  const AddPaymentMethod(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class DeletePaymentMethod extends PaymentMethodEvent {
  final String id;
  const DeletePaymentMethod(this.id);

  @override
  List<Object?> get props => [id];
}

class SetDefaultPaymentMethod extends PaymentMethodEvent {
  final String id;
  const SetDefaultPaymentMethod(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateCardPreview extends PaymentMethodEvent {
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvv;
  final PaymentMethodType type;

  const UpdateCardPreview({
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvv,
    required this.type,
  });

  @override
  List<Object?> get props => [cardNumber, expiryDate, cardHolderName, cvv, type];
}
