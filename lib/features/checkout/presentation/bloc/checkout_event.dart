import 'package:equatable/equatable.dart';
import '../../domain/entities/checkout_item.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/shipping_address.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadCheckout extends CheckoutEvent {
  final List<CartItem> cartItems;
  final CartState? cartState;
  
  const LoadCheckout({
    required this.cartItems,
    this.cartState,
  });
  
  @override
  List<Object?> get props => [cartItems, cartState];
}

class InitializeCheckoutFromCart extends CheckoutEvent {
  final List<CheckoutItem> items;
  final CheckoutSummary summary;
  const InitializeCheckoutFromCart({
    required this.items,
    required this.summary,
  });

  @override
  List<Object?> get props => [items, summary];
}

class UpdateCheckoutItem extends CheckoutEvent {
  final String itemId;
  final bool isSelected;

  const UpdateCheckoutItem({
    required this.itemId,
    required this.isSelected,
  });

  @override
  List<Object?> get props => [itemId, isSelected];
}

class RemoveCheckoutItem extends CheckoutEvent {
  final String itemId;

  const RemoveCheckoutItem({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class SelectShippingAddress extends CheckoutEvent {
  final String addressId;

  const SelectShippingAddress({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}

class SelectPaymentMethod extends CheckoutEvent {
  final String methodId;

  const SelectPaymentMethod({required this.methodId});

  @override
  List<Object?> get props => [methodId];
}

class LoadShippingMethods extends CheckoutEvent {
  final int orderId;
  const LoadShippingMethods(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class ApplyShippingMethod extends CheckoutEvent {
  final int orderId;
  final int shippingMethodId;
  const ApplyShippingMethod({required this.orderId, required this.shippingMethodId});

  @override
  List<Object?> get props => [orderId, shippingMethodId];
}

class ApplyPaymentMethod extends CheckoutEvent {
  final int orderId;
  final int paymentMethodId;
  const ApplyPaymentMethod({required this.orderId, required this.paymentMethodId});

  @override
  List<Object?> get props => [orderId, paymentMethodId];
}

class SelectShippingMethod extends CheckoutEvent {
  final int? shippingMethodId;
  const SelectShippingMethod({required this.shippingMethodId});

  @override
  List<Object?> get props => [shippingMethodId];
}

class SetWaitingForNewAddress extends CheckoutEvent {
  final bool isWaiting;
  const SetWaitingForNewAddress({required this.isWaiting});

  @override
  List<Object?> get props => [isWaiting];
}

class SetUseCartTotals extends CheckoutEvent {
  final bool useCartTotals;
  const SetUseCartTotals({required this.useCartTotals});

  @override
  List<Object?> get props => [useCartTotals];
}

class SetProcessingDialogVisible extends CheckoutEvent {
  final bool isVisible;
  const SetProcessingDialogVisible({required this.isVisible});

  @override
  List<Object?> get props => [isVisible];
}


class UpdateCheckoutFromCart extends CheckoutEvent {
  final List<CheckoutItem> items;
  final CheckoutSummary summary;
  const UpdateCheckoutFromCart({
    required this.items,
    required this.summary,
  });

  @override
  List<Object?> get props => [items, summary];
}

class UpdateShippingAddresses extends CheckoutEvent {
  final List<ShippingAddress> addresses;
  const UpdateShippingAddresses({required this.addresses});

  @override
  List<Object?> get props => [addresses];
}
