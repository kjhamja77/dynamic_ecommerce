import '../../domain/entities/checkout_summary.dart';

class CheckoutSummaryModel extends CheckoutSummary {
  const CheckoutSummaryModel({
    required super.subtotal,
    required super.shipping,
    required super.tax,
    required super.discount,
    required super.total,
    required super.totalItems,
  });

  factory CheckoutSummaryModel.fromEntity(CheckoutSummary summary) {
    return CheckoutSummaryModel(
      subtotal: summary.subtotal,
      shipping: summary.shipping,
      tax: summary.tax,
      discount: summary.discount,
      total: summary.total,
      totalItems: summary.totalItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'discount': discount,
      'total': total,
      'totalItems': totalItems,
    };
  }

  factory CheckoutSummaryModel.fromJson(Map<String, dynamic> json) {
    return CheckoutSummaryModel(
      subtotal: (json['subtotal'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      totalItems: json['totalItems'] as int,
    );
  }
}
