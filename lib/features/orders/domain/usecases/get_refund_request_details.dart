import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/refund_request.dart';
import '../repositories/order_repository.dart';

class GetRefundRequestDetailsParams {
  final int refundRequestId;

  const GetRefundRequestDetailsParams(this.refundRequestId);
}

class GetRefundRequestDetails
    implements UseCase<RefundRequest, GetRefundRequestDetailsParams> {
  final OrderRepository repository;

  const GetRefundRequestDetails(this.repository);

  @override
  Future<dartz.Either<Failure, RefundRequest>> call(
    GetRefundRequestDetailsParams params,
  ) {
    return repository.getRefundRequestDetails(
      refundRequestId: params.refundRequestId,
    );
  }
}

