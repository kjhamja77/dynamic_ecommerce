import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/place_order.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../../cart/domain/usecases/clear_cart.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final PlaceOrder placeOrder;
  final ClearCart clearCart;
  final CheckoutRepository checkoutRepository;

  OrderBloc({
    required this.placeOrder,
    required this.clearCart,
    required this.checkoutRepository,
  }) : super(const OrderInitial()) {
    on<PlaceOrderRequested>(_onPlaceOrderRequested);
    on<CreateAlQasehPaymentRequested>(_onCreateAlQasehPaymentRequested);
    on<AlQasehPaymentCompleted>(_onAlQasehPaymentCompleted);
  }

  Future<void> _onPlaceOrderRequested(
    PlaceOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderSubmitting());

    final result = await placeOrder(
      PlaceOrderParams(
        orderId: event.orderId,
        addressId: event.addressId,
      ),
    );

    await result.fold(
      (failure) async => emit(OrderFailure(failure.message)),
      (orderReference) async {
        // Clear cart after successful order placement
        final clearResult = await clearCart(NoParams());
        clearResult.fold(
          (failure) => emit(OrderFailure(failure.message)),
          (_) => emit(OrderSuccess(
            orderReference: orderReference,
            orderId: event.orderId,
          )),
        );
      },
    );
  }

  Future<void> _onCreateAlQasehPaymentRequested(
    CreateAlQasehPaymentRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const AlQasehPaymentCreating());
    
    debugPrint('🔄 Creating Al Qaseh payment for order ID: ${event.orderId}');

    final result = await checkoutRepository.createAlQasehPayment(orderId: event.orderId);

    result.fold(
      (failure) {
        debugPrint('❌ Failed to create Al Qaseh payment: ${failure.code} ${failure.message}');
        emit(AlQasehPaymentFailure(failure.message));
      },
      (paymentData) {
        final paymentUrl = paymentData['payment_url']?.toString() ?? '';
        final paymentId = paymentData['payment_id']?.toString() ?? '';
        final token = paymentData['token']?.toString() ?? '';
        
        debugPrint('✅ Al Qaseh payment created successfully');
        debugPrint('   Payment URL: $paymentUrl');
        debugPrint('   Payment ID: $paymentId');
        debugPrint('   Token: $token');
        
        // Validate payment URL before proceeding
        if (paymentUrl.isEmpty) {
          debugPrint('❌ Payment URL is empty - cannot proceed');
          emit(AlQasehPaymentFailure('Payment URL is missing. Please try again.'));
          return;
        }
        
        // Validate URL format
        final uri = Uri.tryParse(paymentUrl);
        if (uri == null || !uri.hasScheme) {
          debugPrint('❌ Invalid payment URL format: $paymentUrl');
          emit(AlQasehPaymentFailure('Invalid payment URL format. Please try again.'));
          return;
        }
        
        emit(AlQasehPaymentCreated(
          paymentUrl: paymentUrl,
          paymentId: paymentId,
          token: token,
          orderId: event.orderId,
          addressId: event.addressId,
        ));
      },
    );
  }

  Future<void> _onAlQasehPaymentCompleted(
    AlQasehPaymentCompleted event,
    Emitter<OrderState> emit,
  ) async {
    if (event.success) {
      // Payment successful - now place the order
      debugPrint('✅ Al Qaseh payment successful - Placing order...');
      debugPrint('   Order ID: ${event.orderId}');
      debugPrint('   Address ID: ${event.addressId}');
      
      emit(const OrderSubmitting());
      
      final result = await placeOrder(
        PlaceOrderParams(
          orderId: event.orderId,
          addressId: event.addressId,
        ),
      );

      await result.fold(
        (failure) async => emit(OrderFailure(failure.message)),
        (orderReference) async {
          // Clear cart after successful order placement
          final clearResult = await clearCart(NoParams());
          clearResult.fold(
            (failure) => emit(OrderFailure(failure.message)),
            (_) => emit(AlQasehPaymentSuccess(orderReference)),
          );
        },
      );
    } else {
      // Payment failed or cancelled - don't place order, don't clear cart
      debugPrint('❌ Al Qaseh payment failed or cancelled');
      emit(const AlQasehPaymentDeclined('Payment was cancelled or failed'));
    }
  }
}


