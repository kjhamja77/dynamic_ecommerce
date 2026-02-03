import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/checkout_item.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/shipping_address.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_data_source.dart';
import '../datasources/checkout_local_data_source.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutLocalDataSource localDataSource;
  final CheckoutRemoteDataSource? remoteDataSource;
  final NetworkInfo networkInfo;

  CheckoutRepositoryImpl({
    required this.localDataSource,
    required this.networkInfo,
    this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<CheckoutItem>>> getCheckoutItems() async {
    try {
      final items = await localDataSource.getCheckoutItems();
      return Right(items);
    } catch (e) {
      return Left(CacheFailure('Failed to get checkout items: $e'));
    }
  }

  @override
  Future<Either<Failure, CheckoutSummary>> getCheckoutSummary() async {
    try {
      final summary = await localDataSource.getCheckoutSummary();
      return Right(summary);
    } catch (e) {
      return Left(CacheFailure('Failed to get checkout summary: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ShippingAddress>>> getShippingAddresses() async {
    try {
      final addresses = await localDataSource.getShippingAddresses();
      return Right(addresses);
    } catch (e) {
      return Left(CacheFailure('Failed to get shipping addresses: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods() async {
    try {
      if (remoteDataSource != null && await networkInfo.isConnected) {
        try {
          final remoteMethods = await remoteDataSource!.getPaymentMethods();
          if (remoteMethods.isNotEmpty) {
            final mapped = _mapPaymentMethodDtos(remoteMethods);
            return Right(mapped);
          }
        } catch (e) {
          // Fall back to local if remote call fails
        }
      }
      final methods = await localDataSource.getPaymentMethods();
      return Right(methods);
    } catch (e) {
      return Left(CacheFailure('Failed to get payment methods: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCheckoutItem(String itemId, bool isSelected) async {
    try {
      await localDataSource.updateCheckoutItem(itemId, isSelected);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update checkout item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeCheckoutItem(String itemId) async {
    try {
      await localDataSource.removeCheckoutItem(itemId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to remove checkout item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addShippingAddress(ShippingAddress address) async {
    try {
      await localDataSource.addShippingAddress(address);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add shipping address: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateShippingAddress(ShippingAddress address) async {
    try {
      await localDataSource.updateShippingAddress(address);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update shipping address: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeShippingAddress(String addressId) async {
    try {
      await localDataSource.removeShippingAddress(addressId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to remove shipping address: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addPaymentMethod(PaymentMethod method) async {
    try {
      await localDataSource.addPaymentMethod(method);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add payment method: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePaymentMethod(PaymentMethod method) async {
    try {
      await localDataSource.updatePaymentMethod(method);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update payment method: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removePaymentMethod(String methodId) async {
    try {
      await localDataSource.removePaymentMethod(methodId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to remove payment method: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> placeOrder({
    required int orderId,
    required String addressId,
  }) async {
    try {
      if (remoteDataSource != null && await networkInfo.isConnected) {
        final parsedAddressId = int.tryParse(addressId);
        if (parsedAddressId == null) {
          return Left(ValidationFailure('Invalid address id'));
        }
        final confirmation = await remoteDataSource!.placeOrder(
          orderId: orderId,
          addressId: parsedAddressId,
        );
        return Right(confirmation);
      }

      // Fallback simulation when remote integration is unavailable
      await Future.delayed(const Duration(seconds: 2));
      final simulatedOrderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      return Right(simulatedOrderId);
    } catch (e) {
      return Left(CacheFailure('Failed to process order: $e'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getShippingMethods({required int orderId}) async {
    try {
      if (remoteDataSource == null) {
        return const Right(<dynamic>[]);
      }
      final list = await remoteDataSource!.getShippingMethods(orderId: orderId);
      return Right(list);
    } catch (e) {
      return Left(CacheFailure('Failed to get shipping methods: $e'));
    }
  }

  @override
  Future<Either<Failure, CheckoutSummary>> applyShippingMethod({required int orderId, required int shippingMethodId}) async {
    try {
      if (remoteDataSource == null) {
        return Left(CacheFailure('Remote DS not configured'));
      }
      final totals = await remoteDataSource!.applyShippingMethod(orderId: orderId, shippingMethodId: shippingMethodId);
      // Fallback compute shipping if backend didn't include it explicitly
      double computedShipping = totals.shippingPrice;
      if (computedShipping == 0.0) {
        final diff = totals.amountTotal - totals.amountUntaxed - totals.amountTax;
        computedShipping = diff > 0 ? diff : 0.0;
      }
      final summary = CheckoutSummary(
        subtotal: totals.amountUntaxed,
        shipping: computedShipping,
        tax: totals.amountTax,
        discount: 0.0,
        total: totals.amountTotal,
        totalItems: 0,
      );
      return Right(summary);
    } catch (e) {
      return Left(CacheFailure('Failed to apply shipping method: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> applyPaymentMethod({required int orderId, required int paymentMethodId}) async {
    try {
      if (remoteDataSource == null) {
        return Left(CacheFailure('Remote DS not configured'));
      }
      final message = await remoteDataSource!.applyPaymentMethod(
        orderId: orderId,
        paymentMethodId: paymentMethodId,
      );
      return Right(message);
    } catch (e) {
      return Left(CacheFailure('Failed to apply payment method: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> createAlQasehPayment({required int orderId}) async {
    try {
      if (remoteDataSource == null) {
        return Left(CacheFailure('Remote DS not configured'));
      }
      final paymentResponse = await remoteDataSource!.createAlQasehPayment(orderId: orderId);
      return Right({
        'payment_url': paymentResponse.paymentUrl,
        'payment_id': paymentResponse.paymentId,
        'token': paymentResponse.token,
      });
    } catch (e) {
      return Left(CacheFailure('Failed to create Al Qaseh payment: $e'));
    }
  }

  // Promo APIs passthrough (optional exposure if needed later for UI)
  Future<Either<Failure, List<Map<String, dynamic>>>> getPromoPricelists({required int orderId}) async {
    try {
      if (remoteDataSource == null) return const Right(<Map<String, dynamic>>[]);
      final list = await remoteDataSource!.getPromoPricelists(orderId: orderId);
      return Right(list);
    } catch (e) {
      return Left(CacheFailure('Failed to get promo pricelists: $e'));
    }
  }

  Future<Either<Failure, CheckoutSummary>> applyPromo({required int orderId, required int pricelistId, required String promoCode}) async {
    try {
      if (remoteDataSource == null) return Left(CacheFailure('Remote DS not configured'));
      final totals = await remoteDataSource!.applyPromo(orderId: orderId, pricelistId: pricelistId, promoCode: promoCode);
      final summary = CheckoutSummary(
        subtotal: totals.amountUntaxed,
        shipping: 0.0,
        tax: totals.amountTax,
        discount: 0.0,
        total: totals.amountTotal,
        totalItems: 0,
      );
      return Right(summary);
    } catch (e) {
      return Left(CacheFailure('Failed to apply promo: $e'));
    }
  }

  List<PaymentMethod> _mapPaymentMethodDtos(List<PaymentMethodDto> dtos) {
    bool hasDefault = false;
    return dtos.map((dto) {
      // Check if URL contains alqaseh to detect Al Qaseh payment method
      final isAlQasehUrl = dto.url != null && 
          (dto.url!.toLowerCase().contains('alqaseh') || 
           dto.url!.toLowerCase().contains('/api/alqaseh'));
      
      final type = isAlQasehUrl 
          ? PaymentType.alQaseh 
          : _inferPaymentType(dto.name);
      
      final method = PaymentMethod(
        id: dto.id.toString(),
        type: type,
        name: dto.name,
        lastFourDigits: null,
        cardBrand: null,
        isDefault: !hasDefault,
        paymentUrl: dto.url,
      );
      hasDefault = true;
      return method;
    }).toList();
  }

  PaymentType _inferPaymentType(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('al qaseh') || lower.contains('qaseh') || lower.contains('alqaseh')) {
      return PaymentType.alQaseh;
    }
    if (lower.contains('cash')) return PaymentType.cashOnDelivery;
    if (lower.contains('paypal')) return PaymentType.paypal;
    if (lower.contains('apple')) return PaymentType.applePay;
    if (lower.contains('google')) return PaymentType.googlePay;
    if (lower.contains('card')) return PaymentType.creditCard;
    if (lower.contains('wire') || lower.contains('transfer') || lower.contains('bank')) {
      return PaymentType.bankTransfer;
    }
    return PaymentType.bankTransfer;
  }
}
