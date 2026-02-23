import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/checkout_item.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CheckoutRepository checkoutRepository;

  CheckoutBloc({
    required this.checkoutRepository,
  }) : super(CheckoutInitial()) {
    on<LoadCheckout>(_onLoadCheckout);
    on<InitializeCheckoutFromCart>(_onInitializeCheckoutFromCart);
    on<UpdateCheckoutItem>(_onUpdateCheckoutItem);
    on<RemoveCheckoutItem>(_onRemoveCheckoutItem);
    on<SelectShippingAddress>(_onSelectShippingAddress);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<LoadShippingMethods>(_onLoadShippingMethods);
    on<ApplyShippingMethod>(_onApplyShippingMethod);
    on<ApplyPaymentMethod>(_onApplyPaymentMethod);
    on<SelectShippingMethod>(_onSelectShippingMethod);
    on<SetWaitingForNewAddress>(_onSetWaitingForNewAddress);
    on<SetUseCartTotals>(_onSetUseCartTotals);
    on<SetProcessingDialogVisible>(_onSetProcessingDialogVisible);
    on<UpdateCheckoutFromCart>(_onUpdateCheckoutFromCart);
    on<UpdateShippingAddresses>(_onUpdateShippingAddresses);
  }

  Future<void> _onLoadCheckout(
    LoadCheckout event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());

    try {
      // Load addresses and payment methods
      final addressesResult = await checkoutRepository.getShippingAddresses();
      final methodsResult = await checkoutRepository.getPaymentMethods();

      if (addressesResult.isRight() && methodsResult.isRight()) {
        final addresses = addressesResult.getOrElse(() => []);
        final methods = methodsResult.getOrElse(() => []);

        // Set default selections
        final defaultAddress = addresses.isNotEmpty 
            ? addresses.firstWhere(
                (address) => address.isDefault,
                orElse: () => addresses.first,
              )
            : null;
        final defaultMethod = methods.isNotEmpty 
            ? methods.firstWhere(
                (method) => method.isDefault,
                orElse: () => methods.first,
              )
            : null;

        // Initialize checkout items from cart items
        final checkoutItems = event.cartItems.map((cartItem) {
          return CheckoutItem(
            id: cartItem.id,
            cartItem: cartItem,
            isSelected: true,
          );
        }).toList();

        // Calculate summary from cart state or cart items
        CheckoutSummary checkoutSummary;
        if (event.cartState is CartLoaded) {
          final cartLoaded = event.cartState as CartLoaded;
          checkoutSummary = CheckoutSummary(
            subtotal: cartLoaded.subtotal,
            shipping: 0.0, // Will be set when shipping method is selected
            tax: cartLoaded.taxAmount,
            discount: 0.0, // No discount initially
            total: cartLoaded.total,
            totalItems: cartLoaded.uniqueItemsCount, // Number of line items, not sum of quantities
          );
        } else {
          // Fallback calculation using cart items
          final subtotal = checkoutItems.fold<double>(
            0.0,
            (sum, item) => sum + (item.cartItem.totalPrice * (item.isSelected ? 1 : 0)),
          );
          final shipping = 0.0;
          final tax = subtotal * 0.08; // Estimate 8% tax
          final discount = 0.0;
          final total = subtotal + shipping + tax - discount;
          // Number of distinct line items (products), not sum of quantities
          final totalItems = checkoutItems.where((item) => item.isSelected).length;

          checkoutSummary = CheckoutSummary(
            subtotal: subtotal,
            shipping: shipping,
            tax: tax,
            discount: discount,
            total: total,
            totalItems: totalItems,
          );
        }

        emit(CheckoutLoaded(
          items: checkoutItems,
          summary: checkoutSummary,
          shippingAddresses: addresses,
          paymentMethods: methods,
          selectedShippingAddressId: defaultAddress?.id,
          selectedPaymentMethodId: defaultMethod?.id,
          useCartTotals: true,
        ));
      } else {
        emit(const CheckoutError(message: 'Failed to load checkout data'));
      }
    } catch (e) {
      emit(CheckoutError(message: 'Error loading checkout: $e'));
    }
  }

  Future<void> _onInitializeCheckoutFromCart(
    InitializeCheckoutFromCart event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is CheckoutLoaded) {
      final currentState = state as CheckoutLoaded;
      emit(currentState.copyWith(
        items: event.items,
        summary: event.summary,
        useCartTotals: true,
      ));
    } else {
      // If checkout is not loaded yet, wait for LoadCheckout to complete first
      // This should not happen in normal flow, but handle it gracefully
      emit(CheckoutLoading());
      // The page should call InitializeCheckoutFromCart after LoadCheckout completes
    }
  }

  Future<void> _onLoadShippingMethods(
    LoadShippingMethods event,
    Emitter<CheckoutState> emit,
  ) async {
    final previousState = state is CheckoutLoaded ? state as CheckoutLoaded : null;
    emit(ShippingMethodsLoading());
    final result = await checkoutRepository.getShippingMethods(orderId: event.orderId);
    result.fold(
      (failure) => emit(CheckoutError(message: failure.message)),
      (methods) => emit(ShippingMethodsLoaded(methods, previousState: previousState)),
    );
  }

  Future<void> _onApplyShippingMethod(
    ApplyShippingMethod event,
    Emitter<CheckoutState> emit,
  ) async {
    CheckoutLoaded? currentState;
    if (state is CheckoutLoaded) {
      currentState = state as CheckoutLoaded;
    } else if (state is ShippingMethodsLoaded) {
      currentState = (state as ShippingMethodsLoaded).previousState;
    }
    
    if (currentState == null) return;
    
    final stateToUse = currentState; // Capture for use in callbacks
    emit(ShippingMethodApplying(stateToUse));
    final result = await checkoutRepository.applyShippingMethod(orderId: event.orderId, shippingMethodId: event.shippingMethodId);
    result.fold(
      (failure) {
        emit(CheckoutError(message: failure.message));
        emit(stateToUse); // Restore previous state on error
      },
      (summary) {
        // Preserve totalItems from current state since API doesn't return it
        final updatedSummary = summary.copyWith(
          totalItems: stateToUse.summary.totalItems,
        );
        // Directly transition to CheckoutLoaded with updated summary
        emit(stateToUse.copyWith(
          summary: updatedSummary,
          selectedShippingMethodId: event.shippingMethodId,
          useCartTotals: false,
        ));
      },
    );
  }

  Future<void> _onApplyPaymentMethod(
    ApplyPaymentMethod event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;

    final current = state as CheckoutLoaded;
    emit(PaymentMethodApplying(current));

    final result = await checkoutRepository.applyPaymentMethod(
      orderId: event.orderId,
      paymentMethodId: event.paymentMethodId,
    );

    result.fold(
      (failure) {
        emit(PaymentMethodFailure(current, failure.message));
        emit(current);
      },
      (message) {
        final selectedId = event.paymentMethodId.toString();
        final updatedMethods = current.paymentMethods
            .map(
              (method) => method.copyWith(isDefault: method.id == selectedId),
            )
            .toList();
        final updatedState = current.copyWith(
          paymentMethods: updatedMethods,
          selectedPaymentMethodId: selectedId,
        );
        emit(PaymentMethodApplied(updatedState, message));
        emit(updatedState);
      },
    );
  }

  Future<void> _onUpdateCheckoutItem(
    UpdateCheckoutItem event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;
    
    try {
      await checkoutRepository.updateCheckoutItem(event.itemId, event.isSelected);
      // Update the item in the current state
      final updatedItems = currentState.items.map((item) {
        if (item.id == event.itemId) {
          return CheckoutItem(
            id: item.id,
            cartItem: item.cartItem,
            isSelected: event.isSelected,
          );
        }
        return item;
      }).toList();
      
      // Recalculate summary
      final subtotal = updatedItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.cartItem.totalPrice * (item.isSelected ? 1 : 0)),
      );
      final totalItems = updatedItems.where((item) => item.isSelected).length;

      emit(currentState.copyWith(
        items: updatedItems,
        summary: currentState.summary.copyWith(
          subtotal: subtotal,
          totalItems: totalItems,
          total: subtotal + currentState.summary.shipping + currentState.summary.tax - currentState.summary.discount,
        ),
      ));
    } catch (e) {
      emit(CheckoutError(message: 'Failed to update item: $e'));
    }
  }

  Future<void> _onRemoveCheckoutItem(
    RemoveCheckoutItem event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;
    
    try {
      await checkoutRepository.removeCheckoutItem(event.itemId);
      // Remove the item from current state
      final updatedItems = currentState.items.where((item) => item.id != event.itemId).toList();
      
      // Recalculate summary
      final subtotal = updatedItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.cartItem.totalPrice * (item.isSelected ? 1 : 0)),
      );
      final totalItems = updatedItems.where((item) => item.isSelected).length;

      emit(currentState.copyWith(
        items: updatedItems,
        summary: currentState.summary.copyWith(
          subtotal: subtotal,
          totalItems: totalItems,
          total: subtotal + currentState.summary.shipping + currentState.summary.tax - currentState.summary.discount,
        ),
      ));
    } catch (e) {
      emit(CheckoutError(message: 'Failed to remove item: $e'));
    }
  }

  Future<void> _onSelectShippingAddress(
    SelectShippingAddress event,
    Emitter<CheckoutState> emit,
  ) async {
    // Allow address selection in any state that has checkout data (no dependency on shipping method being selected)
    CheckoutLoaded? base;
    if (state is CheckoutLoaded) {
      base = state as CheckoutLoaded;
    } else if (state is ShippingMethodsLoaded) {
      base = (state as ShippingMethodsLoaded).previousState;
    } else if (state is ShippingMethodApplying) {
      base = (state as ShippingMethodApplying).snapshot;
    } else if (state is PaymentMethodApplying) {
      base = (state as PaymentMethodApplying).snapshot;
    } else if (state is PaymentMethodApplied) {
      base = (state as PaymentMethodApplied).snapshot;
    } else if (state is PaymentMethodFailure) {
      base = (state as PaymentMethodFailure).snapshot;
    }
    if (base != null) {
      emit(base.copyWith(selectedShippingAddressId: event.addressId));
    }
  }

  Future<void> _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<CheckoutState> emit,
  ) async {
    // Allow payment method selection in any state that has checkout data (no dependency on address/shipping)
    CheckoutLoaded? base;
    if (state is CheckoutLoaded) {
      base = state as CheckoutLoaded;
    } else if (state is ShippingMethodsLoaded) {
      base = (state as ShippingMethodsLoaded).previousState;
    } else if (state is ShippingMethodApplying) {
      base = (state as ShippingMethodApplying).snapshot;
    } else if (state is PaymentMethodApplying) {
      base = (state as PaymentMethodApplying).snapshot;
    } else if (state is PaymentMethodApplied) {
      base = (state as PaymentMethodApplied).snapshot;
    } else if (state is PaymentMethodFailure) {
      base = (state as PaymentMethodFailure).snapshot;
    }
    if (base != null) {
      emit(base.copyWith(selectedPaymentMethodId: event.methodId));
    }
  }

  Future<void> _onSelectShippingMethod(
    SelectShippingMethod event,
    Emitter<CheckoutState> emit,
  ) async {
    CheckoutLoaded? currentState;
    if (state is CheckoutLoaded) {
      currentState = state as CheckoutLoaded;
    } else if (state is ShippingMethodsLoaded) {
      currentState = (state as ShippingMethodsLoaded).previousState;
    }
    // Note: ShippingMethodApplying doesn't have snapshot, so we can't update during that state
    
    if (currentState != null) {
      emit(currentState.copyWith(
        selectedShippingMethodId: event.shippingMethodId,
      ));
    }
  }

  Future<void> _onSetWaitingForNewAddress(
    SetWaitingForNewAddress event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is CheckoutLoaded) {
      final currentState = state as CheckoutLoaded;
      emit(currentState.copyWith(
        isWaitingForNewAddress: event.isWaiting,
      ));
    }
  }

  Future<void> _onSetUseCartTotals(
    SetUseCartTotals event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is CheckoutLoaded) {
      final currentState = state as CheckoutLoaded;
      emit(currentState.copyWith(
        useCartTotals: event.useCartTotals,
      ));
    }
  }

  Future<void> _onSetProcessingDialogVisible(
    SetProcessingDialogVisible event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is CheckoutLoaded) {
      final currentState = state as CheckoutLoaded;
      emit(currentState.copyWith(
        isProcessingDialogVisible: event.isVisible,
      ));
    }
  }

  Future<void> _onUpdateCheckoutFromCart(
    UpdateCheckoutFromCart event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is CheckoutLoaded) {
      final currentState = state as CheckoutLoaded;
      emit(currentState.copyWith(
        items: event.items,
        summary: event.summary,
      ));
    }
  }

  Future<void> _onUpdateShippingAddresses(
    UpdateShippingAddresses event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is CheckoutLoaded) {
      final currentState = state as CheckoutLoaded;
      emit(currentState.copyWith(
        shippingAddresses: event.addresses,
      ));
    }
  }

}
