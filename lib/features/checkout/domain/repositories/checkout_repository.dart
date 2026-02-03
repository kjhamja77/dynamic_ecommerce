import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/checkout_item.dart';
import '../entities/checkout_summary.dart';
import '../entities/shipping_address.dart';
import '../entities/payment_method.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, List<CheckoutItem>>> getCheckoutItems();
  Future<Either<Failure, CheckoutSummary>> getCheckoutSummary();
  Future<Either<Failure, List<ShippingAddress>>> getShippingAddresses();
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods();
  Future<Either<Failure, void>> updateCheckoutItem(String itemId, bool isSelected);
  Future<Either<Failure, void>> removeCheckoutItem(String itemId);
  Future<Either<Failure, void>> addShippingAddress(ShippingAddress address);
  Future<Either<Failure, void>> updateShippingAddress(ShippingAddress address);
  Future<Either<Failure, void>> removeShippingAddress(String addressId);
  Future<Either<Failure, void>> addPaymentMethod(PaymentMethod method);
  Future<Either<Failure, void>> updatePaymentMethod(PaymentMethod method);
  Future<Either<Failure, void>> removePaymentMethod(String methodId);
  Future<Either<Failure, String>> placeOrder({
    required int orderId,
    required String addressId,
  });

  // Remote checkout extensions
  Future<Either<Failure, List<dynamic>>> getShippingMethods({required int orderId});
  Future<Either<Failure, CheckoutSummary>> applyShippingMethod({required int orderId, required int shippingMethodId});
  Future<Either<Failure, String>> applyPaymentMethod({required int orderId, required int paymentMethodId});
  Future<Either<Failure, Map<String, String>>> createAlQasehPayment({required int orderId});
}
