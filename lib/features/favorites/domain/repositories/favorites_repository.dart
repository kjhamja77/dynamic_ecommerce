import 'package:dartz/dartz.dart';
import '../entities/favorite_product.dart';
import '../../../../core/errors/failures.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoriteProduct>>> getFavorites();
  Future<Either<Failure, void>> addToFavorites(FavoriteProduct product);
  Future<Either<Failure, void>> removeFromFavorites(String productId);
  Future<Either<Failure, bool>> isFavorite(String productId);
  Future<Either<Failure, void>> clearFavorites();
}
