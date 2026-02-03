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

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.selectedColor,
    required this.selectedSize,
    required this.price,
    required this.addedAt,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedColor,
    String? selectedSize,
    double? price,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      price: price ?? this.price,
      addedAt: addedAt ?? this.addedAt,
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
      ];
}
