import '../../domain/entities/payment_method.dart';

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.name,
    super.cardNumber,
    super.expiryDate,
    super.cardHolderName,
    super.cvvCode,
    required super.type,
    super.isDefault,
    required super.createdAt,
    super.lastUsed,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      cardNumber: json['cardNumber'] as String?,
      expiryDate: json['expiryDate'] as String?,
      cardHolderName: json['cardHolderName'] as String?,
      cvvCode: json['cvvCode'] as String?,
      type: PaymentMethodType.values.firstWhere(
        (e) => e.toString() == 'PaymentMethodType.${json['type']}',
        orElse: () => PaymentMethodType.creditCard,
      ),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsed: json['lastUsed'] != null 
          ? DateTime.parse(json['lastUsed'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cardHolderName': cardHolderName,
      'cvvCode': cvvCode,
      'type': type.toString().split('.').last,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  factory PaymentMethodModel.fromEntity(PaymentMethod paymentMethod) {
    return PaymentMethodModel(
      id: paymentMethod.id,
      name: paymentMethod.name,
      cardNumber: paymentMethod.cardNumber,
      expiryDate: paymentMethod.expiryDate,
      cardHolderName: paymentMethod.cardHolderName,
      cvvCode: paymentMethod.cvvCode,
      type: paymentMethod.type,
      isDefault: paymentMethod.isDefault,
      createdAt: paymentMethod.createdAt,
      lastUsed: paymentMethod.lastUsed,
    );
  }
}
