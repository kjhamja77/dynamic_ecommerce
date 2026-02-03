import '../models/favorite_product_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteProductModel>> getWishlist();
  Future<void> addToWishlist(int productId);
  Future<void> removeFromWishlist(int productId);
}
