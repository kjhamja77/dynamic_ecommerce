import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_method_repository.dart';

class DeletePaymentMethodUseCase implements UseCase<bool, String> {
  final PaymentMethodRepository repository;

  DeletePaymentMethodUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String params) async {
    return await repository.deletePaymentMethod(params);
  }
}
