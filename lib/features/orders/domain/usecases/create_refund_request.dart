import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/refund_request.dart';
import '../repositories/order_repository.dart';

class RefundLineInput {
  final int lineId;
  final double quantity;

  const RefundLineInput({
    required this.lineId,
    required this.quantity,
  });
}

class CreateRefundRequestParams {
  final int orderId;
  final List<RefundLineInput> refundLines;
  final String reason;

  const CreateRefundRequestParams({
    required this.orderId,
    required this.refundLines,
    required this.reason,
  });
}

class CreateRefundRequest
    implements UseCase<RefundRequest, CreateRefundRequestParams> {
  final OrderRepository repository;

  const CreateRefundRequest(this.repository);

  @override
  Future<dartz.Either<Failure, RefundRequest>> call(
    CreateRefundRequestParams params,
  ) {
    return repository.createRefundRequest(
      orderId: params.orderId,
      refundLines: params.refundLines,
      reason: params.reason,
    );
  }
}

