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
        if (state is CartError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is CartLoaded) {
          // Show success message when item is added
          if (_isAdding) {
            _isAdding = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    Expanded(
                      child: Text(
                        '${widget.product.name} added to cart!',
                        style: AppFonts.getTextStyle(),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
          await HapticService.buttonClick();
          // Switch to cart tab (index 3)
                        widget.onTabChanged?.call(3);
        },
                      child: Text(
                        'VIEW CART',
                        style: AppFonts.getTextStyle(color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Expanded(
                child: Text(
                  '${widget.product.name} is out of stock',
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

    // Remove from favorites
    final favoriteProduct = FavoriteProduct(
      id: widget.product.id,
      name: widget.product.name,
      brand: widget.product.brand,
      price: widget.product.price,
      imageUrl: widget.product.images.isNotEmpty ? widget.product.images.first : null,
      category: widget.product.category,
      addedAt: DateTime.now(),
    );

    context.read<FavoritesBloc>().add(
      ToggleFavorite(favoriteProduct, true), // true means remove from favorites
    );

    // Trigger the slide animation callback
    widget.onAddToCart?.call();
  }
}
