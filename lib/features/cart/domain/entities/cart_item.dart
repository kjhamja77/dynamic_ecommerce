import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/product.dart';

class CartItem extends Equatable {
  final String id;
  final Product product;
  final int quantity;
  final String selectedColor;
  final String selectedSize;
  final double price;
  final DateTime addedAt;
  /// True when this line represents a coupon/discount item (e.g. negative line).
  final bool isCoupon;
  /// Optional override for line subtotal from backend (e.g. price_subtotal).
  final double? lineSubtotalOverride;
  /// Optional override for line total from backend (e.g. price_total).
  final double? lineTotalOverride;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.selectedColor,
    required this.selectedSize,
    required this.price,
    required this.addedAt,
    this.isCoupon = false,
    this.lineSubtotalOverride,
    this.lineTotalOverride,
  });

  double get totalPrice => price * quantity;

  /// Subtotal for this line. Uses backend override when provided, otherwise price * quantity.
  double get lineSubtotal => lineSubtotalOverride ?? totalPrice;

  /// Final total for this line. Uses backend override when provided, otherwise [lineSubtotal].
  double get lineTotal => lineTotalOverride ?? lineSubtotal;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedColor,
    String? selectedSize,
    double? price,
    DateTime? addedAt,
    bool? isCoupon,
    double? lineSubtotalOverride,
    double? lineTotalOverride,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      price: price ?? this.price,
      addedAt: addedAt ?? this.addedAt,
      isCoupon: isCoupon ?? this.isCoupon,
      lineSubtotalOverride: lineSubtotalOverride ?? this.lineSubtotalOverride,
      lineTotalOverride: lineTotalOverride ?? this.lineTotalOverride,
    );
  }

  @override
  List<Object?> get props => [
        id,
        product,
        quantity,
        selectedColor,
        selectedSize,
        price,
        addedAt,
        isCoupon,
        lineSubtotalOverride,
        lineTotalOverride,
      ];
}
