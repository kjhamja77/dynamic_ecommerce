import 'package:dartz/dartz.dart';
import '../repositories/favorites_repository.dart';
import '../../../../core/errors/failures.dart';

class RemoveFromFavoritesUseCase {
  final FavoritesRepository repository;

  RemoveFromFavoritesUseCase(this.repository);

  Future<Either<Failure, void>> call(String productId) async {
    return await repository.removeFromFavorites(productId);
  }
}
