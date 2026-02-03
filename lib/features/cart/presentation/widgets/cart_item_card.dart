import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../domain/entities/cart_item.dart';
import '../bloc/cart_bloc.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../core/services/app_localization_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/cart_response_model.dart';
import '../../../checkout/presentation/constants/checkout_constants.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback? onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final localizationService = AppLocalizationService();
    final isRTL = localizationService.isRTL;
    
    return Container(
      decoration: _buildCardDecoration(context),
      child: Stack(
        children: [
          // Main content with margin for buttons (responsive to language direction)
          Padding(
            padding: EdgeInsets.only(
              left: isRTL ? ResponsiveConstants.mdPadding + 80 : ResponsiveConstants.mdPadding,
              top: ResponsiveConstants.mdPadding,
              bottom: ResponsiveConstants.mdPadding + 56, // reserve space for quantity control
              right: isRTL ? ResponsiveConstants.mdPadding : ResponsiveConstants.mdPadding + 80,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 340;
                final imageSize = constraints.maxWidth * (isNarrow ? 0.22 : 0.18);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(context, size: imageSize.clamp(56.0, 96.0)),
                    SizedBox(width: ResponsiveConstants.mdSpacing),
                    _buildProductDetails(context),
                  ],
                );
              },
            ),
          ),
          // Delete button - top right for LTR, top left for RTL
          Positioned(
            top: ResponsiveConstants.smPadding,
            right: isRTL ? null : ResponsiveConstants.smPadding,
            left: isRTL ? ResponsiveConstants.smPadding : null,
            child: _buildRemoveButton(context),
          ),
          // Quantity selector - bottom right for LTR, bottom left for RTL
          Positioned(
            bottom: ResponsiveConstants.smPadding,
            right: isRTL ? null : ResponsiveConstants.smPadding,
            left: isRTL ? ResponsiveConstants.smPadding : null,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              bottom: true,
              child: _QuantitySelector(cartItem: cartItem),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: isDark ? 0.4 : 0.1,
          ),
          blurRadius: CheckoutConstants.cardShadowBlur,
          offset: Offset(0, CheckoutConstants.cardShadowOffset),
        ),
      ],
    );
  }

  Widget _buildProductImage(BuildContext context, {double size = 80}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () async {
        await HapticService.buttonClick();
        _navigateToProductDetails(context);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
          color: colorScheme.surface,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
          child: Hero(
            tag: 'product_image_${cartItem.product.id}',
            child: cartItem.product.images.isNotEmpty
                ? _CartItemImageLoader(
                    imageUrl: cartItem.product.images.first,
                    placeholder: _buildImagePlaceholder(),
                    errorWidget: _buildImageError(),
                  )
                : _buildImageError(),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Container(
          color: colorScheme.surface,
          child: Center(
            child: SizedBox(
              width: ResponsiveConstants.mdIconSize,
              height: ResponsiveConstants.mdIconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageError() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Container(
          color: colorScheme.surface,
          child: Icon(
            Icons.error,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            size: ResponsiveConstants.mdIconSize,
          ),
        );
      },
    );
  }

  Widget _buildProductDetails(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductHeader(context),
          SizedBox(height: ResponsiveConstants.smSpacing),
          _buildProductAttributes(context),
          SizedBox(height: ResponsiveConstants.smSpacing),
          _buildPriceSection(),
          SizedBox(height: ResponsiveConstants.xsSpacing),
          _buildTaxDetails(context),
        ],
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cartItem.product.brand,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.xsFontSize,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () async {
            await HapticService.buttonClick();
            _navigateToProductDetails(context);
          },
          child: Text(
            cartItem.product.name,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProductAttributes(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final variantChips = <Widget>[];
    
    // Add size chip if available
    if (cartItem.selectedSize.isNotEmpty) {
      variantChips.add(
        _buildVariantChip(
          context,
          '${loc.size}: ${cartItem.selectedSize}',
        ),
      );
    }
    
    // Add color chip if available
    if (cartItem.selectedColor.isNotEmpty) {
      variantChips.add(
        _buildVariantChip(
          context,
          '${loc.color}: ${cartItem.selectedColor}',
        ),
      );
    }
    
    // Add brand chip if available and not already in product name
    if (cartItem.product.brand.isNotEmpty) {
      variantChips.add(
        _buildVariantChip(
          context,
          '${loc.brand}: ${cartItem.product.brand}',
        ),
      );
    }
    
    if (variantChips.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Wrap(
      spacing: ResponsiveConstants.xsSpacing,
      runSpacing: ResponsiveConstants.xsSpacing,
      children: variantChips,
    );
  }

  Widget _buildVariantChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.xsPadding + 2,
        vertical: ResponsiveConstants.xsPadding - 1,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.xsFontSize - 1,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final currencyProvider = context.watch<CurrencyProvider>();
        final isUpdating = state is CartUpdating && state.updatingProductId == cartItem.product.id;
        final colorScheme = Theme.of(context).colorScheme;
        
        if (isUpdating) {
          return Container(
            height: 20,
            width: 100,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
          );
        }
        return Row(
          children: [
            Flexible(
              child: Text(
                currencyProvider.formatPrice(cartItem.price, locale: Localizations.localeOf(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
            if (cartItem.product.originalPrice != null && 
                cartItem.product.originalPrice! > cartItem.price) ...[
              SizedBox(width: ResponsiveConstants.smSpacing),
              Flexible(
                child: Text(
                  currencyProvider.formatPrice(cartItem.product.originalPrice!, locale: Localizations.localeOf(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.smFontSize,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTaxDetails(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return const _TaxShimmer();
        }
        if (state is CartUpdating && state.updatingProductId == cartItem.product.id) {
          return const _TaxShimmer();
        }
        CartResponseModel? response;
        if (state is CartLoaded && state.cartResponse != null && state.cartResponse!.lines.isNotEmpty) {
          response = state.cartResponse!;
        } else if (state is CartUpdating && state.cartResponse != null && state.cartResponse!.lines.isNotEmpty) {
          response = state.cartResponse!;
        }
        if (response != null) {
          // Try match by line_id first (cartItem.id maps from lineId)
          final int? lineId = int.tryParse(cartItem.id);
          var lineItem = lineId != null
              ? (response.lines.where((line) => line.lineId == lineId).isNotEmpty
                  ? response.lines.firstWhere((line) => line.lineId == lineId)
                  : null)
              : null;

          // Fallback match by product_id if line_id didn't match semantically
          if (lineItem == null || (lineId != null && lineItem.lineId != lineId)) {
            final matches = response.lines.where(
              (line) => line.productId.toString() == cartItem.product.id,
            );
            if (matches.isNotEmpty) {
              lineItem = matches.first;
            }
          }

          if (lineItem == null) return const SizedBox.shrink();

          // Store in local non-nullable variable for use in closures
          final nonNullLineItem = lineItem!;

          // Prefer detailed breakdown if available
          if (nonNullLineItem.taxDetails.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...nonNullLineItem.taxDetails.map((taxDetail) => Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: ResponsiveConstants.xsIconSize,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      SizedBox(width: ResponsiveConstants.xsSpacing),
                      Expanded(
                        child: Text(
                          '${taxDetail.taxName}: ${_formatCurrency(taxDetail.taxAmount, context)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.xsFontSize,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                Padding(
                  padding: EdgeInsets.only(top: ResponsiveConstants.xsSpacing),
                  child: Builder(
                    builder: (context) {
                      final colorScheme = Theme.of(context).colorScheme;
                      
                      return Row(
                        children: [
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context)!.totalWithTax,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.xsFontSize,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          SizedBox(width: ResponsiveConstants.xsSpacing),
                          Flexible(
                            child: Text(
                              _formatCurrency(nonNullLineItem.priceTotal, context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.smFontSize,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Fallback to show item-level tax and total if no taxDetails
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: ResponsiveConstants.xsIconSize,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          SizedBox(width: ResponsiveConstants.xsSpacing),
                          Expanded(
                            child: Text(
                              '${AppLocalizations.of(context)!.tax}: ${_formatCurrency(nonNullLineItem.taxAmount, context)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.xsFontSize,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context)!.totalWithTax,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.xsFontSize,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          SizedBox(width: ResponsiveConstants.xsSpacing),
                          Flexible(
                            child: Text(
                              _formatCurrency(nonNullLineItem.priceTotal, context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.smFontSize,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  String _formatCurrency(double amount, BuildContext context) {
    // Use the cached currency from provider for consistent formatting
    final currencyProvider = context.watch<CurrencyProvider>();
    return currencyProvider.formatPrice(amount, locale: Localizations.localeOf(context));
  }



  Widget _buildRemoveButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return IconButton(
      onPressed: () async {
        await HapticService.buttonClick();
        onRemove?.call();
        final cartBloc = context.read<CartBloc>();
        // Remove the full quantity of this item from the cart
        Future.delayed(const Duration(milliseconds: 500), () {
          cartBloc.add(
            RemoveItemFromCartByQuantity(
              cartItemId: cartItem.product.id,
              quantity: cartItem.quantity,
            ),
          );
        });
      },
      icon: Icon(
        Icons.delete_outline,
        color: colorScheme.error,
        size: ResponsiveConstants.mdIconSize,
      ),
    );
  }

  void _navigateToProductDetails(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/product-details',
      arguments: {
        'productId': cartItem.product.id,
        'productType': 'variant',
      },
    );
  }
}

class _TaxShimmer extends StatelessWidget {
  const _TaxShimmer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: colorScheme.outline.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: ResponsiveConstants.xsSpacing),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final CartItem cartItem;

  const _QuantitySelector({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cartBloc = context.read<CartBloc>();
    final canIncrement = cartBloc.canIncrement(cartItem.product.id, cartItem.quantity);
    
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove,
            onTap: () async {
              await HapticService.buttonClick();
              _updateQuantity(context, cartItem.quantity - 1);
            },
            isEnabled: cartItem.quantity > 1,
          ),
          _buildQuantityDisplay(context),
          _QuantityButton(
            icon: Icons.add,
            onTap: () async {
              await HapticService.buttonClick();
              _updateQuantity(context, cartItem.quantity + 1);
            },
            isEnabled: canIncrement,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityDisplay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      constraints: BoxConstraints(
        minWidth: 40,
        maxWidth: 60, // Allow for larger quantities
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.smPadding,
        vertical: ResponsiveConstants.xsPadding,
      ),
      child: Text(
        '${cartItem.quantity}',
        textAlign: TextAlign.center,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.smFontSize,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        overflow: TextOverflow.visible, // Prevent text wrapping
        maxLines: 1, // Force single line
      ),
    );
  }

  void _updateQuantity(BuildContext context, int newQuantity) {
    final currentQuantity = cartItem.quantity;
    final cartBloc = context.read<CartBloc>();
    
    debugPrint('CartItemCard: _updateQuantity called');
    debugPrint('CartItemCard: cartItem.product.id = ${cartItem.product.id}');
    debugPrint('CartItemCard: currentQuantity = $currentQuantity');
    debugPrint('CartItemCard: newQuantity = $newQuantity');
    
    if (newQuantity > currentQuantity) {
      // Adding items - use add operation
      final quantityToAdd = newQuantity - currentQuantity;
      debugPrint('CartItemCard: Adding $quantityToAdd items');
      cartBloc.add(
        AddItemToCart(
          cartItem: cartItem.copyWith(quantity: quantityToAdd),
        ),
      );
    } else if (newQuantity < currentQuantity) {
      // Removing items - use remove operation
      final quantityToRemove = currentQuantity - newQuantity;
      debugPrint('CartItemCard: Removing $quantityToRemove items');
      cartBloc.add(
        RemoveItemFromCartByQuantity(
          cartItemId: cartItem.product.id,
          quantity: quantityToRemove,
        ),
      );
    }
    // If newQuantity == currentQuantity, do nothing
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
        child: Icon(
          icon,
          size: ResponsiveConstants.smIconSize,
          color: isEnabled 
              ? colorScheme.primary 
              : colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

/// StatefulWidget to cache the image loading future and prevent reloading on rebuild
class _CartItemImageLoader extends StatefulWidget {
  final String imageUrl;
  final Widget placeholder;
  final Widget errorWidget;

  const _CartItemImageLoader({
    required this.imageUrl,
    required this.placeholder,
    required this.errorWidget,
  });

  @override
  State<_CartItemImageLoader> createState() => _CartItemImageLoaderState();
}

class _CartItemImageLoaderState extends State<_CartItemImageLoader> {
  // Use a non-final late field so we can safely reassign it in didUpdateWidget
  late Future<Map<String, dynamic>> _imageDataFuture;

  @override
  void initState() {
    super.initState();
    // Cache the future so it doesn't recreate on rebuild
    _imageDataFuture = ImageCacheUtils.getAuthenticatedImageData(
      widget.imageUrl,
      useCacheBuster: false, // Disable cache buster to prevent reloading on page enter
    );
  }

  @override
  void didUpdateWidget(_CartItemImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only recreate future if image URL actually changed
    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageDataFuture = ImageCacheUtils.getAuthenticatedImageData(
        widget.imageUrl,
        useCacheBuster: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _imageDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return widget.placeholder;
        }
        final data = snapshot.data!;
        return CachedNetworkImage(
          imageUrl: data['url'] as String,
          fit: BoxFit.contain,
          httpHeaders: data['headers'] as Map<String, String>,
          placeholder: (context, url) => widget.placeholder,
          errorWidget: (context, url, error) => widget.errorWidget,
        );
      },
    );
  }
}
