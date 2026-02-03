import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCart implements UseCase<void, RemoveFromCartParams> {
  final CartRepository repository;

  RemoveFromCart(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromCartParams params) async {
    return await repository.removeFromCart(params.cartItemId);
  }
}

class RemoveFromCartParams {
  final String cartItemId;

  RemoveFromCartParams({required this.cartItemId});
}
