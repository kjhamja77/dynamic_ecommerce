import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> cart);
  Future<void> saveCartItem(CartItemModel cartItem);
  Future<bool> clearCart();
}

const String cachedCartKey = 'CACHED_CART';

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CartItemModel>> getCart() async {
    try {
      final jsonString = sharedPreferences.getString(cachedCartKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        return cartItemModelListFromJson(jsonString);
      }
      return [];
    } catch (e) {
      throw CacheFailure('Failed to get cart from cache');
    }
  }

  @override
  Future<void> saveCart(List<CartItemModel> cart) async {
    try {
      final jsonString = cartItemModelListToJson(cart);
      await sharedPreferences.setString(cachedCartKey, jsonString);
    } catch (e) {
      throw CacheFailure('Failed to save cart to cache');
    }
  }

  @override
  Future<void> saveCartItem(CartItemModel cartItem) async {
    try {
      final currentCart = await getCart();
      
      // Check if item already exists by ID
      final existingIndex = currentCart.indexWhere((item) => item.id == cartItem.id);

      if (existingIndex != -1) {
        // Item exists, merge quantities
        final existingItem = currentCart[existingIndex];
        final newQuantity = existingItem.quantity + cartItem.quantity;
        
        // Update quantity and timestamp of existing item
        final updatedItem = currentCart[existingIndex].copyWith(
          quantity: newQuantity,
          addedAt: DateTime.now(),
        );
        
        currentCart[existingIndex] = updatedItem;
      } else {
        // Add new item
        currentCart.add(cartItem);
      }

      await saveCart(currentCart);
    } catch (e) {
      throw CacheFailure('Failed to save cart item to cache');
    }
  }

  @override
  Future<bool> clearCart() async {
    try {
      return await sharedPreferences.remove(cachedCartKey);
    } catch (e) {
      throw CacheFailure('Failed to clear cart from cache');
    }
  }
}
