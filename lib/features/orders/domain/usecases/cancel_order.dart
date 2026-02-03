import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CancelOrderParams {
  final String orderId;

  const CancelOrderParams(this.orderId);
}

class CancelOrder implements UseCase<Order, CancelOrderParams> {
  final OrderRepository repository;

  const CancelOrder(this.repository);

  @override
  Future<dartz.Either<Failure, Order>> call(CancelOrderParams params) async {
    return await repository.cancelOrder(params.orderId);
  }
}
