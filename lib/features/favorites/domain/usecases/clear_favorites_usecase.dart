import 'package:dartz/dartz.dart';
import '../repositories/favorites_repository.dart';
import '../../../../core/errors/failures.dart';

class ClearFavoritesUseCase {
  final FavoritesRepository repository;

  ClearFavoritesUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.clearFavorites();
  }
}
