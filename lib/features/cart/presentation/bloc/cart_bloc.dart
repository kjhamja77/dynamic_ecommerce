import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/get_cart.dart';
import '../../domain/usecases/remove_from_cart.dart';
import '../../domain/usecases/remove_from_cart_by_quantity.dart';
import '../../domain/usecases/update_cart_item_quantity.dart';
import '../../domain/usecases/clear_cart.dart';
import '../../data/models/cart_response_model.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final AddToCart _addToCart;
  final GetCart _getCart;
  final RemoveFromCart _removeFromCart;
  final RemoveFromCartByQuantity _removeFromCartByQuantity;
  final UpdateCartItemQuantity _updateCartItemQuantity;
  final ClearCart _clearCart;
  
  // Track max quantities per product ID to disable increment when at stock limit
  final Map<String, int> _maxQuantities = {};

  CartBloc({
    required AddToCart addToCart,
    required GetCart getCart,
    required RemoveFromCart removeFromCart,
    required RemoveFromCartByQuantity removeFromCartByQuantity,
    required UpdateCartItemQuantity updateCartItemQuantity,
    required ClearCart clearCart,
  })  : _addToCart = addToCart,
        _getCart = getCart,
        _removeFromCart = removeFromCart,
        _removeFromCartByQuantity = removeFromCartByQuantity,
        _updateCartItemQuantity = updateCartItemQuantity,
        _clearCart = clearCart,
        super(const CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<RefreshCart>(_onRefreshCart);
    on<AddItemToCart>(_onAddItemToCart);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<RemoveItemFromCartByQuantity>(_onRemoveItemFromCartByQuantity);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<ClearCartEvent>(_onClearCart);
  }
  
  /// Get the max allowed quantity for a product (returns null if unknown)
  int? getMaxQuantity(String productId) => _maxQuantities[productId];
  
  /// Check if increment is allowed. When backend has set a max (e.g. stock limit), restrict.
  bool canIncrement(String productId, int currentQuantity) {
    final max = _maxQuantities[productId];
    if (max == null) return true;
    return currentQuantity < max;
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final result = await _getCart(NoParams());
      result.fold(
        (failure) => emit(CartError(failure.message)),
        (cartData) {
          debugPrint('CartBloc._onLoadCart: Loaded ${cartData.items.length} cart items');
          for (final item in cartData.items) {
            debugPrint('CartBloc._onLoadCart: Item - product_id: ${item.product.id}, quantity: ${item.quantity}, product_name: ${item.product.name}');
          }
          _applyMaxQuantitiesFromCartResponse(cartData.response);
          emit(CartLoaded(cartData.items, cartResponse: cartData.response));
        },
      );
    } catch (e) {
      debugPrint('CartBloc._onLoadCart error: $e');
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRefreshCart(RefreshCart event, Emitter<CartState> emit) async {
    // Force refresh without showing loading state (keep current UI)
    try {
      debugPrint('CartBloc._onRefreshCart: Force refreshing cart...');
      final result = await _getCart(NoParams());
      result.fold(
        (failure) {
          debugPrint('CartBloc._onRefreshCart: Failed to refresh cart: ${failure.message}');
          emit(CartError(failure.message));
        },
        (cartData) {
          debugPrint('CartBloc._onRefreshCart: Refreshed ${cartData.items.length} cart items');
          for (final item in cartData.items) {
            debugPrint('CartBloc._onRefreshCart: Item - product_id: ${item.product.id}, quantity: ${item.quantity}, product_name: ${item.product.name}');
          }
          _applyMaxQuantitiesFromCartResponse(cartData.response);
          emit(CartLoaded(cartData.items, cartResponse: cartData.response));
        },
      );
    } catch (e) {
      debugPrint('CartBloc._onRefreshCart error: $e');
      emit(CartError(e.toString()));
    }
  }

  /// Helper to check if error is stock-related
  bool _isStockError(String errorMessage) {
    final lower = errorMessage.toLowerCase();
    return lower.contains('stock') || 
           lower.contains('out of stock') ||
           lower.contains('available') ||
           lower.contains('quantity') ||
           lower.contains('exceed');
  }

  /// Helper to format stock error message for user display
  String _formatStockErrorMessage(String errorMessage) {
    final lower = errorMessage.toLowerCase();
    if (lower.contains('out of stock')) {
      return 'This item is out of stock and cannot be added to your cart.';
    } else if (lower.contains('available') && lower.contains('quantity')) {
      // Try to extract numbers from error message
      final regex = RegExp(r'(\d+)');
      final matches = regex.allMatches(errorMessage);
      if (matches.isNotEmpty) {
        final quantity = matches.first.group(0);
        return 'Only $quantity item(s) available in stock.';
      }
      return 'Limited stock available. Please adjust the quantity.';
    } else if (lower.contains('exceed')) {
      return 'Quantity exceeds available stock. Please reduce the quantity.';
    }
    // Return original message if we can't parse it
    return errorMessage;
  }

  /// Current cart items and response from CartLoaded or CartStockError (so decrement/update work from any state).
  (List<CartItem>, CartResponseModel?)? _currentCartItems(CartState s) {
    if (s is CartLoaded) return (s.cartItems, s.cartResponse);
    if (s is CartStockError) return (s.cartItems, s.cartResponse);
    return null;
  }

  /// Populate max quantities from cart API response (quantity_available per line).
  /// Used when loading/refreshing cart so product cards can disable increment at stock limit.
  void _applyMaxQuantitiesFromCartResponse(CartResponseModel? response) {
    if (response == null) return;
    for (final line in response.lines) {
      if (line.quantityAvailable != null) {
        _maxQuantities[line.productId.toString()] = line.quantityAvailable!;
        debugPrint('CartBloc: Set max quantity for product ${line.productId} to ${line.quantityAvailable} from cart response');
      }
    }
  }

  Future<void> _onAddItemToCart(AddItemToCart event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      // Find existing item or add new one optimistically
      final existingItemIndex = currentState.cartItems.indexWhere(
        (item) => item.product.id == event.cartItem.product.id,
      );
      
      List<CartItem> updatedCartItems;
      if (existingItemIndex != -1) {
        // Item exists - update quantity optimistically
        updatedCartItems = currentState.cartItems.map((item) {
          if (item.product.id == event.cartItem.product.id) {
            return item.copyWith(quantity: item.quantity + event.cartItem.quantity);
          }
          return item;
        }).toList();
      } else {
        // New item - add to cart optimistically
        updatedCartItems = List<CartItem>.from(currentState.cartItems);
        updatedCartItems.add(event.cartItem);
      }
      
      emit(CartUpdating(
        cartItems: updatedCartItems,
        cartResponse: currentState.cartResponse,
        updatingProductId: event.cartItem.product.id,
      ));
      
      try {
        final result = await _addToCart(AddToCartParams(cartItem: event.cartItem));
        await result.fold(
          (failure) async {
            if (!emit.isDone) {
              // For stock errors, emit a special state that can be handled in UI without replacing cart
              if (_isStockError(failure.message)) {
                // Track that current quantity is max for this product
                final existingItemIndex = currentState.cartItems.indexWhere(
                  (item) => item.product.id == event.cartItem.product.id,
                );
                final currentQuantity = existingItemIndex != -1
                    ? currentState.cartItems[existingItemIndex].quantity
                    : event.cartItem.quantity;
                _maxQuantities[event.cartItem.product.id] = currentQuantity;
                debugPrint('CartBloc: Set max quantity for product ${event.cartItem.product.id} to $currentQuantity');
                
                final formattedMessage = _formatStockErrorMessage(failure.message);
                // Emit CartStockError directly with current cart items (reverting optimistic update)
                emit(CartStockError(formattedMessage, currentState.cartItems, currentState.cartResponse));
              } else {
                // Revert optimistic update on failure for non-stock errors
                emit(CartLoaded(currentState.cartItems, cartResponse: currentState.cartResponse));
                emit(CartError(failure.message));
              }
            }
          },
          (addedCartItem) async {
            // Success - clear max quantity for this product (stock may have increased)
            _maxQuantities.remove(event.cartItem.product.id);
            debugPrint('CartBloc: Cleared max quantity for product ${event.cartItem.product.id} after successful add');
            
            // Success - reload cart from server to ensure consistency
            debugPrint('CartBloc._onAddItemToCart: Successfully added item, reloading cart...');
            if (!emit.isDone) {
              await _reloadCart(emit);
            }
          },
        );
      } catch (e) {
        if (!emit.isDone) {
          final errorStr = e.toString();
          
          // Check if it's a stock error
          if (_isStockError(errorStr)) {
            // Track that current quantity is max for this product
            final existingItemIndex = currentState.cartItems.indexWhere(
              (item) => item.product.id == event.cartItem.product.id,
            );
            final currentQuantity = existingItemIndex != -1
                ? currentState.cartItems[existingItemIndex].quantity
                : event.cartItem.quantity;
            _maxQuantities[event.cartItem.product.id] = currentQuantity;
            debugPrint('CartBloc: Set max quantity for product ${event.cartItem.product.id} to $currentQuantity');
            
            final formattedMessage = _formatStockErrorMessage(errorStr);
            // Emit CartStockError directly with current cart items (reverting optimistic update)
            emit(CartStockError(formattedMessage, currentState.cartItems, currentState.cartResponse));
          } else {
            // Revert optimistic update on error for non-stock errors
            emit(CartLoaded(currentState.cartItems, cartResponse: currentState.cartResponse));
            emit(CartError('Failed to add item to cart: $errorStr'));
          }
        }
      }
    } else if (currentState is CartInitial || currentState is CartError) {
      // For initial or error states, show loading
      emit(CartLoading());
      
      try {
        final result = await _addToCart(AddToCartParams(cartItem: event.cartItem));
        await result.fold(
          (failure) async {
            if (!emit.isDone) emit(CartError(failure.message));
          },
          (cartItem) async {
            await _reloadCart(emit);
          },
        );
      } catch (e) {
        if (!emit.isDone) emit(CartError('Failed to add item to cart'));
      }
    }
  }

  Future<void> _onRemoveItemFromCart(RemoveItemFromCart event, Emitter<CartState> emit) async {
    final currentState = state;
    final list = _currentCartItems(currentState);
    if (list == null) return;
    final cartItems = list.$1;
    final cartResponse = list.$2;

    // Optimistic update - remove item immediately from UI
    final updatedCartItems = List<CartItem>.from(cartItems);
    updatedCartItems.removeWhere((item) => item.product.id == event.cartItemId);
    emit(CartUpdating(
      cartItems: updatedCartItems,
      cartResponse: cartResponse,
      updatingProductId: event.cartItemId,
    ));

    try {
      final result = await _removeFromCart(RemoveFromCartParams(cartItemId: event.cartItemId));
      await result.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(CartLoaded(cartItems, cartResponse: cartResponse));
            emit(CartError(failure.message));
          }
        },
        (_) async {
          _maxQuantities.remove(event.cartItemId);
          if (!emit.isDone) await _reloadCart(emit);
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(CartLoaded(cartItems, cartResponse: cartResponse));
        emit(CartError('Failed to remove item from cart'));
      }
    }
  }

  Future<void> _onRemoveItemFromCartByQuantity(RemoveItemFromCartByQuantity event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      // Find the item to update
      final itemIndex = currentState.cartItems.indexWhere((item) => item.product.id == event.cartItemId);
      if (itemIndex == -1) {
        emit(CartError('Cart item not found'));
        return;
      }

      final currentItem = currentState.cartItems[itemIndex];
      final newQuantity = currentItem.quantity - event.quantity;
      
      if (newQuantity <= 0) {
        // Remove item completely if quantity becomes 0 or negative
        // Use removeFromCartByQuantity with the full quantity to ensure complete removal
        final updatedCartItems = List<CartItem>.from(currentState.cartItems);
        updatedCartItems.removeAt(itemIndex);
        emit(CartUpdating(
          cartItems: updatedCartItems,
          cartResponse: currentState.cartResponse,
          updatingProductId: event.cartItemId,
        ));
        
        try {
          // Use removeFromCartByQuantity with the full quantity to remove all items
          final result = await _removeFromCartByQuantity(
            RemoveFromCartByQuantityParams(
              cartItemId: event.cartItemId,
              quantity: event.quantity, // Use the quantity from the event (full quantity)
            ),
          );
          await result.fold(
            (failure) async {
              if (!emit.isDone) {
                // Revert optimistic update on failure
                emit(CartLoaded(currentState.cartItems, cartResponse: currentState.cartResponse));
                emit(CartError(failure.message));
              }
            },
            (_) async {
              // Success - reload to sync totals/prices from server
              if (!emit.isDone) {
                await _reloadCart(emit);
              }
            },
          );
        } catch (e) {
          if (!emit.isDone) {
            // Revert optimistic update on error
            emit(CartLoaded(currentState.cartItems, cartResponse: currentState.cartResponse));
            emit(CartError('Failed to remove item from cart'));
          }
        }
      } else {
        // Update quantity optimistically
        final updatedCartItems = currentState.cartItems.map((item) {
          if (item.product.id == event.cartItemId) {
            return item.copyWith(quantity: newQuantity);
          }
          return item;
        }).toList();
        emit(CartUpdating(
          cartItems: updatedCartItems,
          cartResponse: currentState.cartResponse,
          updatingProductId: event.cartItemId,
        ));
        
        try {
          final result = await _removeFromCartByQuantity(
            RemoveFromCartByQuantityParams(
              cartItemId: event.cartItemId,
              quantity: event.quantity,
            ),
          );
          await result.fold(
            (failure) async {
              if (!emit.isDone) {
                // Revert optimistic update on failure
                emit(CartLoaded(currentState.cartItems, cartResponse: currentState.cartResponse));
                emit(CartError(failure.message));
              }
            },
            (_) async {
              // Success - reload to sync totals/prices from server
              if (!emit.isDone) {
                await _reloadCart(emit);
              }
            },
          );
        } catch (e) {
          if (!emit.isDone) {
            // Revert optimistic update on error
            emit(CartLoaded(currentState.cartItems, cartResponse: currentState.cartResponse));
            emit(CartError('Failed to remove item from cart by quantity'));
          }
        }
      }
    }
  }

  Future<void> _onUpdateItemQuantity(UpdateItemQuantity event, Emitter<CartState> emit) async {
    final currentState = state;
    final list = _currentCartItems(currentState);
    if (list == null) return;
    final cartItems = list.$1;
    final cartResponse = list.$2;

    debugPrint('CartBloc: _onUpdateItemQuantity called');
    debugPrint('CartBloc: event.cartItemId = ${event.cartItemId}');
    debugPrint('CartBloc: event.quantity = ${event.quantity}');

    final itemIndex = cartItems.indexWhere((item) => item.product.id == event.cartItemId);
    if (itemIndex == -1) return;
    final currentItem = cartItems[itemIndex];

    if (event.quantity > currentItem.quantity) {
      debugPrint('CartBloc: Increasing quantity from ${currentItem.quantity} to ${event.quantity} - backend will validate stock');
    }

    // Optimistic update so product card and cart UI show new quantity immediately
    final updatedCartItems = cartItems.map<CartItem>((item) {
      if (item.product.id == event.cartItemId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();
    emit(CartUpdating(
      cartItems: updatedCartItems,
      cartResponse: cartResponse,
      updatingProductId: event.cartItemId,
    ));

    final isDecrement = event.quantity < currentItem.quantity;
    try {
      if (isDecrement) {
        // Decrement: use remove action (remove N) so backend does not re-validate stock and return "out of stock"
        final quantityToRemove = currentItem.quantity - event.quantity;
        final result = await _removeFromCartByQuantity(
          RemoveFromCartByQuantityParams(
            cartItemId: event.cartItemId,
            quantity: quantityToRemove,
          ),
        );
        await result.fold(
          (failure) async {
            if (!emit.isDone) {
              emit(CartLoaded(cartItems, cartResponse: cartResponse));
              emit(CartError(failure.message));
            }
          },
          (_) async {
            if (!emit.isDone) await _reloadCart(emit);
          },
        );
      } else {
        // Increment: use update action (set target quantity); backend validates stock
        final result = await _updateCartItemQuantity(
          UpdateCartItemQuantityParams(
            cartItemId: event.cartItemId,
            quantity: event.quantity,
          ),
        );
        await result.fold(
          (failure) async {
            if (!emit.isDone) {
              if (_isStockError(failure.message)) {
                _maxQuantities[event.cartItemId] = currentItem.quantity;
                debugPrint('CartBloc: Set max quantity for product ${event.cartItemId} to ${currentItem.quantity}');
                final formattedMessage = _formatStockErrorMessage(failure.message);
                emit(CartStockError(formattedMessage, cartItems, cartResponse));
              } else {
                emit(CartLoaded(cartItems, cartResponse: cartResponse));
                emit(CartError('Failed to update quantity. ${failure.message}'));
              }
            }
          },
          (_) async {
            _maxQuantities.remove(event.cartItemId);
            debugPrint('CartBloc: Cleared max quantity for product ${event.cartItemId} after successful update');
            if (!emit.isDone) await _reloadCart(emit);
          },
        );
      }
    } catch (e) {
      if (!emit.isDone) {
        final errorStr = e.toString();
        if (_isStockError(errorStr) && !isDecrement) {
          _maxQuantities[event.cartItemId] = currentItem.quantity;
          debugPrint('CartBloc: Set max quantity for product ${event.cartItemId} to ${currentItem.quantity}');
          emit(CartStockError(_formatStockErrorMessage(errorStr), cartItems, cartResponse));
        } else {
          emit(CartLoaded(cartItems, cartResponse: cartResponse));
          emit(CartError(isDecrement
              ? 'Failed to update quantity.'
              : 'Failed to update item quantity. Please check stock availability.'));
        }
      }
    }
  }

  Future<void> _onClearCart(ClearCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    
    // Clear max quantities when cart is cleared
    _maxQuantities.clear();
    
    final result = await _clearCart(NoParams());
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) => emit(const CartLoaded([], cartResponse: null)),
    );
  }

  Future<void> _reloadCart(Emitter<CartState> emit) async {
    try {
      debugPrint('CartBloc._reloadCart: Starting cart reload...');
      final cartResult = await _getCart(NoParams());
      await cartResult.fold(
        (failure) async {
          debugPrint('CartBloc._reloadCart: Failed to reload cart: ${failure.message}');
          if (!emit.isDone) emit(CartError(failure.message));
        },
        (cartData) async {
          debugPrint('CartBloc._reloadCart: Successfully reloaded ${cartData.items.length} cart items');
          for (final item in cartData.items) {
            debugPrint('CartBloc._reloadCart: Item - product_id: ${item.product.id}, quantity: ${item.quantity}, product_name: ${item.product.name}');
          }
          if (!emit.isDone) emit(CartLoaded(cartData.items, cartResponse: cartData.response));
        },
      );
    } catch (e) {
      debugPrint('CartBloc._reloadCart: Exception during reload: $e');
      if (!emit.isDone) emit(CartError('Failed to reload cart'));
    }
  }
}
