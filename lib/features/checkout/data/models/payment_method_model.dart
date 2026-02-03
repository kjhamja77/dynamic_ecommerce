import '../../domain/entities/payment_method.dart';

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.type,
    required super.name,
    required super.lastFourDigits,
    required super.cardBrand,
    required super.isDefault,
    super.paymentUrl,
  });

  factory PaymentMethodModel.fromEntity(PaymentMethod method) {
    return PaymentMethodModel(
      id: method.id,
      type: method.type,
      name: method.name,
      lastFourDigits: method.lastFourDigits,
      cardBrand: method.cardBrand,
      isDefault: method.isDefault,
      paymentUrl: method.paymentUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'lastFourDigits': lastFourDigits,
      'cardBrand': cardBrand,
      'isDefault': isDefault,
      'paymentUrl': paymentUrl,
    };
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      type: PaymentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentType.creditCard,
      ),
      name: json['name'] as String,
      lastFourDigits: json['lastFourDigits'] as String?,
      cardBrand: json['cardBrand'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      paymentUrl: json['paymentUrl'] as String?,
    );
  }
}
