import 'package:equatable/equatable.dart';
import '../../domain/entities/checkout_item.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/shipping_address.dart';
import '../../domain/entities/payment_method.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutLoaded extends CheckoutState {
  final List<CheckoutItem> items;
  final CheckoutSummary summary;
  final List<ShippingAddress> shippingAddresses;
  final List<PaymentMethod> paymentMethods;
  final String? selectedShippingAddressId;
  final String? selectedPaymentMethodId;
  final int? selectedShippingMethodId;
  final bool isWaitingForNewAddress;
  final bool useCartTotals;
  final bool isApplyingPaymentMethod;
  final bool isProcessingDialogVisible;

  const CheckoutLoaded({
    required this.items,
    required this.summary,
    required this.shippingAddresses,
    required this.paymentMethods,
    this.selectedShippingAddressId,
    this.selectedPaymentMethodId,
    this.selectedShippingMethodId,
    this.isWaitingForNewAddress = false,
    this.useCartTotals = true,
    this.isApplyingPaymentMethod = false,
    this.isProcessingDialogVisible = false,
  });

  CheckoutLoaded copyWith({
    List<CheckoutItem>? items,
    CheckoutSummary? summary,
    List<ShippingAddress>? shippingAddresses,
    List<PaymentMethod>? paymentMethods,
    String? selectedShippingAddressId,
    String? selectedPaymentMethodId,
    int? selectedShippingMethodId,
    bool? isWaitingForNewAddress,
    bool? useCartTotals,
    bool? isApplyingPaymentMethod,
    bool? isProcessingDialogVisible,
  }) {
    return CheckoutLoaded(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      shippingAddresses: shippingAddresses ?? this.shippingAddresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedShippingAddressId: selectedShippingAddressId ?? this.selectedShippingAddressId,
      selectedPaymentMethodId: selectedPaymentMethodId ?? this.selectedPaymentMethodId,
      selectedShippingMethodId: selectedShippingMethodId ?? this.selectedShippingMethodId,
      isWaitingForNewAddress: isWaitingForNewAddress ?? this.isWaitingForNewAddress,
      useCartTotals: useCartTotals ?? this.useCartTotals,
      isApplyingPaymentMethod: isApplyingPaymentMethod ?? this.isApplyingPaymentMethod,
      isProcessingDialogVisible: isProcessingDialogVisible ?? this.isProcessingDialogVisible,
    );
  }

  @override
  List<Object?> get props => [
        items,
        summary,
        shippingAddresses,
        paymentMethods,
        selectedShippingAddressId,
        selectedPaymentMethodId,
        selectedShippingMethodId,
        isWaitingForNewAddress,
        useCartTotals,
        isApplyingPaymentMethod,
        isProcessingDialogVisible,
      ];
}

class ShippingMethodsLoading extends CheckoutState {}

class ShippingMethodsLoaded extends CheckoutState {
  final List<dynamic> methods;
  final CheckoutLoaded? previousState;
  const ShippingMethodsLoaded(this.methods, {this.previousState});

  @override
  List<Object?> get props => [methods, previousState];
}

class ShippingMethodApplying extends CheckoutState {
  final CheckoutLoaded snapshot;
  const ShippingMethodApplying(this.snapshot);

  @override
  List<Object?> get props => [snapshot];
}

class ShippingMethodApplied extends CheckoutState {
  final CheckoutSummary updatedSummary;
  const ShippingMethodApplied(this.updatedSummary);
}

class PaymentMethodApplying extends CheckoutState {
  final CheckoutLoaded snapshot;
  const PaymentMethodApplying(this.snapshot);

  @override
  List<Object?> get props => [snapshot];
}

class PaymentMethodApplied extends CheckoutState {
  final CheckoutLoaded snapshot;
  final String message;
  const PaymentMethodApplied(this.snapshot, this.message);

  @override
  List<Object?> get props => [snapshot, message];
}

class PaymentMethodFailure extends CheckoutState {
  final CheckoutLoaded snapshot;
  final String message;
  const PaymentMethodFailure(this.snapshot, this.message);

  @override
  List<Object?> get props => [snapshot, message];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError({required this.message});

  @override
  List<Object?> get props => [message];
}
