import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_method_repository.dart';
import '../validators/payment_card_validator.dart';

class AddPaymentMethodUseCase implements UseCase<PaymentMethod, PaymentMethod> {
  final PaymentMethodRepository repository;
  final PaymentCardValidator validator;

  AddPaymentMethodUseCase(this.repository, {PaymentCardValidator? validator})
      : validator = validator ?? const PaymentCardValidator();

  @override
  Future<Either<Failure, PaymentMethod>> call(PaymentMethod params) async {
    // Only enforce card details for card-based methods
    final isCard = params.type == PaymentMethodType.creditCard || params.type == PaymentMethodType.debitCard;
    if (isCard) {
      final cardNumber = (params.cardNumber ?? '').trim();
      final expiry = (params.expiryDate ?? '').trim();
      final cvv = (params.cvvCode ?? '').trim();
      final holder = (params.cardHolderName ?? '').trim();

      if (!validator.isValidCardNumber(cardNumber)) {
        return Left(ValidationFailure('Invalid card number'));
      }
      if (!validator.isValidExpiry(expiry)) {
        return Left(ValidationFailure('Invalid expiry date'));
      }
      if (!validator.isValidCvv(cvv, params.type)) {
        return Left(ValidationFailure('Invalid CVV'));
      }
      if (holder.isEmpty) {
        return Left(ValidationFailure('Cardholder name is required'));
      }
    }
    return await repository.addPaymentMethod(params);
  }
}
