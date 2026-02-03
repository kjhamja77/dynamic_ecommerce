import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/checkout_item.dart';

class CheckoutItemModel extends CheckoutItem {
  const CheckoutItemModel({
    required super.id,
    required super.cartItem,
    required super.isSelected,
  });

  factory CheckoutItemModel.fromEntity(CheckoutItem checkoutItem) {
    return CheckoutItemModel(
      id: checkoutItem.id,
      cartItem: checkoutItem.cartItem,
      isSelected: checkoutItem.isSelected,
    );
  }

  @override
  CheckoutItemModel copyWith({
    String? id,
    CartItem? cartItem,
    bool? isSelected,
  }) {
    return CheckoutItemModel(
      id: id ?? this.id,
      cartItem: cartItem ?? this.cartItem,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartItem': cartItem.toString(), // Simplified for demo
      'isSelected': isSelected,
    };
  }

  factory CheckoutItemModel.fromJson(Map<String, dynamic> json) {
    // Simplified for demo - in real app, you'd properly deserialize CartItem
    // For now, we'll skip this method as it requires proper Product deserialization
    throw UnimplementedError('fromJson requires proper Product deserialization');
  }
}
