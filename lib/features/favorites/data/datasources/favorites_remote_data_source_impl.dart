import 'package:zalando_clone_app/core/network/api_client.dart';
import '../models/favorite_product_model.dart';
import 'favorites_remote_data_source.dart';

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final ApiClient apiClient;

  FavoritesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<FavoriteProductModel>> getWishlist() async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/product/wish-list',
        method: 'POST',
        params: {
          'action': 'list',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          // Handle the JSON-RPC response structure
          List<dynamic> wishlistData = [];
          
          if (data['result'] != null && data['result']['data'] != null) {
            final resultData = data['result']['data'];
            if (resultData['items'] != null) {
              wishlistData = resultData['items'] as List<dynamic>;
            }
          } else if (data['data'] is List<dynamic>) {
            // Fallback for direct array structure
            wishlistData = data['data'] as List<dynamic>;
          } else if (data['data'] is Map<String, dynamic> && data['data']['items'] != null) {
            // Fallback for items wrapper structure
            wishlistData = data['data']['items'] as List<dynamic>;
          }
          
          final products = wishlistData
              .map((item) {
                try {
                  return FavoriteProductModel.fromWishlistJson(item);
                } catch (e) {
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<FavoriteProductModel>()
              .toList();
          return products;
        }
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to get wishlist: $e');
    }
  }

  @override
  Future<void> addToWishlist(int productId) async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/product/wish-list',
        method: 'POST',
        params: {
          'action': 'add',
          'product_id': productId,
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to add to wishlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  @override
  Future<void> removeFromWishlist(int productId) async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/product/wish-list',
        method: 'POST',
        params: {
          'action': 'remove',
          'product_id': productId,
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to remove from wishlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }
}
