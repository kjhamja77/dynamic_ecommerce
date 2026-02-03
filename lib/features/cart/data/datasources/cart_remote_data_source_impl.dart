import 'package:flutter/foundation.dart';
import '../../../../core/constants/endpoints.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import '../models/cart_response_model.dart';
import 'cart_remote_data_source.dart';

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient apiClient;

  CartRemoteDataSourceImpl(this.apiClient);

  @override
  Future<CartResponseModel> getCartItems({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.cart,
        method: 'POST',
        params: {
          'action': 'get',
          'page': page,
          'page_size': pageSize,
        },
      );

      final envelope = apiClient.parseRpcEnvelope(response.data);
      if (envelope.status != 'success') {
        throw Exception(envelope.message ?? 'Failed to get cart items');
      }

      final data = envelope.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid response format');
      }
      
      return CartResponseModel.fromApiJson(data);
    } catch (e, s) {
      debugPrint('CartRemoteDataSourceImpl.getCartItems error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<CartResponseModel> addToCart(int productId, int quantity) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.cart,
        method: 'POST',
        params: {
          'action': 'add',
          'product_id': productId,
          'quantity': quantity,
        },
      );

      final envelope = apiClient.parseRpcEnvelope(response.data);
      if (envelope.status != 'success') {
        throw Exception(envelope.message ?? 'Failed to add item to cart');
      }

      final data = envelope.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid response format');
      }

      return CartResponseModel.fromApiJson(data);
    } catch (e, s) {
      debugPrint('CartRemoteDataSourceImpl.addToCart error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<CartResponseModel> updateCartItemQuantity(int productId, int quantity) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.cart,
        method: 'POST',
        params: {
          'action': 'update',
          'product_id': productId,
          'quantity': quantity, // Send the target quantity for update operations
        },
      );

      final envelope = apiClient.parseRpcEnvelope(response.data);
      if (envelope.status != 'success') {
        throw Exception(envelope.message ?? 'Failed to update cart item quantity');
      }

      final data = envelope.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid response format');
      }

      return CartResponseModel.fromApiJson(data);
    } catch (e, s) {
      debugPrint('CartRemoteDataSourceImpl.updateCartItemQuantity error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<CartResponseModel> removeFromCartByQuantity(int productId, int quantity) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.cart,
        method: 'POST',
        params: {
          'action': 'remove',
          'product_id': productId,
          'quantity': quantity, // Send the actual quantity to remove
        },
      );

      final envelope = apiClient.parseRpcEnvelope(response.data);
      if (envelope.status != 'success') {
        throw Exception(envelope.message ?? 'Failed to remove item from cart');
      }

      final data = envelope.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid response format');
      }

      return CartResponseModel.fromApiJson(data);
    } catch (e, s) {
      debugPrint('CartRemoteDataSourceImpl.removeFromCartByQuantity error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<CartResponseModel> removeFromCart(int productId) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.cart,
        method: 'POST',
        params: {
          'action': 'remove',
          'product_id': productId,
          'quantity': 1, // Always send 1 for remove operations
        },
      );

      final envelope = apiClient.parseRpcEnvelope(response.data);
      if (envelope.status != 'success') {
        throw Exception(envelope.message ?? 'Failed to remove item from cart');
      }

      final data = envelope.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid response format');
      }

      return CartResponseModel.fromApiJson(data);
    } catch (e, s) {
      debugPrint('CartRemoteDataSourceImpl.removeFromCart error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<CartResponseModel> clearCart() async {
    try {
      debugPrint('CartRemoteDataSourceImpl.clearCart: Clearing entire cart using clear_cart action');
      
      final response = await apiClient.requestRpc(
        Endpoints.cart,
        method: 'POST',
        params: {
          'action': 'clear_cart',
        },
      );

      debugPrint('CartRemoteDataSourceImpl.clearCart: API response received');
      
      final envelope = apiClient.parseRpcEnvelope(response.data);
      if (envelope.status != 'success') {
        throw Exception(envelope.message ?? 'Failed to clear cart');
      }

      final data = envelope.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid response format');
      }

      debugPrint('CartRemoteDataSourceImpl.clearCart: Cart cleared successfully');
      return CartResponseModel.fromApiJson(data);
    } catch (e, s) {
      debugPrint('CartRemoteDataSourceImpl.clearCart: clear_cart action failed: $e');
      
      // Fallback: Try to get current cart items and remove them individually
      try {
        debugPrint('CartRemoteDataSourceImpl.clearCart: Attempting fallback - removing items individually');
        
        // First, get current cart items
        final currentCartResponse = await getCartItems();
        
        // If cart is already empty, return success
        if (currentCartResponse.lines.isEmpty) {
          debugPrint('CartRemoteDataSourceImpl.clearCart: Cart is already empty');
          return currentCartResponse;
        }
        
        // Remove each item individually
        for (final line in currentCartResponse.lines) {
          try {
            debugPrint('CartRemoteDataSourceImpl.clearCart: Removing item ${line.productId} with quantity ${line.quantity}');
            await apiClient.requestRpc(
              Endpoints.cart,
              method: 'POST',
              params: {
                'action': 'remove',
                'product_id': line.productId,
                'quantity': line.quantity, // Remove all quantity of this item
              },
            );
            debugPrint('CartRemoteDataSourceImpl.clearCart: Successfully removed item ${line.productId}');
          } catch (itemError) {
            debugPrint('CartRemoteDataSourceImpl.clearCart: Failed to remove item ${line.productId}: $itemError');
            // Continue with other items even if one fails
          }
        }
        
        // Get final cart state after individual removals
        final finalCartResponse = await getCartItems();
        debugPrint('CartRemoteDataSourceImpl.clearCart: Fallback completed, final cart has ${finalCartResponse.lines.length} items');
        return finalCartResponse;
        
      } catch (fallbackError) {
        debugPrint('CartRemoteDataSourceImpl.clearCart: Fallback also failed: $fallbackError');
        debugPrintStack(stackTrace: s);
        rethrow;
      }
    }
  }
}
