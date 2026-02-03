import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/product_details_repository.dart';

class ToggleFavorite implements UseCase<void, String> {
  final ProductDetailsRepository repository;

  const ToggleFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(String productId) async {
    return await repository.toggleFavorite(productId);
  }
}
