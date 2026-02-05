import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/favorite_product_model.dart';

abstract class FavoritesLocalDataSource {
  Future<List<FavoriteProductModel>> getFavorites();
  Future<void> addToFavorites(FavoriteProductModel product);
  Future<void> removeFromFavorites(String productId);
  Future<bool> isFavorite(String productId);
  Future<void> clearFavorites();
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences sharedPreferences;

  FavoritesLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<FavoriteProductModel>> getFavorites() async {
    final favoritesJson = sharedPreferences.getStringList(AppConstants.favoritesKey) ?? [];
    return favoritesJson
        .map((json) => FavoriteProductModel.fromJson(jsonDecode(json)))
        .toList();
  }

  @override
  Future<void> addToFavorites(FavoriteProductModel product) async {
    final favorites = await getFavorites();
    
    // Check if product already exists
    if (!favorites.any((fav) => fav.id == product.id)) {
      favorites.add(product);
      await _saveFavorites(favorites);
    }
  }

  @override
  Future<void> removeFromFavorites(String productId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((fav) => fav.id == productId);
    await _saveFavorites(favorites);
  }

  @override
  Future<bool> isFavorite(String productId) async {
    final favorites = await getFavorites();
    return favorites.any((fav) => fav.id == productId);
  }

  @override
  Future<void> clearFavorites() async {
    await sharedPreferences.remove(AppConstants.favoritesKey);
  }

  Future<void> _saveFavorites(List<FavoriteProductModel> favorites) async {
    final favoritesJson = favorites
        .map((product) => jsonEncode(product.toJson()))
        .toList();
    await sharedPreferences.setStringList(AppConstants.favoritesKey, favoritesJson);
  }
}
