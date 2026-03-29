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
import '../../../../l10n/app_localizations.dart';

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
    return Container(
      decoration: _buildCardDecoration(context),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          ResponsiveConstants.mdPadding,
          ResponsiveConstants.smPadding + 2,
          ResponsiveConstants.mdPadding,
          ResponsiveConstants.smPadding + 2,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 340;
            final tileExtent = isNarrow ? 88.0 : 96.0;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(context, tileExtent: tileExtent),
                SizedBox(width: ResponsiveConstants.mdSpacing),
                Expanded(child: _buildProductDetails(context)),
              ],
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(
            alpha: isDark ? 0.4 : 0.1,
          ),
          blurRadius: isDark ? 20 : 14,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(
            alpha: isDark ? 0.18 : 0.04,
          ),
          blurRadius: isDark ? 6 : 3,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildProductImage(BuildContext context, {required double tileExtent}) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        await HapticService.buttonClick();
        _navigateToProductDetails(context);
      },
      child: Container(
        width: tileExtent,
        height: tileExtent,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
          color: Colors.white,
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            ResponsiveConstants.smRadius - 0.5,
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildProductHeader(context)),
            _buildRemoveButton(context),
          ],
        ),
        if (_hasVariantChips()) ...[
          SizedBox(height: ResponsiveConstants.smSpacing),
          _buildProductAttributes(context),
        ],
        SizedBox(height: ResponsiveConstants.mdSpacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildPriceSection(context)),
            _QuantitySelector(cartItem: cartItem),
          ],
        ),
      ],
    );
  }

  bool _hasVariantChips() {
    return cartItem.selectedSize.isNotEmpty ||
        cartItem.selectedColor.isNotEmpty;
  }

  Widget _buildProductHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondary = _secondaryProductLine();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cartItem.product.brand.isNotEmpty) ...[
          Text(
            cartItem.product.brand,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.xsFontSize,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            softWrap: true,
          ),
          SizedBox(height: ResponsiveConstants.xsSpacing),
        ],
        GestureDetector(
          onTap: () async {
            await HapticService.buttonClick();
            _navigateToProductDetails(context);
          },
          child: Text(
            cartItem.product.name,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize + 1,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              height: 1.25,
            ),
            softWrap: true,
          ),
        ),
        if (secondary != null) ...[
          SizedBox(height: ResponsiveConstants.xsSpacing),
          Text(
            secondary,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.xsFontSize,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
            softWrap: true,
          ),
        ],
      ],
    );
  }

  /// Subtitle line: category when distinct from the title (no dedicated SKU on [Product]).
  String? _secondaryProductLine() {
    final category = cartItem.product.category.trim();
    if (category.isEmpty) return null;
    final name = cartItem.product.name.trim();
    if (category.toLowerCase() == name.toLowerCase()) return null;
    return category;
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
        horizontal: ResponsiveConstants.smPadding + 2,
        vertical: ResponsiveConstants.xsPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.xsFontSize,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final currencyProvider = context.watch<CurrencyProvider>();
        final isUpdating = state is CartUpdating && state.updatingProductId == cartItem.product.id;
        final colorScheme = Theme.of(context).colorScheme;

        if (isUpdating) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              height: 22,
              width: 112,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                currencyProvider.formatPrice(
                  cartItem.price,
                  locale: Localizations.localeOf(context),
                ),
                softWrap: true,
                textAlign: TextAlign.start,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ),
            if (cartItem.product.originalPrice != null &&
                cartItem.product.originalPrice! > cartItem.price) ...[
              SizedBox(width: ResponsiveConstants.smSpacing),
              Flexible(
                child: Text(
                  currencyProvider.formatPrice(
                    cartItem.product.originalPrice!,
                    locale: Localizations.localeOf(context),
                  ),
                  softWrap: true,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.smFontSize,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
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

  Widget _buildRemoveButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return IconButton(
      tooltip: loc.removeFromCart,
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () async {
        await HapticService.buttonClick();
        onRemove?.call();
        final cartBloc = context.read<CartBloc>();
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
    final p = cartItem.product;
    Navigator.of(context).pushNamed(
      '/product-details',
      arguments: {
        'productId': p.id,
        'productType': 'variant',
        'cardPreview': {
          'imageUrl': p.images.isNotEmpty ? p.images.first : null,
          'brand': p.brand,
          'productTitle': p.name,
          'price': cartItem.price,
        },
      },
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final CartItem cartItem;

  const _QuantitySelector({required this.cartItem});

  static const double _minSideTap = 40;

  @override
  Widget build(BuildContext context) {
    final cartBloc = context.read<CartBloc>();
    final canIncrement = cartBloc.canIncrement(cartItem.product.id, cartItem.quantity);
    final loc = AppLocalizations.of(context)!;

    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.22),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            tooltip: loc.decreaseQuantity,
            icon: Icons.remove,
            onTap: () async {
              await HapticService.buttonClick();
              _updateQuantity(context, cartItem.quantity - 1);
            },
            isEnabled: cartItem.quantity > 1,
            minSide: _minSideTap,
          ),
          _buildQuantityDisplay(context),
          _QuantityButton(
            tooltip: loc.increaseQuantity,
            icon: Icons.add,
            onTap: () async {
              await HapticService.buttonClick();
              _updateQuantity(context, cartItem.quantity + 1);
            },
            isEnabled: canIncrement,
            minSide: _minSideTap,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityDisplay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 34,
        maxWidth: 44,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.xsPadding + 1,
        vertical: ResponsiveConstants.xsPadding - 1,
      ),
      child: Text(
        '${cartItem.quantity}',
        textAlign: TextAlign.center,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.smFontSize,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        overflow: TextOverflow.visible,
        maxLines: 1,
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
  final String tooltip;
  final double minSide;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.isEnabled,
    required this.tooltip,
    required this.minSide,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          canRequestFocus: isEnabled,
          child: SizedBox(
            width: minSide,
            height: minSide,
            child: Icon(
              icon,
              size: ResponsiveConstants.smIconSize + 1,
              color: isEnabled
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
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
