import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/checkout_item.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/entities/coupon.dart';
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
    on<LoadPromoPricelists>(_onLoadPromoPricelists);
    on<ApplyPromo>(_onApplyPromo);
    on<LoadCoupons>(_onLoadCoupons);
    on<ApplyCoupon>(_onApplyCoupon);
    on<RemoveCoupon>(_onRemoveCoupon);
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

        // Optionally load promo pricelists if we already have an order id from the cart
        List<Map<String, dynamic>> promoPricelists = const [];
        if (event.cartState is CartLoaded) {
          final cartLoaded = event.cartState as CartLoaded;
          final orderId = cartLoaded.cartResponse?.orderId;
          if (orderId != null) {
            final promoResult = await checkoutRepository.getPromoPricelists(orderId: orderId);
            promoResult.fold(
              (_) {},
              (list) {
                promoPricelists = list;
              },
            );
          }
        }

        // Set default selections
        // Load coupons up-front so the first CheckoutLoaded already contains them.
        List<Coupon> coupons = const <Coupon>[];
        String? couponsError;
        final couponsResult = await checkoutRepository.getCoupons();
        couponsResult.fold(
          (failure) {
            couponsError = failure.message;
            coupons = const <Coupon>[];
          },
          (list) {
            coupons = list;
          },
        );

        // If a previous CheckoutLoaded existed, preserve applied coupon id so totals stay consistent.
        final CheckoutLoaded? previousLoaded =
            state is CheckoutLoaded ? state as CheckoutLoaded : null;
        final int? appliedCouponId = previousLoaded?.appliedCouponId;
        // Only auto-select an address if the backend explicitly marks it as default.
        // If no address is flagged as default, leave selection empty so that
        // shipping stays at 0 until the user chooses an address.
        final defaultAddress = addresses.where((address) => address.isDefault).isNotEmpty
            ? addresses.firstWhere((address) => address.isDefault)
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
          promoPricelists: promoPricelists,
          useCartTotals: true,
          coupons: coupons,
          isLoadingCoupons: false,
          couponsError: couponsError,
          appliedCouponId: appliedCouponId,
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
    // Capture initial state, but we'll also re-check after the async call
    CheckoutLoaded? previousState = state is CheckoutLoaded ? state as CheckoutLoaded : null;
    emit(ShippingMethodsLoading());
    final result = await checkoutRepository.getShippingMethods(
      orderId: event.orderId,
      addressId: event.addressId,
    );
    result.fold(
      (failure) => emit(CheckoutError(message: failure.message)),
      (methods) {
        // If checkout state was updated (e.g. coupons loaded) while the request
        // was in flight, prefer the latest CheckoutLoaded so we don't lose data.
        final CheckoutLoaded? effectiveState =
            state is CheckoutLoaded ? state as CheckoutLoaded : previousState;

        emit(ShippingMethodsLoaded(methods, previousState: effectiveState));

        // Decide when to auto-apply a method:
        // - Initial load: no method selected yet.
        // - Address change: caller set autoApplyFirstMethod to true.
        final base = effectiveState;
        final shouldAutoApply = base != null &&
            methods.isNotEmpty &&
            (base.selectedShippingMethodId == null || event.autoApplyFirstMethod);

        if (shouldAutoApply) {
          final dynamic firstMethod = methods.first;
          final int? methodId = (firstMethod as dynamic).id as int?;
          final double? amount =
              (firstMethod as dynamic).price is num ? ((firstMethod as dynamic).price as num).toDouble() : null;
          if (methodId != null && methodId > 0) {
            add(ApplyShippingMethod(orderId: event.orderId, shippingMethodId: methodId, amount: amount));
          }
        }
      },
    );
  }

  Future<void> _onApplyShippingMethod(
    ApplyShippingMethod event,
    Emitter<CheckoutState> emit,
  ) async {
    CheckoutLoaded? snapshot;
    if (state is CheckoutLoaded) {
      snapshot = state as CheckoutLoaded;
    } else if (state is ShippingMethodsLoaded) {
      snapshot = (state as ShippingMethodsLoaded).previousState;
    }

    if (snapshot == null) return;

    // Emit applying state with a snapshot (may not yet include coupons)
    emit(ShippingMethodApplying(snapshot));
    final result = await checkoutRepository.applyShippingMethod(
      orderId: event.orderId,
      shippingMethodId: event.shippingMethodId,
      amount: event.amount,
    );
    result.fold(
      (failure) {
        emit(CheckoutError(message: failure.message));
        emit(snapshot!); // Restore previous state on error
      },
      (summary) {
        // Backend returns authoritative totals (subtotal, tax, total, discount).
        // Derive the shipping amount from these so that:
        //   subtotal + shipping + tax - discount == total
        // and keep totalItems from the previous state (API doesn't return it).
        final derivedShipping = summary.total -
            summary.subtotal -
            summary.tax +
            summary.discount;

        // Prefer the latest loaded state (which may already include coupons)
        final CheckoutLoaded baseState =
            state is CheckoutLoaded ? state as CheckoutLoaded : snapshot!;

        // Preserve any coupons that might have been loaded after the snapshot
        final List<Coupon> mergedCoupons =
            (state is CheckoutLoaded && (state as CheckoutLoaded).coupons.isNotEmpty)
                ? (state as CheckoutLoaded).coupons
                : snapshot!.coupons;

        final updatedSummary = summary.copyWith(
          totalItems: baseState.summary.totalItems,
          shipping: derivedShipping,
        );
        // Directly transition to CheckoutLoaded with updated summary
        emit(baseState.copyWith(
          summary: updatedSummary,
          selectedShippingMethodId: event.shippingMethodId,
          useCartTotals: false,
          coupons: mergedCoupons,
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

  Future<void> _onLoadPromoPricelists(
    LoadPromoPricelists event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;
    final current = state as CheckoutLoaded;
    emit(current.copyWith(
      isLoadingPromo: true,
      promoError: null,
    ));

    final result = await checkoutRepository.getPromoPricelists(orderId: event.orderId);
    result.fold(
      (failure) => emit(current.copyWith(
        isLoadingPromo: false,
        promoError: failure.message,
      )),
      (list) => emit(current.copyWith(
        isLoadingPromo: false,
        promoPricelists: list,
        promoError: null,
      )),
    );
  }

  Future<void> _onApplyPromo(
    ApplyPromo event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;
    final current = state as CheckoutLoaded;

    emit(current.copyWith(
      isApplyingPromo: true,
      promoError: null,
    ));

    final result = await checkoutRepository.applyPromo(
      orderId: event.orderId,
      pricelistId: event.pricelistId,
      promoCode: event.promoCode,
    );

    result.fold(
      (failure) => emit(current.copyWith(
        isApplyingPromo: false,
        promoError: failure.message,
      )),
      (summary) {
        final updatedSummary = summary.copyWith(
          totalItems: current.summary.totalItems,
        );
        emit(current.copyWith(
          isApplyingPromo: false,
          summary: updatedSummary,
          useCartTotals: false,
          promoError: null,
          appliedPromoCode: event.promoCode,
        ));
      },
    );
  }

  Future<void> _onLoadCoupons(
    LoadCoupons event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;
    final current = state as CheckoutLoaded;
    emit(current.copyWith(
      isLoadingCoupons: true,
      couponsError: null,
    ));

    final result = await checkoutRepository.getCoupons();
    result.fold(
      (failure) => emit(current.copyWith(
        isLoadingCoupons: false,
        couponsError: failure.message,
      )),
      (list) => emit(current.copyWith(
        isLoadingCoupons: false,
        coupons: list,
        couponsError: null,
      )),
    );
  }

  Future<void> _onApplyCoupon(
    ApplyCoupon event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;
    final current = state as CheckoutLoaded;

    final String targetCode = event.couponCode.trim().toLowerCase();
    if (targetCode.isEmpty) {
      return;
    }

    // Find matching coupon by code from the loaded coupons list
    final matched = current.coupons.where(
      (c) => c.code.trim().toLowerCase() == targetCode,
    );

    if (matched.isEmpty) {
      debugPrint('❌ No coupon found for code: ${event.couponCode}');
      emit(
        current.copyWith(
          promoError: 'Apply coupon failed',
        ),
      );
      return;
    }

    final coupon = matched.first;

    final result = await checkoutRepository.applyCoupon(
      orderId: event.orderId,
      couponId: coupon.cardId,
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to apply coupon: ${failure.message}');
        emit(
          current.copyWith(
            promoError: 'APPLY_COUPON_FAILED',
          ),
        );
      },
      (summary) {
        final base = current.summary;
        final double couponDiscount = summary.discount;
        final double recalculatedTotal =
            base.subtotal + base.shipping + base.tax - couponDiscount;

        final updatedSummary = base.copyWith(
          discount: couponDiscount,
          total: recalculatedTotal,
          totalItems: current.summary.totalItems,
        );
        emit(
          current.copyWith(
            summary: updatedSummary,
            useCartTotals: false,
            appliedCouponId: coupon.cardId,
            // Drive UI success snackbar for apply-coupon
            promoError: 'APPLY_COUPON_SUCCESS',
          ),
        );
      },
    );
  }

  Future<void> _onRemoveCoupon(
    RemoveCoupon event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;
    final current = state as CheckoutLoaded;
    final couponId = current.appliedCouponId;
    if (couponId == null) return;

    final result = await checkoutRepository.removeCoupon(
      orderId: event.orderId,
      couponId: couponId,
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to remove coupon: ${failure.message}');
        emit(
          current.copyWith(
            // Drive UI failure snackbar for remove-coupon
            promoError: 'REMOVE_COUPON_FAILED',
          ),
        );
      },
      (summary) {
        final base = current.summary;
        final double couponDiscount = summary.discount;
        final double recalculatedTotal =
            base.subtotal + base.shipping + base.tax - couponDiscount;

        final updatedSummary = base.copyWith(
          discount: couponDiscount,
          total: recalculatedTotal,
          totalItems: current.summary.totalItems,
        );
        emit(
          current.copyWith(
            summary: updatedSummary,
            useCartTotals: false,
            appliedCouponId: null,
            // Drive UI success snackbar for remove-coupon
            promoError: 'REMOVE_COUPON_SUCCESS',
          ),
        );
      },
    );
  }

}
