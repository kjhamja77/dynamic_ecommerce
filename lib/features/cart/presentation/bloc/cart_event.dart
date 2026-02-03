part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {
  const LoadCart();
}

class RefreshCart extends CartEvent {
  const RefreshCart();
}

class AddItemToCart extends CartEvent {
  final CartItem cartItem;

  const AddItemToCart({required this.cartItem});

  @override
  List<Object?> get props => [cartItem];
}

class RemoveItemFromCart extends CartEvent {
  final String cartItemId;

  const RemoveItemFromCart({required this.cartItemId});

  @override
  List<Object?> get props => [cartItemId];
}

class RemoveItemFromCartByQuantity extends CartEvent {
  final String cartItemId;
  final int quantity;

  const RemoveItemFromCartByQuantity({
    required this.cartItemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class UpdateItemQuantity extends CartEvent {
  final String cartItemId;
  final int quantity;

  const UpdateItemQuantity({
    required this.cartItemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}
