import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CreateOrderParams {
  final Order order;

  const CreateOrderParams(this.order);
}

class CreateOrder implements UseCase<Order, CreateOrderParams> {
  final OrderRepository repository;

  const CreateOrder(this.repository);

  @override
  Future<dartz.Either<Failure, Order>> call(CreateOrderParams params) async {
    return await repository.createOrder(params.order);
  }
}
