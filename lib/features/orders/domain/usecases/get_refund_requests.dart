import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/refund_request.dart';
import '../repositories/order_repository.dart';

class GetRefundRequestsParams {
  final int page;

  const GetRefundRequestsParams({this.page = 1});
}

class GetRefundRequests
    implements UseCase<List<RefundRequest>, GetRefundRequestsParams> {
  final OrderRepository repository;

  const GetRefundRequests(this.repository);

  @override
  Future<dartz.Either<Failure, List<RefundRequest>>> call(
    GetRefundRequestsParams params,
  ) {
    return repository.getRefundRequests(page: params.page);
  }
}

