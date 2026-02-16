import 'package:flutter/material.dart';
import '../../../../core/theme/app_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/services/haptic_service.dart';

import '../../domain/entities/product_details.dart';
import '../bloc/product_details_bloc.dart';
import '../controllers/dynamic_variant_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../utils/attribute_label_helper.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../../core/navigation/navigation_service.dart';

class AddToCartBottomSheet extends StatelessWidget {
  final ProductDetailsBloc bloc;

  const AddToCartBottomSheet({
    super.key,
    required this.bloc,
  });

  static Future<void> show(
    BuildContext context,
    ProductDetailsBloc bloc,
    DynamicVariantController variantController,
  ) {
    // Log current controller state for debugging
    debugPrint('📦 AddToCartBottomSheet.show() called');
    debugPrint('   Controller variantId: ${variantController.variantId}');
    debugPrint('   Controller quantityAvailable: ${variantController.quantityAvailable}');
    debugPrint('   Controller selectedAttributes: ${variantController.selectedAttributes}');
    debugPrint('   Controller currentPrice: ${variantController.currentPrice}');
    debugPrint('   Controller inStock: ${variantController.inStock}');
    
    // Always reset quantity to 1 when opening the bottom sheet
    // This ensures fresh state for each variant selection
    final currentState = bloc.state;
    if (currentState is ProductDetailsLoaded) {
      // Always reset to 1 for a fresh start
      if (currentState.quantity != 1) {
        final availableQty = variantController.quantityAvailable;
        debugPrint('🔄 Resetting quantity from ${currentState.quantity} to 1 (available: $availableQty)');
        bloc.add(ResetQuantityEvent(quantity: 1));
      }
    }
    
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height * 0.8, // Responsive max height
      ),
      builder: (context) => MultiProvider(
        providers: [
          BlocProvider.value(value: bloc),
          ChangeNotifierProvider.value(value: variantController),
        ],
        child: AddToCartBottomSheet(bloc: bloc),
      ),
    ).then((_) {
      // Reset the isAdding state when the bottom sheet is closed
      bloc.add(ResetAddingStateEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveConstants.lgPadding,
              ResponsiveConstants.mdSpacing,
              ResponsiveConstants.lgPadding,
              ResponsiveConstants.lgPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () async {
                    await HapticService.buttonClick();
                    Navigator.of(context).pop();
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product Info Card
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.lgPadding,
            ),
            padding: EdgeInsets.all(ResponsiveConstants.mdSpacing),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Consumer<DynamicVariantController>(
              builder: (context, variantController, _) {
                // Get current productDetails from controller (always fresh)
                final pd = variantController.productDetails;
                if (pd == null) {
                  return const SizedBox.shrink();
                }
                
                // Get current images from controller
                final currentImages = variantController.currentImages.isNotEmpty
                    ? variantController.currentImages
                    : pd.images;
                
                // Get selected attribute values from controller
                final selectedAttrValues = _getSelectedAttributeValues(
                  context,
                  variantController,
                  pd,
                );
                
                return Row(
                  children: [
                    // Product Image - Use controller's current images
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ResponsiveConstants.smRadius,
                      ),
                      child: currentImages.isEmpty
                          ? Container(
                              width: ResponsiveConstants.xlDimension,
                              height: ResponsiveConstants.xlDimension,
                              color: Theme.of(context).colorScheme.surface,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.4),
                                size: 28,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: currentImages.first,
                              width: ResponsiveConstants.xlDimension,
                              height: ResponsiveConstants.xlDimension,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Container(
                                width: ResponsiveConstants.xlDimension,
                                height: ResponsiveConstants.xlDimension,
                                color: Theme.of(context).colorScheme.surface,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: ResponsiveConstants.xlDimension,
                                height: ResponsiveConstants.xlDimension,
                                color: Theme.of(context).colorScheme.surface,
                                child: Icon(
                                  Icons.error,
                                  color:
                                      Theme.of(context).colorScheme.error,
                                  size: 24,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(width: ResponsiveConstants.mdSpacing),

                    // Product Details - Use controller's selected attributes
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pd.brand,
                            style: AppFonts.getTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pd.name + (selectedAttrValues.isNotEmpty
                                ? ' (${selectedAttrValues.join(', ')})'
                                : ''),
                            style: AppFonts.getTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              // Use variant-specific price if available, otherwise fallback to template price
                              Consumer<CurrencyProvider>(
                                builder: (context, currencyProvider, child) {
                                  final unitPrice = variantController.currentPrice > 0 
                                      ? variantController.currentPrice 
                                      : pd.price;
                                  
                                  return Row(
                                    children: [
                                      Text(
                                        currencyProvider.formatPrice(
                                          unitPrice,
                                          locale: Localizations.localeOf(context),
                                        ),
                                        style: AppFonts.getTextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      if (pd.originalPrice != null &&
                                          pd.originalPrice! >
                                              unitPrice) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          currencyProvider.formatPrice(
                                            pd.originalPrice!,
                                            locale: Localizations.localeOf(context),
                                          ),
                                          style: AppFonts.getTextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: ResponsiveConstants.lgPadding),

          // Selected Options (dynamic attribute header) - Use controller's selected attributes
          Consumer<DynamicVariantController>(
            builder: (context, variantController, _) {
              final pd = variantController.productDetails;
              if (pd == null) return const SizedBox.shrink();
              
              final selectedAttrValues = _getSelectedAttributeValues(
                context,
                variantController,
                pd,
              );
              
              if (selectedAttrValues.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.lgPadding,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.selected}: ',
                        style: AppFonts.getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      ...selectedAttrValues.asMap().entries.map((entry) {
                        final index = entry.key;
                        final attrText = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            left: index > 0 ? 8 : 0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              attrText,
                              style: AppFonts.getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: ResponsiveConstants.lgPadding),

          // Quantity Selector – max is available from controller (after attribute loop) minus cart
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.lgPadding,
            ),
            child: Consumer<DynamicVariantController>(
              builder: (context, variantController, _) {
                return BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    int maxAllowed = variantController.quantityAvailable;
                    if (cartState is CartLoaded &&
                        variantController.variantId.isNotEmpty) {
                      try {
                        final existingItem = cartState.cartItems.firstWhere(
                          (item) =>
                              item.product.id == variantController.variantId,
                        );
                        maxAllowed =
                            maxAllowed - existingItem.quantity;
                        if (maxAllowed < 0) maxAllowed = 0;
                      } catch (_) {}
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.quantity,
                          style: AppFonts.getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveConstants.smRadius,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? 0.3
                                      : 0.05,
                                ),
                                blurRadius:
                                    ResponsiveConstants.smElevation,
                                offset: Offset(
                                    0, ResponsiveConstants.xsSpacing),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _buildQuantityButton(
                                context,
                                icon: Icons.remove,
                                onPressed: () {
                                  context.read<ProductDetailsBloc>().add(
                                        DecrementQuantityEvent(),
                                      );
                                },
                              ),
                              Container(
                                width: ResponsiveConstants.xlDimension,
                                height: ResponsiveConstants.xlDimension,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .background,
                                  border: Border.symmetric(
                                    horizontal: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                                child:
                                    BlocBuilder<ProductDetailsBloc,
                                        ProductDetailsState>(
                                      builder: (context, state) {
                                        final qty = state
                                                is ProductDetailsLoaded
                                            ? state.quantity
                                            : 1;
                                        return Text(
                                          '$qty',
                                          style: AppFonts.getTextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        );
                                      },
                                    ),
                              ),
                              BlocBuilder<ProductDetailsBloc,
                                  ProductDetailsState>(
                                builder: (context, state) {
                                  final currentQty =
                                      state is ProductDetailsLoaded
                                          ? state.quantity
                                          : 1;
                                  final atMax = maxAllowed <= 0 ||
                                      currentQty >= maxAllowed;
                                  return _buildQuantityButton(
                                    context,
                                    icon: Icons.add,
                                    onPressed: atMax
                                        ? null
                                        : () {
                                            context
                                                .read<ProductDetailsBloc>()
                                                .add(
                                              IncrementQuantityEvent(
                                                maxAvailable: maxAllowed,
                                              ),
                                            );
                                          },
                                    enabled: !atMax,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Show remaining quantity - use DynamicVariantController for accurate quantity
          Consumer<DynamicVariantController>(
            builder: (context, variantController, _) {
              return BlocBuilder<CartBloc, CartState>(
                buildWhen: (previous, current) {
                  // Rebuild when cart changes (items added/removed)
                  return true;
                },
                builder: (context, cartState) {
                  // Get quantity from controller
                  int remainingQty = variantController.quantityAvailable;
                  
                  // Subtract what is already in the cart for this variant
                  if (cartState is CartLoaded && variantController.variantId.isNotEmpty) {
                    try {
                      final existingItem = cartState.cartItems.firstWhere(
                        (item) => item.product.id == variantController.variantId,
                      );
                      remainingQty = remainingQty - existingItem.quantity;
                      if (remainingQty < 0) remainingQty = 0;
                    } catch (_) {
                      // Item not in cart → keep full available quantity
                    }
                  }
                  
                  bool hasStockInfo = variantController.variantId.isNotEmpty;
                  
                  debugPrint('📊 AddToCartBottomSheet: Available quantity');
                  debugPrint('   Controller qty: ${variantController.quantityAvailable}');
                  debugPrint('   After cart deduction: $remainingQty');
                  debugPrint('   Variant ID: ${variantController.variantId}');
                  debugPrint('   In stock: ${variantController.inStock}');

                  // Only show stock info if low stock (≤5) or out of stock
                  if (!hasStockInfo || (remainingQty > 5 && remainingQty > 0)) {
                    return const SizedBox.shrink();
                  }
                  
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveConstants.lgPadding,
                      vertical: ResponsiveConstants.smSpacing,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: remainingQty > 0 
                              ? Colors.orange.shade600
                              : Colors.red.shade600,
                        ),
                        SizedBox(width: ResponsiveConstants.xsSpacing),
                        Text(
                          remainingQty > 0
                              ? AppLocalizations.of(context)!.availableCount(remainingQty)
                              : AppLocalizations.of(context)!.outOfStock,
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.smFontSize,
                            color: remainingQty > 0
                                ? Colors.orange.shade600
                                : Colors.red.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          SizedBox(height: ResponsiveConstants.lgSpacing),

          // Total Price
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.lgPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.total}:',
                  style: AppFonts.getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Consumer<DynamicVariantController>(
                  builder: (context, variantController, _) {
                    return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
                      builder: (context, state) {
                        final quantity = state is ProductDetailsLoaded
                            ? state.quantity
                            : 1;
                        // Use variant-specific price if available, otherwise fallback to template price
                        final pd = variantController.productDetails;
                        final unitPrice = variantController.currentPrice > 0 
                            ? variantController.currentPrice 
                            : (pd?.price ?? 0.0);
                        final totalPrice = unitPrice * quantity;
                        return Consumer<CurrencyProvider>(
                          builder: (context, currencyProvider, child) {
                            return Text(
                              currencyProvider.formatPrice(
                                totalPrice,
                                locale: Localizations.localeOf(context),
                              ),
                              style: AppFonts.getTextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveConstants.lgSpacing),

          // Add to Cart Button
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveConstants.lgPadding,
              0,
              ResponsiveConstants.lgPadding,
              ResponsiveConstants.lgPadding,
            ),
            child: SizedBox(
              width: double.infinity,
              height: ResponsiveConstants.lgButtonHeight,
              child: Consumer<DynamicVariantController>(
                builder: (context, variantController, _) {
                  return BlocBuilder<CartBloc, CartState>(
                    buildWhen: (previous, current) => true,
                    builder: (context, cartState) {
                      // Use same "remaining" logic as the stock message so button and message stay in sync
                      int remainingQty = variantController.quantityAvailable;
                      if (cartState is CartLoaded && variantController.variantId.isNotEmpty) {
                        try {
                          final existingItem = cartState.cartItems.firstWhere(
                            (item) => item.product.id == variantController.variantId,
                          );
                          remainingQty = remainingQty - existingItem.quantity;
                          if (remainingQty < 0) remainingQty = 0;
                        } catch (_) {}
                      }
                      final bool hasRemainingStock = remainingQty > 0;
                      final bool isOutOfStockForButton = !hasRemainingStock;

                      return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
                        buildWhen: (previous, current) => current is ProductDetailsLoaded,
                        builder: (context, state) {
                          final isAdding =
                                  state is ProductDetailsLoaded && state.isAdding;
                              
                              // Check if all required attributes are selected
                              final pd = variantController.productDetails;
                              if (pd == null) {
                                return const SizedBox.shrink();
                              }
                              
                              // Count how many attributes need to be selected
                              final totalAttributes = pd.variantAttributeOptions.length;
                              final selectedAttributesCount = variantController.selectedAttributes.length;
                              final bool hasAllAttributesSelected = selectedAttributesCount >= totalAttributes && variantController.variantId.isNotEmpty;
                              
                              // Out of stock = no remaining quantity (same as "Out of Stock" message below)
                              final bool canAdd = hasAllAttributesSelected && hasRemainingStock && !isAdding;

                              developer.log(
                                '🔘 Button state check -> quantityAvailable=${variantController.quantityAvailable}, '
                                'remainingQty=$remainingQty, isOutOfStock=$isOutOfStockForButton, canAdd=$canAdd, '
                                'variantId=${variantController.variantId}, hasAllSelected=$hasAllAttributesSelected '
                                '($selectedAttributesCount/$totalAttributes attributes)',
                              );
                              
                              // Determine button state and text
                              String buttonText;
                              bool buttonEnabled;
                              
                              if (!hasAllAttributesSelected) {
                                // Case: Not all attributes selected
                                buttonText = AppLocalizations.of(context)!.selectOptions;
                                buttonEnabled = false;
                              } else if (isOutOfStockForButton) {
                                // Case: All selected but out of stock (or all in cart) – match "Out of Stock" message
                                buttonText = AppLocalizations.of(context)!.outOfStock;
                                buttonEnabled = false;
                              } else {
                                // Case: All selected and has remaining stock
                                buttonText = AppLocalizations.of(context)!.addToCart;
                                buttonEnabled = canAdd;
                              }
                          
                          return ElevatedButton(
                            onPressed: buttonEnabled
                                ? () async {
                            await HapticService.heavyImpact();
                            developer.log('🔘 Add to Cart button pressed!');
                            
                            // Get the controller to extract colorId and sizeId from selectedAttributes
                            final controller = context.read<DynamicVariantController>();
                            final latestPd = controller.productDetails;
                            
                            if (latestPd == null) {
                              developer.log('⚠️ Controller has no productDetails');
                              return;
                            }
                            
                            developer.log('📱 Product ID Label: ${latestPd.id}');
                            
                            final currentState = context
                                .read<ProductDetailsBloc>()
                                .state;
                            developer.log(
                              '📱 Current bloc state: ${currentState.runtimeType}',
                            );

                            if (currentState is ProductDetailsLoaded) {
                              debugPrint('═══════════════════════════════════════════════════════');
                              debugPrint('🛒 [ADD_TO_CART_FLOW] Step 1 - Add To Cart Bottom Sheet');
                              debugPrint('   User clicked Add to Cart button');
                              debugPrint('   currentState.quantity (from ProductDetailsBloc): ${currentState.quantity}');
                              debugPrint('   Dispatching AddToCartEvent with quantity: ${currentState.quantity}');
                              debugPrint('═══════════════════════════════════════════════════════');

                              String selectedColorId = '';
                              String selectedSizeId = '';
                              
                              // Find color and size attribute IDs from variantAttributeOptions
                              int? colorAttributeId;
                              int? sizeAttributeId;
                              
                              for (final opt in latestPd.variantAttributeOptions) {
                                final attrNameLower = opt.attributeName.toLowerCase().trim();
                                final apiAttrNameLower = opt.apiAttributeName?.toLowerCase().trim() ?? '';
                                
                                if ((attrNameLower.contains('color') || 
                                     attrNameLower.contains('لون') ||
                                     attrNameLower == 'اللون' ||
                                     apiAttrNameLower.contains('color') ||
                                     apiAttrNameLower.contains('لون')) &&
                                    opt.attributeId != null && opt.attributeId!.isNotEmpty) {
                                  colorAttributeId = int.tryParse(opt.attributeId!);
                                } else if ((attrNameLower.contains('size') || 
                                           attrNameLower.contains('مقاس') ||
                                           attrNameLower == 'المقاس' ||
                                           apiAttrNameLower.contains('size') ||
                                           apiAttrNameLower.contains('مقاس')) &&
                                          opt.attributeId != null && opt.attributeId!.isNotEmpty) {
                                  sizeAttributeId = int.tryParse(opt.attributeId!);
                                }
                              }
                              
                              // Extract value_ids from controller's selectedAttributes
                              if (colorAttributeId != null && controller.selectedAttributes.containsKey(colorAttributeId)) {
                                selectedColorId = controller.selectedAttributes[colorAttributeId]!.toString();
                                developer.log('🎨 Color ID from controller: $selectedColorId (attr_id: $colorAttributeId)');
                              }
                              
                              if (sizeAttributeId != null && controller.selectedAttributes.containsKey(sizeAttributeId)) {
                                selectedSizeId = controller.selectedAttributes[sizeAttributeId]!.toString();
                                developer.log('📏 Size ID from controller: $selectedSizeId (attr_id: $sizeAttributeId)');
                              }
                              
                              // Use variantId from controller (matches UI selection) as productId for API
                              final productId = controller.variantId.isNotEmpty
                                  ? controller.variantId
                                  : latestPd.id;
                              debugPrint('🛒 [ADD_TO_CART_FLOW] AddToCartEvent: productId=$productId (from controller.variantId), colorId=$selectedColorId, sizeId=$selectedSizeId, quantity=${currentState.quantity}');

                              context.read<ProductDetailsBloc>().add(
                                AddToCartEvent(
                                  productId: productId,
                                  colorId: selectedColorId,
                                  sizeId: selectedSizeId,
                                  quantity: currentState.quantity,
                                ),
                              );

                              developer.log(
                                '📤 AddToCartEvent dispatched successfully',
                              );

                              // Show success message and close bottom sheet
                              await HapticService.success();
                              AppSnackBar.success(
                                context,
                                AppLocalizations.of(context)!.itemAddedToCart,
                                actionLabel: AppLocalizations.of(context)!.cart,
                                onAction: () async {
                                  await HapticService.buttonClick();
                                  final rootNav = NavigationService.currentState;
                                  // Use root navigator only; avoid relying on local Navigator.of(context)
                                  if (rootNav != null) {
                                    // Optionally pop current route stack until first
                                    rootNav.popUntil((route) => route.isFirst);
                                    rootNav.push(
                                      MaterialPageRoute(
                                        builder: (_) => const CartPage(),
                                      ),
                                    );
                                  }
                                },
                              );

                              // Close the bottom sheet after a short delay
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  if (context.mounted &&
                                      Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              );
                            } else {
                              developer.log(
                                '⚠️ State is not ProductDetailsLoaded: ${currentState.runtimeType}',
                              );
                            }
                          }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonEnabled
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withValues(alpha: 0.5),
                              foregroundColor: buttonEnabled
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                              disabledBackgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withValues(alpha: 0.5),
                              disabledForegroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveConstants.mdRadius,
                                ),
                              ),
                              elevation: buttonEnabled ? 0 : 0,
                              shadowColor: buttonEnabled
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.2)
                                  : Colors.transparent,
                            ),
                            child: isAdding
                                ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                                : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    !hasAllAttributesSelected || isOutOfStockForButton
                                        ? Icons.block
                                        : Icons.shopping_cart_outlined,
                                    size: 20,
                                    color: buttonEnabled
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    buttonText,
                                    style: AppFonts.getTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: buttonEnabled
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                          );
                    },
                  );
                },
              );
            },
          ),
            ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: enabled && onPressed != null ? () async {
        await HapticService.selectionClick();
        onPressed();
      } : null,
      child: Container(
        width: ResponsiveConstants.xlDimension,
        height: ResponsiveConstants.xlDimension,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: enabled 
              ? colorScheme.onSurface.withValues(alpha: 0.7)
              : colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// Helper method to find the currently selected variant.
  /// Uses value_name matching (color, size, material, height) so inStock and quantity_available
  /// match the stock badge and BLoC state.
  VariantCombination? _findSelectedVariant(ProductDetails pd) {
    try {
      developer.log('🔍 Finding selected variant for:');
      developer.log('  - selectedSize: ${pd.selectedSize}');
      developer.log('  - selectedColor: ${pd.selectedColor}');
      developer.log('  - primaryVariantLabel: ${pd.primaryVariantLabel}');

      // 1) Match by value_name (same as BLoC): all 4 attributes -> one variant -> inStock & quantity_available
      final byValueName = pd.findVariantMatchingSelectionByValueName();
      if (byValueName != null) {
        developer.log('🔍 Found variant by value_name: variantId=${byValueName.variantId}, quantityAvailable=${byValueName.quantityAvailable}');
        return byValueName;
      }

      // 2) Fallback: build selected pairs using attribute names (try multiple variations)
      final Map<String, String> selectedByAttribute = {};
      
      // Add selected size/primary variant
      if (pd.selectedSize.isNotEmpty) {
        selectedByAttribute[pd.primaryVariantLabel] = pd.selectedSize;
        selectedByAttribute['size'] = pd.selectedSize;
        selectedByAttribute['SIZE'] = pd.selectedSize;
        selectedByAttribute['المقاس'] = pd.selectedSize;
      }
      
      // Add selected color (try all possible attribute name variations)
      if (pd.selectedColor.isNotEmpty) {
        selectedByAttribute['color'] = pd.selectedColor;
        selectedByAttribute['Color'] = pd.selectedColor;
        selectedByAttribute['COLOR'] = pd.selectedColor;
        selectedByAttribute['colour'] = pd.selectedColor;
        selectedByAttribute['Colour'] = pd.selectedColor;
        selectedByAttribute['COLOUR'] = pd.selectedColor;
        selectedByAttribute['اللون'] = pd.selectedColor;
        selectedByAttribute['color name'] = pd.selectedColor;
        selectedByAttribute['Color Name'] = pd.selectedColor;
        selectedByAttribute['COLOR NAME'] = pd.selectedColor;
      }
      
      // Add selected material if available
      if (pd.selectedMaterial != null && pd.selectedMaterial!.isNotEmpty) {
        selectedByAttribute['MATERIAL NAME'] = pd.selectedMaterial!;
        selectedByAttribute['material name'] = pd.selectedMaterial!;
        selectedByAttribute['Material Name'] = pd.selectedMaterial!;
      }
      
      // Add selected heel height if available
      if (pd.selectedHeelHeightCm != null) {
        final heightStr = pd.selectedHeelHeightCm!.toStringAsFixed(1);
        selectedByAttribute['HEIGHT'] = heightStr;
        selectedByAttribute['height'] = heightStr;
        selectedByAttribute['Height'] = heightStr;
      }
      
      // Add other selected attributes from variantAttributeOptions
      for (final opt in pd.variantAttributeOptions) {
        if (opt.selectedValue.isNotEmpty) {
          selectedByAttribute[opt.attributeName] = opt.selectedValue;
          // Also add uppercase version
          selectedByAttribute[opt.attributeName.toUpperCase()] = opt.selectedValue;
        }
      }
      
      developer.log('🔍 Searching with attributes: ${selectedByAttribute.entries.map((e) => '${e.key}=${e.value}').join(', ')}');
      
      // Find matching variant - prioritize size and color, other attributes are optional
      final matching = pd.variantCombinations.where((combo) {
        // Must match size if provided
        if (pd.selectedSize.isNotEmpty) {
          bool sizeMatch = false;
          final sizeValue = combo.getAttributeValue('SIZE') ?? 
                           combo.getAttributeValue('size') ?? 
                           combo.getAttributeValue(pd.primaryVariantLabel);
          if (sizeValue != null && sizeValue.toLowerCase().trim() == pd.selectedSize.toLowerCase().trim()) {
            sizeMatch = true;
          }
          if (!sizeMatch) return false;
        }
        
        // Must match color if provided
        if (pd.selectedColor.isNotEmpty) {
          bool colorMatch = false;
          final colorValue = combo.getAttributeValue('COLOR NAME') ?? 
                            combo.getAttributeValue('color name') ?? 
                            combo.getAttributeValue('color') ?? 
                            combo.getAttributeValue('colour') ?? 
                            combo.getAttributeValue('اللون');
          if (colorValue != null && colorValue.toLowerCase().trim() == pd.selectedColor.toLowerCase().trim()) {
            colorMatch = true;
          }
          if (!colorMatch) return false;
        }
        
        // Try to match other attributes if they exist in the variant (optional)
        for (final entry in selectedByAttribute.entries) {
          // Skip size and color as we already checked them
          final keyLower = entry.key.toLowerCase();
          if (keyLower == 'size' || 
              keyLower == 'color' ||
              keyLower == 'colour' ||
              keyLower == 'color name' ||
              keyLower == 'اللون' ||
              entry.key == pd.primaryVariantLabel ||
              entry.key == 'SIZE' ||
              entry.key == 'COLOR NAME') {
            continue;
          }
          
          // For other attributes, check if they match (if present in variant)
          final v = combo.getAttributeValue(entry.key);
          if (v != null && v.toLowerCase().trim() != entry.value.toLowerCase().trim()) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      developer.log('🔍 Found ${matching.length} matching variant(s)');
      if (matching.isNotEmpty) {
        developer.log('🔍 First match: variantId=${matching.first.variantId}, quantityAvailable=${matching.first.quantityAvailable}');
        for (final attr in matching.first.attributes) {
          developer.log('  - ${attr.attributeName}: ${attr.valueName}');
        }
      }
      
      if (matching.length == 1) {
        return matching.first;
      }
      
      if (matching.length > 1) {
        developer.log('⚠️ Multiple variants matched (${matching.length}), using first one with highest stock');
        // If multiple matches, prefer the one with highest available stock
        matching.sort((a, b) {
          final qtyA = a.quantityAvailable ?? 0;
          final qtyB = b.quantityAvailable ?? 0;
          return qtyB.compareTo(qtyA); // Sort descending
        });
        developer.log('🔍 Selected variant: variantId=${matching.first.variantId}, quantityAvailable=${matching.first.quantityAvailable}');
        return matching.first;
      }
      
      // If no exact match, log for debugging
      developer.log('⚠️ No exact match found. Available variants:');
      for (final v in pd.variantCombinations.take(3)) {
        developer.log('  - variantId=${v.variantId}:');
        for (final attr in v.attributes) {
          developer.log('    ${attr.attributeName}: ${attr.valueName}');
        }
      }
      
      return null;
    } catch (e) {
      developer.log('⚠️ Error finding selected variant: $e');
      return null;
    }
  }

  /// Helper to compute the available quantity for the *current selection*,
  /// using the same loop-based stock logic we use for attributes/badge,
  /// and then subtracting any quantity already in the cart for that variant.
  int? _getAvailableQuantityForSelection(
    ProductDetails pd,
    CartState cartState,
  ) {
    try {
      VariantCombination? selectedVariant;

      // 1) Prefer the same color-based loop used for badge/attribute disabling.
      if (pd.selectedColor.isNotEmpty &&
          pd.variantCombinations.isNotEmpty) {
        selectedVariant =
            pd.getFirstInStockVariantForColor(pd.selectedColor);
      }

      // 2) Fallback: use full selection matching (size/color/material/height).
      selectedVariant ??= _findSelectedVariant(pd);

      if (selectedVariant == null ||
          selectedVariant.quantityAvailable == null) {
        return null;
      }

      int available = selectedVariant.quantityAvailable!.round();

      // Subtract what is already in the cart for this variant.
      if (cartState is CartLoaded) {
        try {
          final existingItem = cartState.cartItems.firstWhere(
            (item) => item.product.id == selectedVariant!.variantId,
          );
          available = available - existingItem.quantity;
        } catch (_) {
          // Item not in cart → keep full available quantity.
        }
      }

      return available;
    } catch (e) {
      developer.log('⚠️ Error in _getAvailableQuantityForSelection: $e');
      return null;
    }
  }

  /// Get selected attribute values as display strings from the controller
  /// Returns a list of strings like ["اللون: اخضر", "المقاس: 40", "الخامة: شمواه"]
  List<String> _getSelectedAttributeValues(
    BuildContext context,
    DynamicVariantController controller,
    ProductDetails productDetails,
  ) {
    final List<String> parts = [];
    
    if (controller.productDetails == null || controller.selectedVariant == null) return parts;
    
    final pd = controller.productDetails!;
    final selectedVariant = controller.selectedVariant!;
    
    // Get attribute values directly from the selected variant's attributes
    // This ensures we get the actual value_name (e.g., "اخضر") instead of "COLOR_ID_300"
    final Map<String, String> attributeDisplayMap = {};
    
    // Build a map of attribute names to their display names
    for (final opt in pd.variantAttributeOptions) {
      final attrDisplayName = opt.apiAttributeName?.isNotEmpty == true
          ? opt.apiAttributeName!
          : opt.attributeName;
      
      if (opt.attributeId != null && opt.attributeId!.isNotEmpty) {
        final attrId = opt.attributeId!;
        attributeDisplayMap[attrId] = attrDisplayName;
      }
    }
    
    // Extract values from the selected variant's attributes
    for (final variantAttr in selectedVariant.attributes) {
      final attrId = variantAttr.attributeId;
      final valueName = variantAttr.valueName;
      
      if (attrId == null || valueName.isEmpty) continue;
      
      // Get the display name for this attribute (localized for known attributes)
      final rawAttrName = attributeDisplayMap[attrId] ?? variantAttr.attributeName;
      final attrDisplayName = localizedAttributeLabel(context, rawAttrName);

      // For colors, try to get the localized name from ColorOption if available
      String displayValueName = valueName;
      
      // Check if this is a color attribute and try to get localized name
      final attrNameLower = variantAttr.attributeName.toLowerCase();
      if (attrNameLower.contains('color') || attrNameLower.contains('لون')) {
        // Try to find the color in ColorOption by matching value_id
        final valueId = variantAttr.valueId;
        if (valueId != null) {
          try {
            final colorOption = pd.colorOptions.firstWhere(
              (c) => c.id == valueId || c.id == valueId.toString(),
            );
            // Use displayName if available (Arabic), otherwise use name
            displayValueName = colorOption.displayName ?? colorOption.name;
          } catch (_) {
            // Color not found in ColorOption, use value_name from variant
            displayValueName = valueName;
          }
        }
      }
      
      // Skip if value name is still COLOR_ID_X format (fallback)
      if (displayValueName.startsWith('COLOR_ID_')) {
        // Try one more time to get from ColorOption by value_id
        final valueId = variantAttr.valueId;
        if (valueId != null) {
          try {
            final colorOption = pd.colorOptions.firstWhere(
              (c) {
                final cId = int.tryParse(c.id);
                final vId = int.tryParse(valueId);
                return cId != null && vId != null && cId == vId;
              },
            );
            displayValueName = colorOption.displayName ?? colorOption.name;
          } catch (_) {
            // Keep COLOR_ID_X if we can't find it
          }
        }
      }
      
      parts.add('$attrDisplayName: $displayValueName');
    }
    
    return parts;
  }
}
