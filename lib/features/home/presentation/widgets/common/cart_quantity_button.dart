import 'dart:async';
import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/responsive_constants.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../../cart/domain/entities/cart_item.dart';
import 'package:zalando_clone_app/features/home/domain/entities/product.dart';
import 'package:zalando_clone_app/l10n/app_localizations.dart';

/// Cart control with three states:
/// - Initial: plus + logo (add to cart)
/// - Shortened: compact blue button with cart icon + quantity
/// - Expanded: full bar [trash/minus | qty | plus] with extend/shorten animation
class CartQuantityButton extends StatefulWidget {
  final Product product;
  final String productType;

  const CartQuantityButton({
    super.key,
    required this.product,
    this.productType = 'variant',
  });

  @override
  State<CartQuantityButton> createState() => _CartQuantityButtonState();
}

/// Pending snackbar after a cart action (add / increment / decrement / remove).
enum _CartSnackbarAction { add, increment, decrement, remove }

class _CartQuantityButtonState extends State<CartQuantityButton> {
  /// When true, show full [decrement | qty | increment] bar; when false and quantity > 0, show shortened (cart + number).
  bool _showFullControls = false;
  int _quantity = 0;
  bool _isAdding = false;
  /// True while any cart action (add / increment / decrement / remove) is in progress; shows loader in value section.
  bool _isUpdating = false;
  Timer? _collapseTimer;
  _CartSnackbarAction? _pendingSnackbarAction;

  static const Duration _animationDuration = Duration(milliseconds: 380);
  static const Curve _animationCurve = Curves.easeInOut;
  static const Duration _autoCollapseAfter = Duration(milliseconds: 2500);
  /// Delay after load completes before collapsing expanded bar so user sees the value.
  static const Duration _collapseAfterLoadDelay = Duration(seconds: 1);

  /// Orange used for quantity operators and count (matches app price/orange accent)
  static Color get _operatorOrange => Colors.orange.shade700;

  @override
  void initState() {
    super.initState();
    _checkCartQuantity();
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  void _startAutoCollapseTimer() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(_autoCollapseAfter, () {
      if (mounted && _showFullControls && _quantity > 0) {
        setState(() => _showFullControls = false);
      }
    });
  }

  void _cancelAutoCollapseTimer() {
    _collapseTimer?.cancel();
    _collapseTimer = null;
  }

