import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/order_repository.dart';

class CancelRefundRequestParams {
  final int requestId;

  const CancelRefundRequestParams(this.requestId);
}

class CancelRefundRequest
    implements UseCase<void, CancelRefundRequestParams> {
  final OrderRepository repository;

  const CancelRefundRequest(this.repository);

  @override
  Future<dartz.Either<Failure, void>> call(
    CancelRefundRequestParams params,
  ) {
    return repository.cancelRefundRequest(requestId: params.requestId);
  }
}

