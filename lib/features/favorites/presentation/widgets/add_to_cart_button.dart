import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../cart/cart.dart';
import '../../../home/domain/entities/product.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../../domain/entities/favorite_product.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class AddToCartButton extends StatefulWidget {
  final Product product;
  final double size;
  final Color? color;
  final bool isCompact;
  final VoidCallback? onAddToCart;
  final Function(int)? onTabChanged;

  const AddToCartButton({
    super.key,
    required this.product,
    this.size = 24.0,
    this.color,
    this.isCompact = true,
    this.onAddToCart,
    this.onTabChanged,
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        // Only react to cart state changes when this button initiated the add
        if (!_isAdding) return;

        final loc = AppLocalizations.of(context)!;

        final localeCode = Localizations.localeOf(context).languageCode;

        if (state is CartError) {
          _isAdding = false;
          final baseMessage = loc.failedToAddItemToCart;
          final detail = state.message.isNotEmpty ? state.message : '';
          final fullMessage = localeCode == 'ar'
              ? baseMessage
              : (detail.isNotEmpty ? '$baseMessage\n$detail' : baseMessage);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                fullMessage,
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is CartStockError) {
          _isAdding = false;
          final baseMessage = loc.failedToAddItemToCart;
          final detail = state.message.isNotEmpty ? state.message : '';
          final fullMessage = localeCode == 'ar'
              ? baseMessage
              : (detail.isNotEmpty ? '$baseMessage\n$detail' : baseMessage);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                fullMessage,
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is CartLoaded) {
          // Cart successfully updated after add-to-cart from favorites
          _isAdding = false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: ResponsiveConstants.smSpacing),
                  Expanded(
                    child: Text(
                      '${widget.product.name} — ${loc.itemAddedToCart}',
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

          // If this button is used from Favorites, remove item from favorites
          // only after cart add succeeds and trigger the slide-out animation.
          if (widget.onAddToCart != null) {
            final favoriteProduct = FavoriteProduct(
              id: widget.product.id,
              name: widget.product.name,
              brand: widget.product.brand,
              price: widget.product.price,
              imageUrl: widget.product.images.isNotEmpty
                  ? widget.product.images.first
                  : null,
              category: widget.product.category,
              addedAt: DateTime.now(),
            );

            context.read<FavoritesBloc>().add(
                  ToggleFavorite(favoriteProduct, true),
                );

            widget.onAddToCart!.call();
          }

          // Navigate to cart page:
          // - Use tab callback when available (main home tabs)
          // - Fall back to explicit /cart route when opened from elsewhere
          if (widget.onTabChanged != null) {
            widget.onTabChanged!.call(3);
          } else {
            Navigator.of(context).pushNamed('/cart');
          }
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final isOutOfStock = !widget.product.isAvailable;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isOutOfStock ? null : () async {
                await HapticService.buttonClick();
                _addToCart(context);
              },
              borderRadius: BorderRadius.circular(widget.isCompact ? 16 : 20),
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: widget.isCompact ? EdgeInsets.all(6) : EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isOutOfStock ? Colors.grey.shade300 : Colors.white,
                        borderRadius: BorderRadius.circular(widget.isCompact ? 16 : 20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isOutOfStock ? 0.05 : 0.1),
                            blurRadius: widget.isCompact ? 6 : 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: isOutOfStock ? Colors.grey.shade400 : Colors.black,
                          width: widget.isCompact ? 0.5 : 1,
                        ),
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: isOutOfStock ? Colors.grey.shade600 : Colors.black,
                        size: widget.isCompact ? widget.size * 0.7 : widget.size * 0.8,
                      ),
                    ),
                  );
                },
              ).animate(
                target: _isAdding ? 1 : 0,
              ).scale(
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
              ),
            ),
          );
        },
      ),
    );
  }

  void _addToCart(BuildContext context) {
    // Check if product is available
    // Product.isAvailable should be set correctly from FavoriteProduct.isAvailable
    if (!widget.product.isAvailable) {
      final localeCode = Localizations.localeOf(context).languageCode;
      final message = localeCode == 'ar'
          ? 'هذا المنتج غير متوفر في المخزون ولا يمكن إضافته إلى سلة التسوق.'
          : 'This item is out of stock and cannot be added to your cart.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Expanded(
                child: Text(
                  message,
                  style: AppFonts.getTextStyle(),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Trigger tap animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _isAdding = true;
    });

    // Create cart item with default color and size
    final defaultColor = widget.product.colors.isNotEmpty 
        ? widget.product.colors.first 
        : 'Default';
    final defaultSize = widget.product.sizes.isNotEmpty 
        ? widget.product.sizes.first 
        : 'M';

    // Create CartItem
    final cartItem = CartItem(
      id: '${widget.product.id}_${defaultColor}_$defaultSize',
      product: widget.product,
      quantity: 1,
      selectedColor: defaultColor,
      selectedSize: defaultSize,
      price: widget.product.price,
      addedAt: DateTime.now(),
    );

    // Add to cart
    context.read<CartBloc>().add(
      AddItemToCart(cartItem: cartItem),
    );
  }
}
