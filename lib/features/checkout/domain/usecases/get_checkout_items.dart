import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/checkout_item.dart';
import '../repositories/checkout_repository.dart';

class GetCheckoutItems implements UseCase<List<CheckoutItem>, NoParams> {
  final CheckoutRepository repository;

  GetCheckoutItems(this.repository);

  @override
  Future<Either<Failure, List<CheckoutItem>>> call(NoParams params) async {
    return await repository.getCheckoutItems();
  }
}
