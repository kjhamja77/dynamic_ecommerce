import 'package:dartz/dartz.dart';
import 'dart:developer' as developer;
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class AddToCart implements UseCase<CartItem, AddToCartParams> {
  final CartRepository repository;

  AddToCart(this.repository);

  @override
  Future<Either<Failure, CartItem>> call(AddToCartParams params) async {
    developer.log('🔄 Cart AddToCart use case called with cartItem: ${params.cartItem.toString()}');
    
    final result = await repository.addToCart(params.cartItem);
    developer.log('📋 Cart AddToCart repository result: ${result.toString()}');
    
    return result;
  }
}

class AddToCartParams {
  final CartItem cartItem;

  AddToCartParams({required this.cartItem});
}
