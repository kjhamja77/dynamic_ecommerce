import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as developer;
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/product_details_repository.dart';
import '../../../cart/domain/entities/cart_item.dart';

class AddToCartParams extends Equatable {
  final String productId;
  final String colorId;
  final String sizeId;
  final int quantity;

  const AddToCartParams({
    required this.productId,
    required this.colorId,
    required this.sizeId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, colorId, sizeId, quantity];
}

class AddToCart implements UseCase<CartItem, AddToCartParams> {
  final ProductDetailsRepository repository;

  const AddToCart(this.repository);

  @override
  Future<Either<Failure, CartItem>> call(AddToCartParams params) async {
    developer.log('🔄 AddToCart use case called with params: ${params.toString()}');
    
    final result = await repository.addToCart(
      params.productId,
      params.colorId,
      params.sizeId,
      params.quantity,
    );
    
    developer.log('📋 Repository result: ${result.toString()}');
    return result;
  }
}
