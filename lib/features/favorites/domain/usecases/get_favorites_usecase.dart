import 'package:dartz/dartz.dart';
import '../entities/favorite_product.dart';
import '../repositories/favorites_repository.dart';
import '../../../../core/errors/failures.dart';

class GetFavoritesUseCase {
  final FavoritesRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<Either<Failure, List<FavoriteProduct>>> call() async {
    return await repository.getFavorites();
  }
}
