import 'package:dartz/dartz.dart';
import '../entities/favorite_product.dart';
import '../repositories/favorites_repository.dart';
import '../../../../core/errors/failures.dart';

class AddToFavoritesUseCase {
  final FavoritesRepository repository;

  AddToFavoritesUseCase(this.repository);

  Future<Either<Failure, void>> call(FavoriteProduct product) async {
    return await repository.addToFavorites(product);
  }
}
