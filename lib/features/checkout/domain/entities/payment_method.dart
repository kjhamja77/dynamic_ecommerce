enum PaymentType { creditCard, paypal, applePay, googlePay, cashOnDelivery, bankTransfer, alQaseh }

class PaymentMethod {
  final String id;
  final PaymentType type;
  final String name;
  final String? lastFourDigits;
  final String? cardBrand;
  final bool isDefault;
  final String? paymentUrl; // For Al Qaseh and other hosted payment methods

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    this.lastFourDigits,
    this.cardBrand,
    this.isDefault = false,
    this.paymentUrl,
  });

  PaymentMethod copyWith({
    String? id,
    PaymentType? type,
    String? name,
    String? lastFourDigits,
    String? cardBrand,
    bool? isDefault,
    String? paymentUrl,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      cardBrand: cardBrand ?? this.cardBrand,
      isDefault: isDefault ?? this.isDefault,
      paymentUrl: paymentUrl ?? this.paymentUrl,
    );
  }

  String get displayName {
    switch (type) {
      case PaymentType.creditCard:
        return '$cardBrand •••• $lastFourDigits';
      case PaymentType.paypal:
        return 'PayPal';
      case PaymentType.applePay:
        return 'Apple Pay';
      case PaymentType.googlePay:
        return 'Google Pay';
      case PaymentType.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentType.bankTransfer:
        return 'Bank Transfer';
      case PaymentType.alQaseh:
        return 'Al Qaseh';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethod &&
        other.id == id &&
        other.type == type &&
        other.name == name &&
        other.lastFourDigits == lastFourDigits &&
        other.cardBrand == cardBrand &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode => id.hashCode ^
      type.hashCode ^
      name.hashCode ^
      lastFourDigits.hashCode ^
      cardBrand.hashCode ^
      isDefault.hashCode ^
      (paymentUrl?.hashCode ?? 0);
}
