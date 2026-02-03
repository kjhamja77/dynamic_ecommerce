import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../repositories/order_repository.dart';

class GetDeliveryStatusParams {
  final int orderId;

  const GetDeliveryStatusParams(this.orderId);
}

class GetDeliveryStatus implements UseCase<DeliveryStatusDto, GetDeliveryStatusParams> {
  final OrderRepository repository;

  const GetDeliveryStatus(this.repository);

  @override
  Future<dartz.Either<Failure, DeliveryStatusDto>> call(GetDeliveryStatusParams params) async {
    return await repository.getDeliveryStatus(orderId: params.orderId);
  }
}


