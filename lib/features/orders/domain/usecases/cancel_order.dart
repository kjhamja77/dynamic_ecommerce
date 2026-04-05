import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cancel_order_result.dart';
import '../repositories/order_repository.dart';

class CancelOrderParams {
  final String orderId;

  const CancelOrderParams(this.orderId);
}

class CancelOrder implements UseCase<CancelOrderResult, CancelOrderParams> {
  final OrderRepository repository;

  const CancelOrder(this.repository);

  @override
  Future<dartz.Either<Failure, CancelOrderResult>> call(
      CancelOrderParams params) async {
    return repository.cancelOrder(params.orderId);
  }
}
