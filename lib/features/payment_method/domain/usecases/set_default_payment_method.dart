import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_method_repository.dart';

class SetDefaultPaymentMethodUseCase implements UseCase<PaymentMethod, String> {
  final PaymentMethodRepository repository;

  SetDefaultPaymentMethodUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentMethod>> call(String params) async {
    return await repository.setDefaultPaymentMethod(params);
  }
}
