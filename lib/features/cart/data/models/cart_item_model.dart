import 'dart:convert';
import '../../domain/entities/cart_item.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/domain/entities/product.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.product,
    required super.quantity,
    required super.selectedColor,
    required super.selectedSize,
    required super.price,
    required super.addedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      product: ProductModel.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      selectedColor: json['selectedColor'] ?? '',
      selectedSize: json['selectedSize'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      addedAt: DateTime.parse(json['addedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product is ProductModel 
          ? (product as ProductModel).toJson()
          : ProductModel.fromEntity(product).toJson(),
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
      'price': price,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItemModel.fromEntity(CartItem cartItem) {
    return CartItemModel(
      id: cartItem.id,
      product: ProductModel.fromEntity(cartItem.product),
      quantity: cartItem.quantity,
      selectedColor: cartItem.selectedColor,
      selectedSize: cartItem.selectedSize,
      price: cartItem.price,
      addedAt: cartItem.addedAt,
    );
  }

  // Maps backend API cart item shape to our model
  factory CartItemModel.fromApiJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: (json['id'] ?? json['cart_item_id'] ?? '').toString(),
      product: ProductModel.fromApiJson(json['product'] as Map<String, dynamic>? ?? {}),
      quantity: json['quantity'] ?? 1,
      selectedColor: json['selected_color'] ?? json['color'] ?? '',
      selectedSize: json['selected_size'] ?? json['size'] ?? '',
      price: (json['price'] ?? json['unit_price'] ?? 0.0).toDouble(),
      addedAt: json['added_at'] != null 
          ? DateTime.parse(json['added_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  CartItemModel copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedColor,
    String? selectedSize,
    double? price,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      price: price ?? this.price,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

// JSON serialization helpers
String cartItemModelToJson(CartItemModel cartItem) => json.encode(cartItem.toJson());
CartItemModel cartItemModelFromJson(String str) => CartItemModel.fromJson(json.decode(str));

String cartItemModelListToJson(List<CartItemModel> cartItems) => 
    json.encode(cartItems.map((x) => x.toJson()).toList());

List<CartItemModel> cartItemModelListFromJson(String str) => 
    List<CartItemModel>.from(json.decode(str).map((x) => CartItemModel.fromJson(x)));
