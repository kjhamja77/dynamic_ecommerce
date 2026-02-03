import '../../../cart/domain/entities/cart_item.dart';

class CheckoutItem {
  final String id;
  final CartItem cartItem;
  final bool isSelected;

  const CheckoutItem({
    required this.id,
    required this.cartItem,
    this.isSelected = true,
  });

  CheckoutItem copyWith({
    String? id,
    CartItem? cartItem,
    bool? isSelected,
  }) {
    return CheckoutItem(
      id: id ?? this.id,
      cartItem: cartItem ?? this.cartItem,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckoutItem &&
        other.id == id &&
        other.cartItem == cartItem &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode => id.hashCode ^ cartItem.hashCode ^ isSelected.hashCode;
}
