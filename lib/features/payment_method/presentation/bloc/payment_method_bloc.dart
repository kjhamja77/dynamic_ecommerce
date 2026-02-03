import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_payment_methods.dart';
import '../../domain/usecases/add_payment_method.dart';
import '../../domain/usecases/delete_payment_method.dart';
import '../../domain/usecases/set_default_payment_method.dart';
import '../../domain/entities/payment_method.dart';
import '../../../../core/usecases/usecase.dart';
import 'payment_method_event.dart';
import 'payment_method_state.dart';

class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;
  final AddPaymentMethodUseCase addPaymentMethodUseCase;
  final DeletePaymentMethodUseCase deletePaymentMethodUseCase;
  final SetDefaultPaymentMethodUseCase setDefaultPaymentMethodUseCase;

  PaymentMethodBloc({
    required this.getPaymentMethodsUseCase,
    required this.addPaymentMethodUseCase,
    required this.deletePaymentMethodUseCase,
    required this.setDefaultPaymentMethodUseCase,
  }) : super(PaymentMethodInitial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<AddPaymentMethod>(_onAddPaymentMethod);
    on<DeletePaymentMethod>(_onDeletePaymentMethod);
    on<SetDefaultPaymentMethod>(_onSetDefaultPaymentMethod);
    on<UpdateCardPreview>(_onUpdateCardPreview);
  }

  Future<void> _onLoadPaymentMethods(
    LoadPaymentMethods event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentMethodLoading());

    final result = await getPaymentMethodsUseCase(NoParams());

    result.fold(
      (failure) => emit(PaymentMethodError(failure.message)),
      (paymentMethods) => emit(PaymentMethodsLoaded(paymentMethods)),
    );
  }

  Future<void> _onAddPaymentMethod(
    AddPaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    // Get current state to preserve payment methods
    final currentState = state;
    List<PaymentMethod> currentMethods = [];
    
    if (currentState is PaymentMethodsLoaded) {
      currentMethods = List.from(currentState.paymentMethods);
    }

    final result = await addPaymentMethodUseCase.call(event.paymentMethod);

    result.fold(
      (failure) => emit(PaymentMethodError(failure.message)),
      (paymentMethod) async {
        // Add the new payment method to the list
        currentMethods.add(paymentMethod);
        emit(PaymentMethodSuccess('Payment method added successfully', paymentMethods: currentMethods));
      },
    );
  }

  Future<void> _onDeletePaymentMethod(
    DeletePaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    // Get current state to preserve payment methods
    final currentState = state;
    if (currentState is! PaymentMethodsLoaded) {
      emit(PaymentMethodError('No payment methods to delete'));
      return;
    }

    List<PaymentMethod> currentMethods = List.from(currentState.paymentMethods);
    
    // Optimistically remove the payment method
    currentMethods.removeWhere((method) => method.id == event.id);
    
    // Show updating state with the modified list
    emit(PaymentMethodUpdating(currentMethods));

    final result = await deletePaymentMethodUseCase(event.id);

    result.fold(
      (failure) {
        // Revert to original state on failure
        emit(PaymentMethodError(failure.message));
        // Reload to get the correct state
        add(LoadPaymentMethods());
      },
      (success) async {
        emit(PaymentMethodSuccess('Payment method deleted successfully', paymentMethods: currentMethods));
      },
    );
  }

  Future<void> _onSetDefaultPaymentMethod(
    SetDefaultPaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    // Try to get a working copy of the current list from any compatible state
    List<PaymentMethod>? currentMethods;
    final currentState = state;
    if (currentState is PaymentMethodsLoaded) {
      currentMethods = List.from(currentState.paymentMethods);
    } else if (currentState is PaymentMethodUpdating) {
      currentMethods = List.from(currentState.paymentMethods);
    } else if (currentState is PaymentMethodSuccess && currentState.paymentMethods != null) {
      currentMethods = List.from(currentState.paymentMethods!);
    }

    if (currentMethods != null) {
      // Optimistically update the default payment method
      for (int i = 0; i < currentMethods.length; i++) {
        if (currentMethods[i].id == event.id) {
          currentMethods[i] = currentMethods[i].copyWith(isDefault: true);
        } else {
          currentMethods[i] = currentMethods[i].copyWith(isDefault: false);
        }
      }

      // Show updating state with the modified list
      emit(PaymentMethodUpdating(currentMethods));

      final result = await setDefaultPaymentMethodUseCase(event.id);

      result.fold(
        (failure) {
          // Revert by reloading to get the correct state without flashing an error screen
          add(LoadPaymentMethods());
          emit(PaymentMethodError(failure.message));
        },
        (success) async {
          emit(PaymentMethodSuccess('Default payment method updated', paymentMethods: currentMethods));
        },
      );
    } else {
      // No list yet (e.g., quick tap before load). Perform the action silently and then load.
      final result = await setDefaultPaymentMethodUseCase(event.id);
      result.fold(
        (failure) => emit(PaymentMethodError(failure.message)),
        (success) async {
          emit(const PaymentMethodSuccess('Default payment method updated'));
          add(LoadPaymentMethods());
        },
      );
    }
  }

  Future<void> _onUpdateCardPreview(
    UpdateCardPreview event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentCardPreviewState(
      cardNumber: event.cardNumber,
      expiryDate: event.expiryDate,
      cardHolderName: event.cardHolderName,
      cvv: event.cvv,
      type: event.type,
    ));
  }
}