  /// Collapse expanded bar after a short delay so the value is visible first.
  void _startCollapseAfterLoadTimer() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(_collapseAfterLoadDelay, () {
      if (mounted && _showFullControls && _quantity > 0) {
        setState(() => _showFullControls = false);
      }
    });
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: ResponsiveConstants.smSpacing),
            Expanded(
              child: Text(
                message,
                style: AppFonts.getTextStyle(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _checkCartQuantity() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cartState = context.read<CartBloc>().state;
      if (cartState is CartLoaded || cartState is CartUpdating) {
        final items = cartState is CartLoaded
            ? cartState.cartItems
            : (cartState as CartUpdating).cartItems;
        final cartItemIndex = items.indexWhere(
          (item) => item.product.id == widget.product.id,
        );
        if (cartItemIndex != -1) {
          final cartItem = items[cartItemIndex];
          if (mounted) {
            setState(() {
              _quantity = cartItem.quantity;
              _showFullControls = false; // Default to shortened when restored from cart
            });
          }
        }
      }
    });
  }

  void _addToCart() async {
    await HapticService.buttonClick();
    setState(() {
      _isAdding = true;
      _pendingSnackbarAction = _CartSnackbarAction.add;
    });

    final cartItem = CartItem(
      id: '',
      product: widget.product,
      quantity: 1,
      selectedColor: widget.product.colors.isNotEmpty ? widget.product.colors.first : '',
      selectedSize: widget.product.sizes.isNotEmpty ? widget.product.sizes.first : '',
      price: widget.product.price,
      addedAt: DateTime.now(),
    );
    context.read<CartBloc>().add(AddItemToCart(cartItem: cartItem));

    setState(() {
      _quantity = 1;
      _showFullControls = true; // Open expanded bar on first add
      _isUpdating = true;
    });
    _startAutoCollapseTimer();
    _showSuccessSnackbar(AppLocalizations.of(context)!.addedToCartSuccessfully);
  }

  void _increment() async {
    final cartBloc = context.read<CartBloc>();
    if (!cartBloc.canIncrement(widget.product.id, _quantity)) return;
    await HapticService.buttonClick();
    setState(() {
      _isAdding = true;
      _isUpdating = true;
      _pendingSnackbarAction = _CartSnackbarAction.increment;
    });

    final cartItem = CartItem(
      id: '',
      product: widget.product,
      quantity: 1,
      selectedColor: widget.product.colors.isNotEmpty ? widget.product.colors.first : '',
      selectedSize: widget.product.sizes.isNotEmpty ? widget.product.sizes.first : '',
      price: widget.product.price,
      addedAt: DateTime.now(),
    );
    context.read<CartBloc>().add(AddItemToCart(cartItem: cartItem));
    setState(() => _quantity++); // update UI immediately (we already guard with canIncrement so never above max)
    _startAutoCollapseTimer(); // if we were expanded, reset auto-collapse
    // Show "quantity increased" only on CartLoaded (success), not here – so at max we only show error snackbar
  }

  void _decrement() async {
    await HapticService.buttonClick();

    final cartState = context.read<CartBloc>().state;
    // Support CartLoaded, CartUpdating, and CartStockError (cart items available in all)
    final List<CartItem>? items = switch (cartState) {
      CartLoaded() => cartState.cartItems,
      CartUpdating() => cartState.cartItems,
      CartStockError() => cartState.cartItems,
      _ => null,
    };
    if (items == null) return;

    final cartItemIndex = items.indexWhere(
      (item) => item.product.id == widget.product.id,
    );
    if (cartItemIndex == -1) return;

    final cartItem = items[cartItemIndex];

    if (_quantity > 1) {
      setState(() => _isUpdating = true);
      context.read<CartBloc>().add(
        UpdateItemQuantity(
          cartItemId: cartItem.product.id,
          quantity: _quantity - 1,
        ),
      );
      setState(() => _quantity--);
      _startAutoCollapseTimer(); // reset auto-collapse after user action
      _showSuccessSnackbar(AppLocalizations.of(context)!.cartQuantityReduced);
    } else {
      setState(() => _isUpdating = true);
      context.read<CartBloc>().add(
        RemoveItemFromCart(cartItemId: cartItem.product.id),
      );
      setState(() {
        _quantity = 0;
        _showFullControls = false;
      });
      _cancelAutoCollapseTimer();
      _showSuccessSnackbar(AppLocalizations.of(context)!.itemRemovedFromCart);
    }
  }

  void _toggleExpanded() {
    if (_quantity <= 0) return;
    setState(() {
      _showFullControls = !_showFullControls;
      if (_showFullControls) {
        _startAutoCollapseTimer();
      } else {
        _cancelAutoCollapseTimer();
      }
    });
  }

  bool get _canIncrement {
    return context.read<CartBloc>().canIncrement(widget.product.id, _quantity);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartLoaded || state is CartUpdating) {
          final items = state is CartLoaded
              ? state.cartItems
              : (state as CartUpdating).cartItems;
          final cartItemIndex = items.indexWhere(
            (item) => item.product.id == widget.product.id,
          );

          if (cartItemIndex != -1) {
            final cartItem = items[cartItemIndex];
            final cartBloc = context.read<CartBloc>();
            final maxQty = cartBloc.getMaxQuantity(widget.product.id);
            // Cap displayed quantity by stock max so we never show more than allowed
            final displayQty = maxQty != null
                ? min(cartItem.quantity, maxQty)
                : cartItem.quantity;
            // While add is in progress, do not apply optimistic CartUpdating quantity;
            // wait for CartLoaded (success) or CartStockError (revert) so UI never exceeds stock.
            final skipOptimistic = state is CartUpdating && _isAdding;
            if (!skipOptimistic && displayQty != _quantity && mounted) {
              setState(() {
                _quantity = displayQty;
                _showFullControls = false;
              });
            }
          } else {
            // Item no longer in cart (e.g. deleted) – always show initial add state
            if (mounted && _quantity != 0) {
              setState(() {
                _quantity = 0;
                _showFullControls = false;
              });
            }
          }

          if (state is CartLoaded) {
            if (_pendingSnackbarAction == _CartSnackbarAction.increment && mounted) {
              _showSuccessSnackbar(AppLocalizations.of(context)!.cartQuantityIncreased);
            }
            _isAdding = false;
            _isUpdating = false;
            _pendingSnackbarAction = null;
            // Show value in expanded bar (loader gone), then collapse after 1s
            if (mounted) {
              setState(() {});
              _startCollapseAfterLoadTimer();
            }
          }
        } else if (state is CartError) {
          if (_isAdding || _isUpdating || _pendingSnackbarAction != null) {
            _isAdding = false;
            _isUpdating = false;
            _pendingSnackbarAction = null;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.white, size: 20),
                      SizedBox(width: ResponsiveConstants.smSpacing),
                      Expanded(
                        child: Text(
                          state.message.isNotEmpty
                              ? state.message
                              : AppLocalizations.of(context)!.failedToAddItemToCart,
                          style: AppFonts.getTextStyle(),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
          if (mounted) _checkCartQuantity();
        } else if (state is CartStockError) {
          // Revert UI to server quantity (e.g. 3) so we never show over stock (e.g. 4)
          final itemIndex = state.cartItems.indexWhere(
            (item) => item.product.id == widget.product.id,
          );
          if (itemIndex != -1 && mounted) {
            final serverQuantity = state.cartItems[itemIndex].quantity;
            setState(() {
              _quantity = serverQuantity;
              _showFullControls = false;
            });
          }
          if (_isAdding || _isUpdating || _pendingSnackbarAction != null) {
            _isAdding = false;
            _isUpdating = false;
            _pendingSnackbarAction = null;
            if (mounted) {
              final cartBloc = context.read<CartBloc>();
              final maxQty = cartBloc.getMaxQuantity(widget.product.id);
              final message = maxQty != null
                  ? AppLocalizations.of(context)!.maxOrderLimitReached(maxQty)
                  : state.message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 20),
                      SizedBox(width: ResponsiveConstants.smSpacing),
                      Expanded(
                        child: Text(
                          message,
                          style: AppFonts.getTextStyle(),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.orange.shade700,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      },
      child: AnimatedSize(
        duration: _animationDuration,
        curve: _animationCurve,
        alignment: Alignment.centerRight,
        child: _quantity == 0
            ? _buildInitialButton(context, colorScheme)
            : _showFullControls
                ? _buildExpandedButton(context, colorScheme)
                : _buildShortenedButton(context, colorScheme),
      ),
    );
  }

  /// Starting stage: rounded button with plus only, light fill, subtle shadow.
  Widget _buildInitialButton(BuildContext context, ColorScheme colorScheme) {
    return GestureDetector(
      key: const ValueKey<String>('initial'),
      onTap: _addToCart,
      child: Container(
        height: 28.h,
        width: 28.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              spreadRadius: 1.5,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          size: 18.w,
        ),
      ),
    );
  }

  /// Shortened state: transparent background, orange cart icon + count, no border, no shadow.
  Widget _buildShortenedButton(BuildContext context, ColorScheme colorScheme) {
    return GestureDetector(
      key: const ValueKey<String>('shortened'),
      onTap: () {
        HapticService.buttonClick();
        _toggleExpanded();
      },
      child: Container(
        height: 28.h,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              color: _operatorOrange,
              size: 16.w,
            ),
            SizedBox(width: 4.w),
            Text(
              '$_quantity',
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.smFontSize,
                fontWeight: FontWeight.w700,
                color: _operatorOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Expanded state: light grey bg, orange minus/count/plus, subtle shadow.
  Widget _buildExpandedButton(BuildContext context, ColorScheme colorScheme) {
    final showDeleteButton = _quantity == 1;

    return Container(
      key: const ValueKey<String>('expanded'),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left: delete (when quantity is 1) or decrement – transparent bg, orange icon
          GestureDetector(
            onTap: _decrement,
            child: Container(
              width: 28.w,
              height: 28.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ResponsiveConstants.smRadius - 1),
                  bottomLeft: Radius.circular(ResponsiveConstants.smRadius - 1),
                ),
              ),
              child: Icon(
                showDeleteButton ? Icons.delete_outline : Icons.remove,
                color: _operatorOrange,
                size: 16.w,
              ),
            ),
          ),
          // Center: quantity or small loader while updating
          Container(
            height: 28.h,
            constraints: BoxConstraints(minWidth: 28.w),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            color: Colors.transparent,
            alignment: Alignment.center,
            child: _isUpdating
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _operatorOrange,
                    ),
                  )
                : Text(
                    '$_quantity',
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.smFontSize,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
          ),
          // Right: increment – disabled when at max limit (no tap, clearly greyed out)
          IgnorePointer(
            ignoring: !_canIncrement,
            child: GestureDetector(
              onTap: _canIncrement ? _increment : null,
              child: Container(
                width: 28.w,
                height: 28.h,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(ResponsiveConstants.smRadius - 1),
                    bottomRight: Radius.circular(ResponsiveConstants.smRadius - 1),
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: _canIncrement
                      ? _operatorOrange
                      : colorScheme.onSurface.withValues(alpha: 0.35),
                  size: 16.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
