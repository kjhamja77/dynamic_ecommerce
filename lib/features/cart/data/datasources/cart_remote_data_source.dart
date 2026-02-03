import '../models/cart_response_model.dart';

abstract class CartRemoteDataSource {
  Future<CartResponseModel> getCartItems({int page = 1, int pageSize = 10});
  Future<CartResponseModel> addToCart(int productId, int quantity);
  Future<CartResponseModel> updateCartItemQuantity(int productId, int quantity);
  Future<CartResponseModel> removeFromCartByQuantity(int productId, int quantity);
  Future<CartResponseModel> removeFromCart(int productId);
  Future<CartResponseModel> clearCart();
}
