import 'package:dartz/dartz.dart' as dartz;
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrdersParams extends Equatable {
  final int page;
  final int limit;

  const GetOrdersParams({
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [page, limit];
}

class GetOrders implements UseCase<List<Order>, GetOrdersParams> {
  final OrderRepository repository;

  const GetOrders(this.repository);

  @override
  Future<dartz.Either<Failure, List<Order>>> call(GetOrdersParams params) async {
    return await repository.getOrders(
      page: params.page,
      limit: params.limit,
    );
  }
}
