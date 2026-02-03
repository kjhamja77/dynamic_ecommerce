import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/checkout_summary.dart';
import '../repositories/checkout_repository.dart';

class GetCheckoutSummary implements UseCase<CheckoutSummary, NoParams> {
  final CheckoutRepository repository;

  GetCheckoutSummary(this.repository);

  @override
  Future<Either<Failure, CheckoutSummary>> call(NoParams params) async {
    return await repository.getCheckoutSummary();
  }
}
