class CheckoutSummary {
  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;
  final int totalItems;

  const CheckoutSummary({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.total,
    required this.totalItems,
  });

  CheckoutSummary copyWith({
    double? subtotal,
    double? shipping,
    double? tax,
    double? discount,
    double? total,
    int? totalItems,
  }) {
    return CheckoutSummary(
      subtotal: subtotal ?? this.subtotal,
      shipping: shipping ?? this.shipping,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckoutSummary &&
        other.subtotal == subtotal &&
        other.shipping == shipping &&
        other.tax == tax &&
        other.discount == discount &&
        other.total == total &&
        other.totalItems == totalItems;
  }

  @override
  int get hashCode => subtotal.hashCode ^
      shipping.hashCode ^
      tax.hashCode ^
      discount.hashCode ^
      total.hashCode ^
      totalItems.hashCode;
}
