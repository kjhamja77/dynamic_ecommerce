import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdParams {
  final String orderId;

  const GetOrderByIdParams(this.orderId);
}

class GetOrderById implements UseCase<Order, GetOrderByIdParams> {
  final OrderRepository repository;

  const GetOrderById(this.repository);

  @override
  Future<dartz.Either<Failure, Order>> call(GetOrderByIdParams params) async {
    return await repository.getOrderById(params.orderId);
  }
}
