import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cart_item.dart';
import '../../data/models/cart_response_model.dart';

class CartData {
  final List<CartItem> items;
  final CartResponseModel? response;

  const CartData({required this.items, this.response});
}

abstract class CartRepository {
  Future<Either<Failure, CartData>> getCartItems();
  Future<Either<Failure, CartItem>> addToCart(CartItem cartItem);
  Future<Either<Failure, CartItem>> updateCartItemQuantity(String cartItemId, int quantity);
  Future<Either<Failure, void>> removeFromCart(String cartItemId);
  Future<Either<Failure, void>> removeFromCartByQuantity(String cartItemId, int quantity);
  Future<Either<Failure, void>> clearCart();
}
