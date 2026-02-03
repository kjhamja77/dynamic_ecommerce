import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartByQuantity implements UseCase<void, RemoveFromCartByQuantityParams> {
  final CartRepository repository;

  RemoveFromCartByQuantity(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromCartByQuantityParams params) async {
    return await repository.removeFromCartByQuantity(params.cartItemId, params.quantity);
  }
}

class RemoveFromCartByQuantityParams {
  final String cartItemId;
  final int quantity;

  RemoveFromCartByQuantityParams({
    required this.cartItemId,
    required this.quantity,
  });
}
