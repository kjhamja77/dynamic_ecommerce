import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

class GetCart implements UseCase<CartData, NoParams> {
  final CartRepository repository;

  GetCart(this.repository);

  @override
  Future<Either<Failure, CartData>> call(NoParams params) async {
    return await repository.getCartItems();
  }
}
