part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartItem> cartItems;
  final CartResponseModel? cartResponse; // API response with exact tax calculations

  const CartLoaded(this.cartItems, {this.cartResponse});

  @override
  List<Object?> get props => [cartItems, cartResponse];

  double get totalPrice => cartResponse?.amountTotal ?? cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  int get totalItems => cartResponse?.lines.fold<int>(0, (sum, line) => sum + line.quantity.toInt()) ?? 
                       cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  // Number of distinct products (ignores quantity)
  int get uniqueItemsCount => cartResponse?.lines.length ?? cartItems.length;
  
  bool get isEmpty => cartItems.isEmpty;

  // API-based tax calculations
  double get subtotal => cartResponse?.amountUntaxed ?? 0.0;
  double get taxAmount => cartResponse?.amountTax ?? 0.0;
  double get total => cartResponse?.amountTotal ?? 0.0;
  String get currency => cartResponse?.currency ?? 'IQD';
  List<TaxSummaryModel> get taxSummary => cartResponse?.taxSummary ?? [];
}

class CartUpdating extends CartState {
  final List<CartItem> cartItems;
  final CartResponseModel? cartResponse;
  final String updatingProductId;

  const CartUpdating({
    required this.cartItems,
    required this.cartResponse,
    required this.updatingProductId,
  });

  @override
  List<Object?> get props => [cartItems, cartResponse, updatingProductId];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State for stock-related errors that should be shown as snackbar while keeping cart visible
class CartStockError extends CartState {
  final String message;
  final List<CartItem> cartItems;
  final CartResponseModel? cartResponse;

  const CartStockError(this.message, this.cartItems, this.cartResponse);

  @override
  List<Object?> get props => [message, cartItems, cartResponse];
  
  double get totalPrice => cartResponse?.amountTotal ?? cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get totalItems => cartResponse?.lines.fold<int>(0, (sum, line) => sum + line.quantity.toInt()) ?? 
                       cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemsCount => cartResponse?.lines.length ?? cartItems.length;
  bool get isEmpty => cartItems.isEmpty;
  double get subtotal => cartResponse?.amountUntaxed ?? 0.0;
  double get taxAmount => cartResponse?.amountTax ?? 0.0;
  double get total => cartResponse?.amountTotal ?? 0.0;
  String get currency => cartResponse?.currency ?? 'IQD';
  List<TaxSummaryModel> get taxSummary => cartResponse?.taxSummary ?? [];
}
