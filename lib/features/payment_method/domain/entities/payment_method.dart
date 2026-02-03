import 'package:equatable/equatable.dart';

enum PaymentMethodType {
  creditCard,
  debitCard,
  paypal,
  applePay,
  googlePay,
  bankTransfer,
  cashOnDelivery,
  cash,
  zainCash,
  qiCard,
  alQaseh,
}

class PaymentMethod extends Equatable {
  final String id;
  final String name;
  final String? cardNumber;
  final String? expiryDate;
  final String? cardHolderName;
  final String? cvvCode;
  final PaymentMethodType type;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? lastUsed;

  const PaymentMethod({
    required this.id,
    required this.name,
    this.cardNumber,
    this.expiryDate,
    this.cardHolderName,
    this.cvvCode,
    required this.type,
    this.isDefault = false,
    required this.createdAt,
    this.lastUsed,
  });

  PaymentMethod copyWith({
    String? id,
    String? name,
    String? cardNumber,
    String? expiryDate,
    String? cardHolderName,
    String? cvvCode,
    PaymentMethodType? type,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cvvCode: cvvCode ?? this.cvvCode,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        cardNumber,
        expiryDate,
        cardHolderName,
        cvvCode,
        type,
        isDefault,
        createdAt,
        lastUsed,
      ];
}
