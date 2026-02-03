import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/checkout_repository.dart';

class PlaceOrderParams {
  final int orderId;
  final String addressId;

  const PlaceOrderParams({
    required this.orderId,
    required this.addressId,
  });
}

class PlaceOrder implements UseCase<String, PlaceOrderParams> {
  final CheckoutRepository repository;

  PlaceOrder(this.repository);

  @override
  Future<Either<Failure, String>> call(PlaceOrderParams params) {
    return repository.placeOrder(
      orderId: params.orderId,
      addressId: params.addressId,
    );
  }
}


