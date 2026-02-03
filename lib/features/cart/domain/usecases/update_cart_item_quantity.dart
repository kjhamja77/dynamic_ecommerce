import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemQuantity implements UseCase<CartItem, UpdateCartItemQuantityParams> {
  final CartRepository repository;

  UpdateCartItemQuantity(this.repository);

  @override
  Future<Either<Failure, CartItem>> call(UpdateCartItemQuantityParams params) async {
    return await repository.updateCartItemQuantity(params.cartItemId, params.quantity);
  }
}

class UpdateCartItemQuantityParams {
  final String cartItemId;
  final int quantity;

  UpdateCartItemQuantityParams({
    required this.cartItemId,
    required this.quantity,
  });
}
