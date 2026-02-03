import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_method.dart';

abstract class PaymentMethodRepository {
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods();
  Future<Either<Failure, PaymentMethod>> addPaymentMethod(PaymentMethod paymentMethod);
  Future<Either<Failure, PaymentMethod>> updatePaymentMethod(PaymentMethod paymentMethod);
  Future<Either<Failure, bool>> deletePaymentMethod(String id);
  Future<Either<Failure, PaymentMethod>> setDefaultPaymentMethod(String id);
}
