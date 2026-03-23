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
    super.isCoupon = false,
    super.lineSubtotalOverride,
    super.lineTotalOverride,
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
      isCoupon: json['isCoupon'] ?? false,
      lineSubtotalOverride: json['lineSubtotalOverride'] != null
          ? (json['lineSubtotalOverride'] as num).toDouble()
          : null,
      lineTotalOverride: json['lineTotalOverride'] != null
          ? (json['lineTotalOverride'] as num).toDouble()
          : null,
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
      'isCoupon': isCoupon,
      'lineSubtotalOverride': lineSubtotalOverride,
      'lineTotalOverride': lineTotalOverride,
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
      isCoupon: cartItem.isCoupon,
      lineSubtotalOverride: cartItem.lineSubtotalOverride,
      lineTotalOverride: cartItem.lineTotalOverride,
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
    bool? isCoupon,
    double? lineSubtotalOverride,
    double? lineTotalOverride,
  }) {
    return CartItemModel(
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
}

// JSON serialization helpers
String cartItemModelToJson(CartItemModel cartItem) => json.encode(cartItem.toJson());
CartItemModel cartItemModelFromJson(String str) => CartItemModel.fromJson(json.decode(str));

String cartItemModelListToJson(List<CartItemModel> cartItems) => 
    json.encode(cartItems.map((x) => x.toJson()).toList());

List<CartItemModel> cartItemModelListFromJson(String str) => 
    List<CartItemModel>.from(json.decode(str).map((x) => CartItemModel.fromJson(x)));
