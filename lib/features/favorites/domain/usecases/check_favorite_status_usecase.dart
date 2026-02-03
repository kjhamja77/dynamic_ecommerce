import 'package:dartz/dartz.dart';
import '../repositories/favorites_repository.dart';
import '../../../../core/errors/failures.dart';

class CheckFavoriteStatusUseCase {
  final FavoritesRepository repository;

  CheckFavoriteStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call(String productId) async {
    return await repository.isFavorite(productId);
  }
}
