import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../widgets/shipping_address_card.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/order_summary_section.dart';
import '../../domain/entities/checkout_item.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/shipping_address.dart';
import '../../domain/entities/payment_method.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../addresses/domain/entities/address.dart';
import '../../../addresses/presentation/bloc/address_bloc.dart';
import '../../../addresses/presentation/bloc/address_event.dart';
import '../../../addresses/presentation/bloc/address_state.dart';
import '../../../addresses/presentation/pages/edit_address_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/biometric_bloc.dart';
import '../../../auth/presentation/bloc/biometric_event.dart';
import '../../../auth/presentation/bloc/biometric_state.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';
import '../bloc/order_bloc.dart';
import 'al_qaseh_payment_page.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/currency_provider.dart';
import 'package:collection/collection.dart';
import '../constants/checkout_constants.dart';
import '../../../../core/services/haptic_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  
  const CheckoutPage({
    super.key,
    required this.cartItems,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<dynamic> _shippingMethods = const [];
  bool _hasShownInitialLoaded = false;
  bool _hasLoadedAddresses = false; // Flag to prevent duplicate address loading
  bool _hasLoadedShippingMethods = false; // Flag to prevent duplicate shipping loading
  DateTime? _shippingLoadStartTime; // Track when shipping loading started for timeout
  CheckoutLoaded? _lastCheckoutLoadedState; // Store last CheckoutLoaded state to prevent null issues

  void _updateCheckoutFromCart(BuildContext context, CartState cartState, CheckoutBloc checkoutBloc) {
    if (checkoutBloc.state is! CheckoutLoaded) return;
    final checkoutState = checkoutBloc.state as CheckoutLoaded;

    if (!checkoutState.useCartTotals) return;
    
    // Only update if cart items changed

    final currentItemIds = checkoutState.items.map((item) => item.cartItem.id).toSet();
    final cartItemIds = widget.cartItems.map((item) => item.id).toSet();
    if (currentItemIds.length == cartItemIds.length && 
        currentItemIds.every((id) => cartItemIds.contains(id))) {
      return;
      // Already synced, no need to update
    }
    
     final checkoutItems = widget.cartItems.map((cartItem) {
      return CheckoutItem(
        id: cartItem.id,
        cartItem: cartItem,
        isSelected: true,
      );
    }).toList();

    CheckoutSummary checkoutSummary;
    if (cartState is CartLoaded) {
      // Use real API data for pricing
      final subtotal = cartState.subtotal;
      final taxAmount = cartState.taxAmount;
      final shipping = checkoutState.summary.shipping; // Preserve shipping if set
      final discount = checkoutState.summary.discount; // Preserve discount if set
      final total = cartState.total;
      // Total Items = number of distinct line items (products), not sum of quantities
      final totalItems = cartState.uniqueItemsCount;

      checkoutSummary = CheckoutSummary(
        subtotal: subtotal,
        shipping: shipping,
        tax: taxAmount,
        discount: discount,
        total: total,
        totalItems: totalItems,
      );
    } else {
      // Fallback calculation if cart state is not loaded
    final subtotal = checkoutItems.fold<double>(
      0.0, 
      (sum, item) => sum + (item.cartItem.totalPrice * (item.isSelected ? 1 : 0))
    );
    
      final shipping = checkoutState.summary.shipping;
      final tax = subtotal * 0.08;
      final discount = checkoutState.summary.discount;
    final total = subtotal + shipping + tax - discount;
    // Total Items = number of distinct line items (products), not sum of quantities
    final totalItems = checkoutItems.where((item) => item.isSelected).length;

    checkoutSummary = CheckoutSummary(
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      discount: discount,
      total: total,
      totalItems: totalItems,
    );
    }
    
    checkoutBloc.add(UpdateCheckoutFromCart(
      items: checkoutItems,
      summary: checkoutSummary,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => sl<AddressBloc>(),
          ),
          BlocProvider(
            create: (context) {
              final cartBloc = context.read<CartBloc>();
              final cartState = cartBloc.state;
              final cartItems = cartState is CartLoaded 
                  ? cartState.cartItems 
                  : (cartState is CartUpdating 
                      ? cartState.cartItems 
                      : widget.cartItems);
              return sl<CheckoutBloc>()..add(LoadCheckout(
                cartItems: cartItems,
                cartState: cartState is CartLoaded ? cartState : null,
              ));
            },
          ),
          BlocProvider(
            create: (context) => sl<OrderBloc>(),
          ),
        ],
        child: Builder(
          builder: (providerContext) {
            return MultiBlocListener(
          listeners: [
            BlocListener<CheckoutBloc, CheckoutState>(
              listener: _onCheckoutBlocStateChanged,
            ),
            BlocListener<OrderBloc, OrderState>(
              listener: _onOrderBlocStateChanged,
            ),
                BlocListener<AddressBloc, AddressState>(
                  listener: _onAddressBlocStateChanged,
                ),
                BlocListener<CartBloc, CartState>(
                  listener: (context, cartState) {
                    // Update checkout from cart when cart state changes (for quantity updates, etc.)
                    // Only access CheckoutBloc if it's available
                    try {
                      final checkoutBloc = context.read<CheckoutBloc>();
                      final checkoutState = checkoutBloc.state;
                      if (checkoutState is CheckoutLoaded && cartState is CartLoaded) {
                        _updateCheckoutFromCart(context, cartState, checkoutBloc);
                      }
                    } catch (e) {
                      // CheckoutBloc not available yet, ignore
                      debugPrint('CheckoutBloc not available yet: $e');
                    }
                  },
                ),
              ],
              child: BlocConsumer<CheckoutBloc, CheckoutState>(
                listener: (context, state) {
                  // Store CheckoutLoaded state immediately when we get it
                  if (state is CheckoutLoaded) {
                    _lastCheckoutLoadedState = state;
                    // Mark as loaded immediately when we first get CheckoutLoaded
                    if (!_hasShownInitialLoaded) {
                      _hasShownInitialLoaded = true;
                    }
                  }
                  
                  // Handle state transitions that need side effects
                  if (state is ShippingMethodsLoading) {
                    // Track when shipping loading starts for timeout detection
                    if (_shippingLoadStartTime == null) {
                      _shippingLoadStartTime = DateTime.now();
                    }
                  }
                  
                  if (state is ShippingMethodsLoaded) {
                    _shippingMethods = state.methods;
                    _hasLoadedShippingMethods = true;
                    _shippingLoadStartTime = null; // Reset timeout tracker
                    // Preserve the last CheckoutLoaded state if previousState is null
                    if (state.previousState != null) {
                      _lastCheckoutLoadedState = state.previousState;
                    }
                  }
                  
                  // Preserve state from other transitions
                  if (state is ShippingMethodApplying && state.snapshot != null) {
                    _lastCheckoutLoadedState = state.snapshot;
                  }
                  if (state is PaymentMethodApplying && state.snapshot != null) {
                    _lastCheckoutLoadedState = state.snapshot;
                  }
                  if (state is PaymentMethodApplied && state.snapshot != null) {
                    _lastCheckoutLoadedState = state.snapshot;
                  }
                  if (state is PaymentMethodFailure && state.snapshot != null) {
                    _lastCheckoutLoadedState = state.snapshot;
                  }
                  
                  // Reset flags on error to allow retry
                  if (state is CheckoutError) {
                    // Reset shipping flags to allow retry
                    _hasLoadedShippingMethods = false;
                    _shippingLoadStartTime = null;
                  }
                },
                builder: (context, checkoutState) {
                  // Handle error state
                  if (checkoutState is CheckoutError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: ResponsiveConstants.xlIconSize,
                            color: Colors.red.shade400,
                          ),
                          SizedBox(height: ResponsiveConstants.mdSpacing),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.lgPadding),
                            child: Text(
                              checkoutState.message,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.mdFontSize,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: ResponsiveConstants.lgSpacing),
                          ElevatedButton(
                            onPressed: () {
                              final cartBloc = context.read<CartBloc>();
                              final cartState = cartBloc.state;
                              final cartItems = cartState is CartLoaded
                                  ? cartState.cartItems
                                  : (cartState is CartUpdating
                                      ? cartState.cartItems
                                      : widget.cartItems);
                              context.read<CheckoutBloc>().add(LoadCheckout(
                                cartItems: cartItems,
                                cartState: cartState is CartLoaded ? cartState : null,
                              ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CheckoutConstants.primaryColor,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: Text(AppLocalizations.of(context)!.retry),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Handle loading state - check both conditions together to avoid double rendering
                  final isLoadingPhase = checkoutState is CheckoutLoading || checkoutState is CheckoutInitial;
                  
                  // Get the current CheckoutLoaded state (use stored state if available)
                  CheckoutLoaded? currentLoadedState;
                  if (checkoutState is CheckoutLoaded) {
                    currentLoadedState = checkoutState;
                  } else if (checkoutState is ShippingMethodsLoaded) {
                    // Use previousState if available, otherwise fall back to stored state
                    currentLoadedState = checkoutState.previousState ?? _lastCheckoutLoadedState;
                  } else if (checkoutState is ShippingMethodApplying) {
                    currentLoadedState = checkoutState.snapshot;
                  } else if (checkoutState is PaymentMethodApplying) {
                    currentLoadedState = checkoutState.snapshot;
                  } else if (checkoutState is PaymentMethodApplied) {
                    currentLoadedState = checkoutState.snapshot;
                  } else if (checkoutState is PaymentMethodFailure) {
                    currentLoadedState = checkoutState.snapshot;
                  } else {
                    // For any other state, use stored state if available
                    currentLoadedState = _lastCheckoutLoadedState;
                  }
                  
                  // Show full-page shimmer ONLY before we've ever shown a loaded state.
                  // After first load, NEVER show full-page shimmer again - only show section-level loading
                  final showGlobalLoading = !_hasShownInitialLoaded &&
                      (isLoadingPhase || currentLoadedState == null);

                  if (showGlobalLoading) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Scaffold(
                      backgroundColor: colorScheme.surfaceContainerLowest,
                      appBar: _buildAppBar(context),
                      body: _buildFullPageShimmer(),
                    );
                  }

                  // Safety guard: if we've shown initial load but somehow lost the state,
                  // use stored state instead of showing shimmer again
                  if (currentLoadedState == null && _hasShownInitialLoaded && _lastCheckoutLoadedState != null) {
                    currentLoadedState = _lastCheckoutLoadedState;
                  }
                  
                  // Only show shimmer if we truly have no state (shouldn't happen after initial load)
                  if (currentLoadedState == null) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Scaffold(
                      backgroundColor: colorScheme.surfaceContainerLowest,
                      appBar: _buildAppBar(context),
                      body: _buildFullPageShimmer(),
                    );
                  }
                  final colorScheme = Theme.of(context).colorScheme;
                  return Scaffold(
                    backgroundColor: colorScheme.surfaceContainerLowest,
                    appBar: _buildAppBar(context),
                    body: BlocBuilder<CartBloc, CartState>(
                      builder: (cartContext, cartState) {
                        return BlocBuilder<AddressBloc, AddressState>(
                          builder: (addressContext, addressState) {
                            // Load addresses only once when widget first builds (not on every rebuild)
                            if (addressState is AddressInitial && !_hasLoadedAddresses) {
                              _hasLoadedAddresses = true;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && addressContext.read<AddressBloc>().state is AddressInitial) {
                                  addressContext.read<AddressBloc>().add(const LoadAddresses());
                                }
                              });
                            }
                            return _buildCheckoutContent(
                              context, 
                              addressState, 
                              cartState, 
                              currentLoadedState!,
                              checkoutState,
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: colorScheme.onSurface,
          size: ResponsiveConstants.mdIconSize,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        AppLocalizations.of(context)!.checkout,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.lgFontSize,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCheckoutContent(
    BuildContext blocContext, 
    AddressState addressState, 
    CartState cartState, 
    CheckoutLoaded checkoutState,
    CheckoutState rawCheckoutState,
  ) {
    final int? orderId = (cartState is CartLoaded && cartState.cartResponse != null)
        ? cartState.cartResponse!.orderId
        : null;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.smPadding,
        vertical: ResponsiveConstants.mdSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Card
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: checkoutState.items.isNotEmpty
                ? CompactOrderSummarySection(
                    key: const ValueKey('summary-loaded'),
                    items: checkoutState.items,
                    summary: checkoutState.summary,
                  )
                : _buildSummaryShimmer(),
          ),
          
          SizedBox(height: ResponsiveConstants.mdSpacing),
          
          Builder(
            builder: (ctx) {
              final theme = Theme.of(ctx);
              final cs = theme.colorScheme;
              final shadowAlpha = theme.brightness == Brightness.dark ? 0.2 : 0.06;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: shadowAlpha),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(blocContext, AppLocalizations.of(blocContext)!.shipping, Icons.local_shipping),
                        SizedBox(height: ResponsiveConstants.mdSpacing),
                        _buildShippingSection(blocContext, cartState, checkoutState, rawCheckoutState),
                      ],
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  Container(
                    padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: shadowAlpha),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAddressSectionHeader(blocContext),
                        SizedBox(height: ResponsiveConstants.mdSpacing),
                        _buildAddressSection(addressState, blocContext, checkoutState),
                      ],
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  Container(
                    padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: shadowAlpha),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(blocContext, AppLocalizations.of(blocContext)!.paymentMethod, Icons.payment),
                        SizedBox(height: ResponsiveConstants.mdSpacing),
                        checkoutState.paymentMethods.isEmpty
                            ? _buildPaymentShimmerList()
                            : Column(
                                children: checkoutState.paymentMethods.map((method) =>
                                  Padding(
                                    padding: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
                                    child: PaymentMethodCard(
                                      method: method,
                                      isSelected: method.id == checkoutState.selectedPaymentMethodId,
                                      onTap: () => _handlePaymentMethodSelection(blocContext, method, orderId, checkoutState),
                                    ),
                                  ),
                                ).toList(),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  _buildPlaceOrderButton(blocContext, addressState, cartState, checkoutState, orderId),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
          decoration: BoxDecoration(
            color: CheckoutConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
          ),
          child: Icon(
            icon,
            color: CheckoutConstants.primaryColor,
            size: ResponsiveConstants.mdIconSize,
          ),
        ),
        SizedBox(width: ResponsiveConstants.mdSpacing),
        Text(
          title,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
          decoration: BoxDecoration(
            color: CheckoutConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
          ),
          child: Icon(
            Icons.location_on,
            color: CheckoutConstants.primaryColor,
            size: ResponsiveConstants.mdIconSize,
          ),
        ),
        SizedBox(width: ResponsiveConstants.mdSpacing),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.shippingAddress,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.lgFontSize,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            await HapticService.buttonClick();
            context.read<CheckoutBloc>().add(const SetWaitingForNewAddress(isWaiting: true));
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AddressBloc>(),
                  child: const EditAddressPage(),
                ),
              ),
            );
            // Always refresh addresses after returning from add address page
            if (context.mounted) {
              context.read<AddressBloc>().add(const LoadAddresses());
              if (result != true) {
              // Reset flag if user cancelled
              context.read<CheckoutBloc>().add(const SetWaitingForNewAddress(isWaiting: false));
              }
            }
          },
          icon: Icon(
            Icons.add,
            size: ResponsiveConstants.smIconSize,
            color: CheckoutConstants.primaryColor,
          ),
          label: Text(
            AppLocalizations.of(context)!.addAddress,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              fontWeight: FontWeight.w600,
              color: CheckoutConstants.primaryColor,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.smPadding,
              vertical: ResponsiveConstants.xsPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection(
    AddressState addressState, 
    BuildContext blocContext,
    CheckoutLoaded checkoutState,
  ) {
    // Show loading state - address loading is handled at BlocBuilder level to avoid duplicates
    if (addressState is AddressInitial || addressState is AddressLoading) {
      return Column(
        children: [
          // Loading indicator
          Container(
            padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.smPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(CheckoutConstants.primaryColor),
                  ),
                ),
                SizedBox(width: ResponsiveConstants.smSpacing),
                Text(
                  AppLocalizations.of(blocContext)!.loading,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.smFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          _buildAddressShimmerList(),
        ],
      );
    }

    if (addressState is AddressLoading) {
      return Column(
        children: [
          // Loading indicator
          Container(
            padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.smPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(CheckoutConstants.primaryColor),
                  ),
                ),
                SizedBox(width: ResponsiveConstants.smSpacing),
                Text(
                  AppLocalizations.of(blocContext)!.loading,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.smFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          _buildAddressShimmerList(),
        ],
      );
    }

    if (addressState is AddressError) {
      return Container(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: ResponsiveConstants.lgIconSize,
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Text(
              'Failed to load addresses: ${addressState.message}',
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            ElevatedButton(
              onPressed: () => blocContext.read<AddressBloc>().add(LoadAddresses()),
              child: Text(AppLocalizations.of(blocContext)!.tryAgain),
            ),
          ],
        ),
      );
    }

    // Handle AddressSuccess state (can contain addresses after add/update)
    if (addressState is AddressSuccess && addressState.addresses != null) {
      final addresses = addressState.addresses!;
      if (addresses.isEmpty) {
        return Container(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.location_off,
                color: Colors.blue.shade600,
                size: ResponsiveConstants.lgIconSize,
              ),
              SizedBox(height: ResponsiveConstants.smSpacing),
              Text(
                AppLocalizations.of(blocContext)!.noAddressIsSetYet,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  color: Colors.blue.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveConstants.smSpacing),
              ElevatedButton(
                onPressed: () async {
                  await HapticService.buttonClick();
                  blocContext.read<CheckoutBloc>().add(const SetWaitingForNewAddress(isWaiting: true));
                  final result = await Navigator.of(blocContext).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: blocContext.read<AddressBloc>(),
                        child: const EditAddressPage(),
                      ),
                    ),
                  );
                  // Always refresh addresses after returning from add address page
                  if (blocContext.mounted) {
                    // Reset flag to allow reloading after edit/add
                    _hasLoadedAddresses = false;
                    blocContext.read<AddressBloc>().add(const LoadAddresses());
                    if (result != true) {
                      // Reset flag if user cancelled
                      blocContext.read<CheckoutBloc>().add(const SetWaitingForNewAddress(isWaiting: false));
                    }
                  }
                },
                child: Text(AppLocalizations.of(blocContext)!.addAddress),
              ),
            ],
          ),
        );
      }

      final totalAddressCount = addresses.length;
      final isOnlyAddress = totalAddressCount == 1;
      
      return Column(
        children: addresses.map((address) {
          final convertedAddress = _convertToShippingAddress(address);
          return Padding(
            padding: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
            child: _buildAddressCard(
              address, 
              convertedAddress, 
              checkoutState, 
              blocContext,
              isOnlyAddress: isOnlyAddress,
            ),
          );
        }).toList(),
      );
    }

    // Handle AddressUpdating state (optimistic update state)
    if (addressState is AddressUpdating) {
      if (addressState.addresses.isEmpty) {
        return Container(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.location_off,
                color: Colors.blue.shade600,
                size: ResponsiveConstants.lgIconSize,
              ),
              SizedBox(height: ResponsiveConstants.smSpacing),
              Text(
                AppLocalizations.of(blocContext)!.noAddressIsSetYet,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  color: Colors.blue.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveConstants.smSpacing),
              ElevatedButton(
                onPressed: () async {
                  await HapticService.buttonClick();
                  blocContext.read<CheckoutBloc>().add(const SetWaitingForNewAddress(isWaiting: true));
                  final result = await Navigator.of(blocContext).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: blocContext.read<AddressBloc>(),
                        child: const EditAddressPage(),
                      ),
                    ),
                  );
                  // Always refresh addresses after returning from add address page
                  if (blocContext.mounted) {
                    // Reset flag to allow reloading after edit/add
                    _hasLoadedAddresses = false;
                    blocContext.read<AddressBloc>().add(const LoadAddresses());
                    if (result != true) {
                      // Reset flag if user cancelled
                      blocContext.read<CheckoutBloc>().add(const SetWaitingForNewAddress(isWaiting: false));
                    }
                  }
                },
                child: Text(AppLocalizations.of(blocContext)!.addAddress),
              ),
            ],
          ),
        );
      }

      final totalAddressCount = addressState.addresses.length;
      final isOnlyAddress = totalAddressCount == 1;
      
      return Column(
        children: addressState.addresses.map((address) {
          final convertedAddress = _convertToShippingAddress(address);
          return Padding(
            padding: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
            child: _buildAddressCard(
              address, 
              convertedAddress, 
              checkoutState, 
              blocContext,
              isOnlyAddress: isOnlyAddress,
            ),
          );
        }).toList(),
      );
    }

    if (addressState is AddressesLoaded) {
      if (addressState.addresses.isEmpty) {
        return Container(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.location_off,
                color: Colors.blue.shade600,
                size: ResponsiveConstants.lgIconSize,
              ),
              SizedBox(height: ResponsiveConstants.smSpacing),
              Text(
                AppLocalizations.of(blocContext)!.noAddressIsSetYet,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  color: Colors.blue.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveConstants.smSpacing),
              ElevatedButton(
                onPressed: () async {
                  await HapticService.buttonClick();
                  blocContext.read<CheckoutBloc>().add(const SetWaitingForNewAddress(isWaiting: true));
                  final result = await Navigator.of(blocContext).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: blocContext.read<AddressBloc>(),
                        child: const EditAddressPage(),
                      ),
                    ),
                  );
                  // Always refresh addresses after returning from add address page
                  if (blocContext.mounted) {
                    // Reset flag to allow reloading after edit/add
                    _hasLoadedAddresses = false;
                    blocContext.read<AddressBloc>().add(const LoadAddresses());
                    if (result != true) {
                    // Reset flag if user cancelled
                    blocContext.read<CheckoutBloc>().add(const SetWaitingForNewAddress(isWaiting: false));
                    }
                  }
                },
                child: Text(AppLocalizations.of(blocContext)!.addAddress),
              ),
            ],
          ),
        );
      }

      // Note: Auto-selection of default address is handled in _onAddressBlocStateChanged
      // to ensure it happens when addresses are first loaded

      final totalAddressCount = addressState.addresses.length;
      final isOnlyAddress = totalAddressCount == 1;

      return Column(
        children: addressState.addresses.map((address) {
          final convertedAddress = _convertToShippingAddress(address);
          return Padding(
            padding: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
            child: _buildAddressCard(
              address, 
              convertedAddress, 
              checkoutState, 
              blocContext,
              isOnlyAddress: isOnlyAddress,
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  ShippingAddress _convertToShippingAddress(Address address) {
    // Build display phone: "+{dialCode}{nationalDigits}" when we have both parts.
    final nationalDigits = address.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final ccDigits =
        (address.phoneCountryCode ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    String displayPhone = nationalDigits;
    if (ccDigits.isNotEmpty && nationalDigits.isNotEmpty) {
      displayPhone = '+$ccDigits$nationalDigits';
    }

    return ShippingAddress(
      id: address.id,
      firstName: address.fullName.split(' ').first,
      lastName: address.fullName.split(' ').skip(1).join(' '),
      streetAddress: address.street,
      city: address.city,
      state: address.district,
      zipCode: address.zipCode,
      country: address.country,
      phone: displayPhone,
      isDefault: address.isDefault,
      provinceId: address.provinceId,
    );
  }

  // Helper method to create address card with proper tap/edit handlers
  Widget _buildAddressCard(
    Address address,
    ShippingAddress convertedAddress,
    CheckoutLoaded checkoutState,
    BuildContext blocContext, {
    bool isOnlyAddress = false,
  }) {
    final isComplete = convertedAddress.streetAddress.trim().isNotEmpty &&
        convertedAddress.provinceId != null &&
        convertedAddress.phone.trim().isNotEmpty;
    
    // If there's only one address, always treat it as selected and don't allow unselecting
    final shouldBeSelected = isOnlyAddress || address.id == checkoutState.selectedShippingAddressId;
    
    return ShippingAddressCard(
      address: convertedAddress,
      isSelected: shouldBeSelected,
      isOnlyAddress: isOnlyAddress,
      // If only one address: disable tap (always selected, can't unselect)
      // If complete: tap selects address, edit button edits
      // If incomplete: both tap and edit go to edit page
      onTap: isOnlyAddress ? null : (isComplete ? () async {
        await HapticService.buttonClick();
        // Select the address
        blocContext.read<CheckoutBloc>().add(SelectShippingAddress(addressId: address.id));
        // If user had selected Cash (or any method) without an address, apply it now
        final cartState = blocContext.read<CartBloc>().state;
        final orderId = (cartState is CartLoaded && cartState.cartResponse != null)
            ? cartState.cartResponse!.orderId
            : null;
        final paymentId = checkoutState.selectedPaymentMethodId != null
            ? int.tryParse(checkoutState.selectedPaymentMethodId!)
            : null;
        if (orderId != null && orderId > 0 && paymentId != null) {
          blocContext.read<CheckoutBloc>().add(
            ApplyPaymentMethod(orderId: orderId, paymentMethodId: paymentId),
          );
        }
        // Shipping method is not auto-selected; user must choose it explicitly.
      } : null), // Incomplete: handled by cardTapHandler in widget
      onEdit: () async {
        await HapticService.buttonClick();
        // Navigate to edit address page
        final result = await Navigator.of(blocContext).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: blocContext.read<AddressBloc>(),
              child: EditAddressPage(address: address),
            ),
          ),
        );
        // Always refresh addresses after returning from edit page
        if (blocContext.mounted) {
          // Reset flag to allow reloading after edit
          _hasLoadedAddresses = false;
          blocContext.read<AddressBloc>().add(const LoadAddresses());
        }
      },
    );
  }

  String _formatCurrency(double amount, BuildContext context) {
    final currencyProvider = context.read<CurrencyProvider>();
    return currencyProvider.formatPrice(amount, locale: Localizations.localeOf(context));
  }

  Widget _buildShippingSection(
    BuildContext blocContext,
    CartState cartState,
    CheckoutLoaded checkoutState,
    CheckoutState rawCheckoutState,
  ) {
    int? orderId;
    if (cartState is CartLoaded && cartState.cartResponse != null) {
      orderId = cartState.cartResponse!.orderId;
    }
    
    if (orderId == null || orderId == 0) {
      // Show a message instead of infinite loading
      return Container(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue.shade600,
              size: ResponsiveConstants.mdIconSize,
            ),
            SizedBox(width: ResponsiveConstants.smSpacing),
            Expanded(
              child: Text(
                AppLocalizations.of(blocContext)!.loading,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.smFontSize,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Handle different checkout states for shipping methods
    if (rawCheckoutState is ShippingMethodsLoading) {
      // Track loading start time for timeout detection
      if (_shippingLoadStartTime == null) {
        _shippingLoadStartTime = DateTime.now();
      }
          return _buildChipsShimmer();
        }
    
    if (rawCheckoutState is ShippingMethodApplying) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LinearProgressIndicator(minHeight: 2),
          SizedBox(height: ResponsiveConstants.xsSpacing),
          if (_shippingMethods.isNotEmpty)
            _buildShippingMethodList(
              _shippingMethods,
              orderId,
              blocContext,
              rawCheckoutState.snapshot,
              isApplying: true,
            )
          else
            _buildChipsShimmer(),
        ],
      );
    }
    
    if (rawCheckoutState is ShippingMethodsLoaded) {
      return _buildShippingMethodList(
        rawCheckoutState.methods, 
        orderId, 
        blocContext, 
        checkoutState,
        isApplying: false,
      );
    }
    
    // For CheckoutLoaded state, check if we need to load shipping methods
    if (rawCheckoutState is CheckoutLoaded) {
      // Check for timeout (if loading takes more than 30 seconds)
      if (_shippingLoadStartTime != null) {
        final elapsed = DateTime.now().difference(_shippingLoadStartTime!);
        if (elapsed.inSeconds > 30) {
          // Timeout occurred - reset and show error
          _shippingLoadStartTime = null;
          _hasLoadedShippingMethods = false;
          return Container(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.timer_off,
                  color: Colors.orange.shade600,
                  size: ResponsiveConstants.mdIconSize,
                ),
                SizedBox(height: ResponsiveConstants.smSpacing),
                Text(
                  'Loading shipping methods is taking longer than expected. Please try again.',
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.smFontSize,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveConstants.smSpacing),
                TextButton(
                  onPressed: () {
                    _hasLoadedShippingMethods = false;
                    _shippingLoadStartTime = null;
                    if (mounted && orderId != null) {
                      blocContext.read<CheckoutBloc>().add(LoadShippingMethods(orderId));
                    }
                  },
                  child: Text(AppLocalizations.of(blocContext)!.tryAgain),
                ),
              ],
            ),
          );
        }
      }
      
      if (_shippingMethods.isEmpty && !_hasLoadedShippingMethods) {
        // Load shipping methods if we don't have them yet (only once)
        _hasLoadedShippingMethods = true; // Set flag immediately to prevent duplicate calls
        _shippingLoadStartTime = DateTime.now(); // Track start time for timeout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && orderId != null) {
            blocContext.read<CheckoutBloc>().add(LoadShippingMethods(orderId));
          }
        });
        return _buildChipsShimmer();
      }
      
      // If we have methods, show them; otherwise show loading
      if (_shippingMethods.isNotEmpty) {
        return _buildShippingMethodList(
          _shippingMethods,
          orderId,
          blocContext,
          checkoutState,
          isApplying: false,
        );
      } else {
        // Still loading or empty - show shimmer
        return _buildChipsShimmer();
      }
    }
    
    // Fallback: show shimmer
    return _buildChipsShimmer();
  }

  Widget _buildShippingMethodList(
    List<dynamic> methods, 
    int orderId, 
    BuildContext blocContext, 
    CheckoutLoaded checkoutState, {
    bool isApplying = false,
  }) {
    if (methods.isEmpty) {
      return Container(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        ),
        child: Row(
            children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey.shade600,
              size: ResponsiveConstants.mdIconSize,
            ),
            SizedBox(width: ResponsiveConstants.smSpacing),
              Expanded(
                child: Text(
                AppLocalizations.of(blocContext)!.noProductsAvailable,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.smFontSize,
                  color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
        ),
      );
    }

    final currency = blocContext.read<CurrencyProvider>();
    final checkoutBloc = blocContext.read<CheckoutBloc>();
    final selectedShippingMethodId = checkoutState.selectedShippingMethodId;
    final summary = checkoutState.summary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: methods.map<Widget>((m) {
          final name = (m as dynamic).name ?? (m.toString());
          final id = (m as dynamic).id ?? 0;
          final price = ((m as dynamic).price ?? 0.0) as num;
        final bool isSelected = selectedShippingMethodId == id;
        
        final bool isTapDisabled = isApplying || isSelected;
        
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isTapDisabled
                ? null
                : () {
              checkoutBloc.add(SelectShippingMethod(shippingMethodId: id));
              checkoutBloc.add(const SetUseCartTotals(useCartTotals: false));
              // Optimistic UI: update summary table immediately
              final newShipping = price.toDouble();
              final newTotal = summary.subtotal + newShipping + summary.tax - summary.discount;
              final optimisticSummary = summary.copyWith(
                shipping: newShipping, 
                total: newTotal,
                totalItems: summary.totalItems, // Preserve totalItems
              );
              checkoutBloc.add(UpdateCheckoutFromCart(
                items: checkoutState.items,
                summary: optimisticSummary,
              ));
              checkoutBloc.add(ApplyShippingMethod(orderId: orderId, shippingMethodId: id));
            },
            child: Builder(
              builder: (ctx) {
                final cs = Theme.of(ctx).colorScheme;
                return Container(
                  margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
                  padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                  decoration: BoxDecoration(
                    color: isSelected ? CheckoutConstants.primaryColor : cs.surface,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                    border: Border.all(
                      color: isSelected ? CheckoutConstants.primaryColor : cs.outline.withValues(alpha: 0.5),
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isSelected ? CheckoutConstants.primaryColor : cs.shadow).withValues(alpha: isSelected ? 0.2 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? cs.onPrimary : cs.outline,
                            width: 2,
                          ),
                          color: isSelected ? cs.onPrimary : Colors.transparent,
                        ),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? CheckoutConstants.primaryColor : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveConstants.smSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.mdFontSize,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? cs.onPrimary : cs.onSurface,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(blocContext)!.shipping,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.xsFontSize,
                                color: isSelected ? cs.onPrimary.withValues(alpha: 0.9) : cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        currency.formatPrice(price.toDouble(), locale: Localizations.localeOf(blocContext)),
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.mdFontSize,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? cs.onPrimary : cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }).toList(),
    );
  }

  // Shimmers
  Widget _buildFullPageShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.smPadding,
          vertical: ResponsiveConstants.mdSpacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Shimmer
            _buildSummaryShimmer(),
            
            SizedBox(height: ResponsiveConstants.mdSpacing),
            
            // Shipping Method Shimmer Card
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header shimmer
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                        ),
                      ),
                      SizedBox(width: ResponsiveConstants.mdSpacing),
                      Container(
                        width: 100,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  _buildChipsShimmer(),
                ],
              ),
            ),
            
            SizedBox(height: ResponsiveConstants.mdSpacing),
            
            // Shipping Address Shimmer Card
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header shimmer
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                        ),
                      ),
                      SizedBox(width: ResponsiveConstants.mdSpacing),
                      Expanded(
                        child: Container(
                          width: 120,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  _buildAddressShimmerList(),
                ],
              ),
            ),
            
            SizedBox(height: ResponsiveConstants.mdSpacing),
            
            // Payment Method Shimmer Card
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header shimmer
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                        ),
                      ),
                      SizedBox(width: ResponsiveConstants.mdSpacing),
                      Container(
                        width: 120,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  _buildPaymentShimmerList(),
                ],
              ),
            ),
            
            SizedBox(height: ResponsiveConstants.mdSpacing),
            
            // Place Order Button Shimmer
            Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryShimmer() {
    return Container(
      key: const ValueKey('summary-shimmer'),
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          // Items shimmer
          ...List.generate(2, (index) => Padding(
          padding: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                  ),
                ),
                SizedBox(width: ResponsiveConstants.mdSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
            width: double.infinity,
                        height: 14,
            decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          )),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Divider(color: Colors.grey.shade200),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          // Summary rows shimmer
          ...List.generate(3, (index) => Padding(
            padding: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildChipsShimmer() {
    return Wrap(
      spacing: 8,
      children: List.generate(3, (index) => Container(
        width: 100,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      )),
    );
  }

  Widget _buildAddressShimmerList() {
    return Column(
      children: List.generate(1, (index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
              // Radio button shimmer
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
            SizedBox(width: ResponsiveConstants.mdSpacing),
              // Address details shimmer
              Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    // Title shimmer
                    Container(
                      height: 16.h,
                      width: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Address line 1 shimmer
                    Container(
                      height: 12.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // Address line 2 shimmer
                    Container(
                      height: 12.h,
                      width: 180.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // Phone shimmer
                    Container(
                      height: 12.h,
                      width: 140.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
              ],
                ),
              ),
          ],
          ),
        ),
      )),
    );
  }

  Widget _buildPaymentShimmerList() {
    return Column(
      children: List.generate(2, (index) => Container(
        margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(width: 36, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            SizedBox(width: ResponsiveConstants.mdSpacing),
            Expanded(child: Container(height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)))),
          ],
        ),
      )),
    );
  }

  Widget _buildPlaceOrderButton(
    BuildContext blocContext, 
    AddressState addressState, 
    CartState cartState, 
    CheckoutLoaded checkoutState, 
    int? orderId,
  ) {
    if (checkoutState.paymentMethods.isEmpty || checkoutState.selectedPaymentMethodId == null) {
      return SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            elevation: 0,
          ),
          child: Text(
            AppLocalizations.of(context)!.loading,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // Ensure selected address has all required details (phone + location fields)
    bool hasValidPhone = false;
    bool hasCompleteAddressDetails = false;
    Address? selectedAddressForValidation;
    
    // Get addresses from either AddressesLoaded or AddressSuccess state
    List<Address>? addresses;
    if (addressState is AddressesLoaded) {
      addresses = addressState.addresses;
    } else if (addressState is AddressSuccess && addressState.addresses != null) {
      addresses = addressState.addresses;
    }
    
    if (addresses != null &&
        addresses.isNotEmpty &&
        checkoutState.selectedShippingAddressId != null) {
      final selectedAddress = addresses
              .where((address) => address.id == checkoutState.selectedShippingAddressId)
              .firstOrNull ??
          addresses.first;
      selectedAddressForValidation = selectedAddress;
      hasValidPhone = selectedAddress.phone.trim().isNotEmpty;

      // Consider address "complete" only if main required fields are filled:
      // street name, province, and phone number
      final hasStreet = selectedAddress.street.trim().isNotEmpty;
      final hasProvince = selectedAddress.provinceId != null;

      hasCompleteAddressDetails = hasStreet && hasProvince && hasValidPhone;
    }

    // Comprehensive validation: ensure all required data is selected before allowing order placement
    final hasAddressesLoaded = addressState is AddressesLoaded || 
                               (addressState is AddressSuccess && addressState.addresses != null);
    final addressesCount = addresses?.length ?? 0;
    
    final canPlaceOrder = checkoutState.items.isNotEmpty &&
        checkoutState.selectedShippingAddressId != null &&
        checkoutState.selectedPaymentMethodId != null &&
        checkoutState.selectedShippingMethodId != null &&
        hasAddressesLoaded &&
        addressesCount > 0 &&
        hasValidPhone &&
        hasCompleteAddressDetails &&
        !checkoutState.isApplyingPaymentMethod &&
        orderId != null &&
        orderId > 0 &&
        checkoutState.paymentMethods.isNotEmpty; // Ensure payment methods are loaded

    // Debug logging for validation
    if (!canPlaceOrder) {
      debugPrint('🚫 Place Order Button Disabled:');
      debugPrint('   - Items: ${checkoutState.items.isNotEmpty}');
      debugPrint('   - Address Selected: ${checkoutState.selectedShippingAddressId != null} (ID: ${checkoutState.selectedShippingAddressId})');
      debugPrint('   - Payment Method Selected: ${checkoutState.selectedPaymentMethodId != null} (ID: ${checkoutState.selectedPaymentMethodId})');
      debugPrint('   - Shipping Method Selected: ${checkoutState.selectedShippingMethodId != null} (ID: ${checkoutState.selectedShippingMethodId})');
      debugPrint('   - Addresses Loaded: $hasAddressesLoaded');
      debugPrint('   - Addresses Count: $addressesCount');
      debugPrint('   - Has Valid Phone: $hasValidPhone');
      debugPrint('   - Has Complete Address Details: $hasCompleteAddressDetails');
      debugPrint('   - Order ID: $orderId');
      debugPrint('   - Payment Methods Count: ${checkoutState.paymentMethods.length}');
    }

    return SafeArea(
      top: false,
      left: false,
      right: false,
      // Ensure the button sits above system UI (gesture bar / home indicator)
      // while keeping the existing layout spacing consistent.
      minimum: EdgeInsets.only(
        bottom: ResponsiveConstants.smSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: canPlaceOrder ? () async {
          // Get addresses from either AddressesLoaded or AddressSuccess state
          List<Address>? addressesList;
          if (addressState is AddressesLoaded) {
            addressesList = addressState.addresses;
          } else if (addressState is AddressSuccess && addressState.addresses != null) {
            addressesList = addressState.addresses;
          }
          
          if (addressesList == null || addressesList.isEmpty) return;
          
          final int? confirmedOrderId = orderId;
          if (confirmedOrderId == null) return;
          final selectedAddress = addressesList.where((address) => address.id == checkoutState.selectedShippingAddressId).firstOrNull ?? addressesList.first;

          // Extra biometric auth if enabled
          try {
            final biometricBloc = blocContext.read<BiometricBloc>();
            biometricBloc.add(GetBiometricSettings());
            await Future.delayed(const Duration(milliseconds: 50));
            final s = biometricBloc.state;
            bool needsAuth = false;
            if (s is BiometricSettingsLoaded) {
              needsAuth = s.settings.isEnabled && s.settings.isAvailable;
            } else if (s is BiometricAvailable) {
              needsAuth = s.isAvailable;
            }
            if (needsAuth) {
              biometricBloc.add(AuthenticateWithBiometric());
              // Wait briefly for success state; in production, listen via BlocListener
              await Future.delayed(const Duration(milliseconds: 300));
              if (biometricBloc.state is BiometricAuthenticationSuccess) {
                _submitOrder(
                  blocContext: blocContext,
                  orderId: confirmedOrderId,
                  selectedAddress: selectedAddress,
                  checkoutState: checkoutState,
                );
              }
              return;
            }
          } catch (_) {}

          _submitOrder(
            blocContext: blocContext,
            orderId: confirmedOrderId,
            selectedAddress: selectedAddress,
            checkoutState: checkoutState,
          );
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canPlaceOrder ? CheckoutConstants.primaryColor : Theme.of(blocContext).colorScheme.surfaceContainerHighest,
          foregroundColor: Theme.of(blocContext).colorScheme.onPrimary,
          disabledBackgroundColor: Theme.of(blocContext).colorScheme.surfaceContainerHighest,
          disabledForegroundColor: Theme.of(blocContext).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 0,
        ),
        child: Text(
          canPlaceOrder
              ? '${AppLocalizations.of(blocContext)!.placeOrder} - ${_formatCurrency(checkoutState.summary.total, blocContext)}'
              : AppLocalizations.of(blocContext)!.placeOrder,
          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
          ),
          if (!canPlaceOrder &&
              selectedAddressForValidation != null &&
              !hasCompleteAddressDetails &&
              addressState is AddressesLoaded)
            Padding(
              padding: EdgeInsets.only(
                top: ResponsiveConstants.xsSpacing,
              ),
              child: Text(
                // If you have a specific localization key for incomplete address, use it here.
                // For now, use a clear inline message in English.
                'Please complete your shipping address details (province, street name, phone number) before placing your order.',
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.smFontSize,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  void _submitOrder({
    required BuildContext blocContext,
    required int orderId,
    required Address selectedAddress,
    required CheckoutLoaded checkoutState,
  }) {
    // Hard guard: don't allow checkout if selected address has no phone
    if (selectedAddress.phone.trim().isEmpty) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(blocContext)!.pleaseEnterYourPhoneNumber,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if payment method is Al Qaseh
    final selectedPaymentMethod = checkoutState.paymentMethods.firstWhereOrNull(
      (method) => method.id == checkoutState.selectedPaymentMethodId,
    );
    
    // Detect Al Qaseh by type or URL
    final isAlQaseh = selectedPaymentMethod?.type == PaymentType.alQaseh ||
        (selectedPaymentMethod?.paymentUrl != null && 
         selectedPaymentMethod!.paymentUrl!.toLowerCase().contains('alqaseh'));
    
    debugPrint('🔄 Submitting order');
    debugPrint('   Order ID: $orderId');
    debugPrint('   Payment Method: ${selectedPaymentMethod?.name}');
    debugPrint('   Payment Type: ${selectedPaymentMethod?.type}');
    debugPrint('   Payment URL: ${selectedPaymentMethod?.paymentUrl}');
    debugPrint('   Is Al Qaseh: $isAlQaseh');
    
    if (isAlQaseh) {
      // For Al Qaseh: Create payment first, then place order after payment success
      debugPrint('✅ Al Qaseh payment - Creating payment URL first...');
      blocContext.read<OrderBloc>().add(
        CreateAlQasehPaymentRequested(
          orderId: orderId,
          addressId: selectedAddress.id,
        ),
      );
    } else {
      // For other payment methods: Place order immediately
      debugPrint('✅ Non-Al Qaseh payment - Placing order immediately...');
      blocContext.read<OrderBloc>().add(
        PlaceOrderRequested(
          orderId: orderId,
          addressId: selectedAddress.id,
        ),
      );
    }
  }

  void _showProcessingDialog(BuildContext context) {
    final checkoutBloc = context.read<CheckoutBloc>();
    if (checkoutBloc.state is CheckoutLoaded) {
      final state = checkoutBloc.state as CheckoutLoaded;
      if (state.isProcessingDialogVisible) return;
    }
    checkoutBloc.add(const SetProcessingDialogVisible(isVisible: true));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.processingOrder,
          style: AppFonts.getTextStyle(fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.loading),
          ],
        ),
      ),
    ).then((_) {
      checkoutBloc.add(const SetProcessingDialogVisible(isVisible: false));
    });
  }

  void _dismissProcessingDialog(BuildContext context) {
    // Always try to dismiss the dialog if it's showing, regardless of state flag
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    // Update the state flag
    final checkoutBloc = context.read<CheckoutBloc>();
    if (checkoutBloc.state is CheckoutLoaded) {
      final state = checkoutBloc.state as CheckoutLoaded;
      if (state.isProcessingDialogVisible) {
        checkoutBloc.add(const SetProcessingDialogVisible(isVisible: false));
      }
    }
  }

  void _showSuccessDialog(String orderReference, {int? orderId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) {
        final loc = AppLocalizations.of(dialogContext)!;
        final screenWidth = MediaQuery.of(dialogContext).size.width;
        final screenHeight = MediaQuery.of(dialogContext).size.height;
        final isSmallScreen = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 900;
        
        // Responsive dimensions
        final dialogWidth = isSmallScreen 
            ? screenWidth * 0.9 
            : isTablet 
                ? screenWidth * 0.7 
                : 500.0;
        final iconSize = isSmallScreen ? 80.0 : 100.0;
        final iconContainerSize = isSmallScreen ? 120.0 : 140.0;
        
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 24,
            vertical: 24,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: dialogWidth,
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.85,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Animated success icon with gradient background
                      Container(
                        width: iconContainerSize,
                        height: iconContainerSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              CheckoutConstants.primaryColor.withOpacity(0.15),
                              CheckoutConstants.primaryColor.withOpacity(0.08),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CheckoutConstants.primaryColor.withOpacity(0.12),
                              border: Border.all(
                                color: CheckoutConstants.primaryColor.withOpacity(0.3),
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: CheckoutConstants.primaryColor,
                              size: iconSize * 0.6,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      
                      // Title
                      Text(
                        loc.orderPlacedSuccessfully,
                        textAlign: TextAlign.center,
                        style: AppFonts.getTextStyle(
                          fontSize: isSmallScreen 
                              ? ResponsiveConstants.lgFontSize 
                              : ResponsiveConstants.xlFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      
                      // Order ID Card - Enhanced design
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              CheckoutConstants.primaryColor.withOpacity(0.08),
                              CheckoutConstants.primaryColor.withOpacity(0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: CheckoutConstants.primaryColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: isSmallScreen ? 20 : 24,
                                  color: CheckoutConstants.primaryColor,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  loc.orderId,
                                  style: AppFonts.getTextStyle(
                                    fontSize: isSmallScreen 
                                        ? ResponsiveConstants.smFontSize 
                                        : ResponsiveConstants.mdFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: CheckoutConstants.primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: SelectableText(
                                _getDisplayOrderNumber(orderReference, orderId),
                                textAlign: TextAlign.center,
                                style: AppFonts.getTextStyle(
                                  fontSize: isSmallScreen 
                                      ? ResponsiveConstants.mdFontSize 
                                      : ResponsiveConstants.lgFontSize - 1,
                                  fontWeight: FontWeight.w700,
                                  color: CheckoutConstants.primaryColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 28 : 36),
                      
                      // Action Button - Enhanced with icon
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 52 : 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            Navigator.of(dialogContext).pushNamedAndRemoveUntil(
                              '/main',
                              (route) => false,
                            );
                          },
                          icon: Icon(
                            Icons.shopping_bag_outlined,
                            size: isSmallScreen ? 20 : 22,
                          ),
                          label: Text(
                            loc.continueShopping,
                            style: AppFonts.getTextStyle(
                              fontSize: isSmallScreen 
                                  ? ResponsiveConstants.mdFontSize 
                                  : ResponsiveConstants.lgFontSize - 1,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CheckoutConstants.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePaymentMethodSelection(
    BuildContext blocContext, 
    PaymentMethod method, 
    int? orderId, 
    CheckoutLoaded checkoutState,
  ) async {
    // Update selection immediately so UI switches (e.g. Al Qaseh -> Cash) without waiting for API
    blocContext.read<CheckoutBloc>().add(SelectPaymentMethod(methodId: method.id));

    final parsedId = int.tryParse(method.id);
    if (orderId == null || orderId == 0 || parsedId == null) {
      return;
    }

    // For Cash (COD) with no address, only update UI; apply to order when user selects address later
    final isCashNoAddress = method.type == PaymentType.cashOnDelivery &&
        checkoutState.selectedShippingAddressId == null;
    if (isCashNoAddress) {
      return;
    }

    blocContext.read<CheckoutBloc>().add(
          ApplyPaymentMethod(orderId: orderId, paymentMethodId: parsedId),
        );
  }

  String _getDisplayOrderNumber(String orderReference, int? orderId) {
    final trimmedRef = orderReference.trim();
    
    // Check if orderReference looks like a valid order number
    // (not a success message or empty)
    if (trimmedRef.isNotEmpty) {
      final lowerRef = trimmedRef.toLowerCase();
      final isSuccessMessage = lowerRef.contains('successfully') ||
                               lowerRef.contains('placed') ||
                               lowerRef.contains('confirm') ||
                               lowerRef.contains('تم تأكيد');
      
      if (!isSuccessMessage) {
        // Remove transaction ID if present
        String cleanedRef = trimmedRef;
        
        // 1. If there's a pipe separator (|), take only the part before it (order number)
        if (cleanedRef.contains('|')) {
          cleanedRef = cleanedRef.split('|').first.trim();
        }
        
        // 2. Extract order number pattern (S followed by digits, e.g., S00129)
        final orderNumberPattern = RegExp(r'S\d+', caseSensitive: false);
        final match = orderNumberPattern.firstMatch(cleanedRef);
        if (match != null) {
          return match.group(0)!.toUpperCase();
        }
        
        // 3. If no order number pattern found, try to remove transaction ID patterns
        // Transaction IDs are typically very long numeric strings (15+ digits)
        cleanedRef = cleanedRef.replaceAll(RegExp(r'\b\d{15,}\b'), '').trim();
        
        // 4. Remove "transaction_id" or "transaction" text patterns
        cleanedRef = cleanedRef
            .replaceAll(RegExp(r'(?i)\s*transaction[_\s]?id[:\s]*\d*', multiLine: true), '')
            .replaceAll(RegExp(r'(?i)\s*trans[_\s]?id[:\s]*\d*', multiLine: true), '')
            .trim();
        
        // 5. Clean up any double spaces or trailing separators
        cleanedRef = cleanedRef
            .replaceAll(RegExp(r'\s+'), ' ')
            .replaceAll(RegExp(r'[|,;:]\s*$'), '')
            .trim();
        
        // Return cleaned reference if it's not empty
        if (cleanedRef.isNotEmpty) {
          return cleanedRef;
        }
      }
    }
    
    // Fallback to order ID if available
    if (orderId != null && orderId > 0) {
      return 'S${orderId.toString().padLeft(5, '0')}';
    }
    
    // Last resort: return empty or placeholder
    return trimmedRef.isNotEmpty ? trimmedRef : '---';
  }

  void _onAddressBlocStateChanged(BuildContext context, AddressState state) {
    if (!mounted) return;
    final checkoutBloc = context.read<CheckoutBloc>();
    final checkoutState = checkoutBloc.state;
    
    if (checkoutState is! CheckoutLoaded) return;

    // Reset loading flag when addresses are successfully loaded
    if (state is AddressesLoaded) {
      _hasLoadedAddresses = true; // Mark as loaded to prevent re-loading
      
      // Always update shipping addresses when AddressesLoaded is emitted
      // Convert Address entities to ShippingAddress entities
      final shippingAddresses = state.addresses.map((address) {
        return _convertToShippingAddress(address);
      }).toList();
      
      // Update checkout bloc with new addresses
      checkoutBloc.add(UpdateShippingAddresses(addresses: shippingAddresses));
      
      // Auto-select default address if none is selected (both for initial load and after adding new address)
      if (state.addresses.isNotEmpty) {
        // Check if we need to auto-select (either no selection, waiting for new address, or only one address)
        final isOnlyAddress = state.addresses.length == 1;
        final needsAutoSelect = checkoutState.selectedShippingAddressId == null || 
                                checkoutState.isWaitingForNewAddress ||
                                isOnlyAddress;
        
        if (needsAutoSelect) {
          Address addressToSelect;
          
          // If waiting for new address, always select the most recently added address (last in list)
          if (checkoutState.isWaitingForNewAddress) {
            addressToSelect = state.addresses.last;
            debugPrint('🔄 Selecting newly added address from AddressesLoaded: ${addressToSelect.id} (${addressToSelect.city})');
          } else {
            // Otherwise, find the default address, or use the first one if no default exists
            final defaultAddresses = state.addresses.where((a) => a.isDefault).toList();
            if (defaultAddresses.isNotEmpty) {
              addressToSelect = defaultAddresses.first;
            } else {
              // If no default, select the first address
              addressToSelect = state.addresses.first;
            }
          }
          
          // Select immediately - the CheckoutBloc state listener will handle it if UpdateShippingAddresses hasn't processed yet
          debugPrint('🔄 Auto-selecting address: ${addressToSelect.id} (${addressToSelect.city})${isOnlyAddress ? ' [Only address - always selected]' : ''}');
          checkoutBloc.add(SelectShippingAddress(addressId: addressToSelect.id));
          if (checkoutState.isWaitingForNewAddress) {
            checkoutBloc.add(const SetWaitingForNewAddress(isWaiting: false));
          }
        }
      }
    } else if (state is AddressSuccess && state.addresses != null && state.addresses!.isNotEmpty) {
      // Handle AddressSuccess state with addresses
      final shippingAddresses = state.addresses!.map((address) {
        return _convertToShippingAddress(address);
      }).toList();
      
      // Update checkout bloc with new addresses
      checkoutBloc.add(UpdateShippingAddresses(addresses: shippingAddresses));
      
      // Handle auto-selection after adding a new address
      final isOnlyAddress = state.addresses!.length == 1;
      if (checkoutState.isWaitingForNewAddress || checkoutState.selectedShippingAddressId == null || isOnlyAddress) {
        Address addressToSelect;
        
        // If waiting for new address, always select the most recently added address (last in list)
        if (checkoutState.isWaitingForNewAddress) {
          addressToSelect = state.addresses!.last;
          debugPrint('🔄 Selecting newly added address: ${addressToSelect.id} (${addressToSelect.city})');
        } else {
          // Otherwise, try to find the default address first
          final defaultAddresses = state.addresses!.where((a) => a.isDefault).toList();
          if (defaultAddresses.isNotEmpty) {
            addressToSelect = defaultAddresses.first;
          } else {
            // If no default, select the last address (most recently added)
            addressToSelect = state.addresses!.last;
          }
        }
        
        // Use a small delay to ensure UpdateShippingAddresses is processed first
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            debugPrint('🔄 Auto-selecting address after add: ${addressToSelect.id} (${addressToSelect.city})${isOnlyAddress ? ' [Only address - always selected]' : ''}');
            checkoutBloc.add(SelectShippingAddress(addressId: addressToSelect.id));
            if (checkoutState.isWaitingForNewAddress) {
              checkoutBloc.add(const SetWaitingForNewAddress(isWaiting: false));
            }
          }
        });
      }
    } else if (state is AddressError && checkoutState.isWaitingForNewAddress) {
      // Reset flag on error
      checkoutBloc.add(const SetWaitingForNewAddress(isWaiting: false));
    }
  }

  void _onCheckoutBlocStateChanged(BuildContext context, CheckoutState state) {
    if (!mounted) return;

    if (state is CheckoutError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      return;
    }

    if (state is PaymentMethodApplied) {
      // Payment method applied successfully - no need to show snackbar
      return;
    }

    if (state is PaymentMethodFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      return;
    }

    // Auto-select default address when addresses are updated and none is selected
    if (state is CheckoutLoaded) {
      final isOnlyAddress = state.shippingAddresses.length == 1;
      // Auto-select if we have addresses but no selection, OR if there's only one address
      if (state.shippingAddresses.isNotEmpty && 
          (state.selectedShippingAddressId == null || isOnlyAddress)) {
        // Find the default address, or use the first one if no default exists
        final defaultAddresses = state.shippingAddresses.where((a) => a.isDefault).toList();
        final addressToSelect = defaultAddresses.isNotEmpty 
            ? defaultAddresses.first 
            : state.shippingAddresses.first;
        
        // Auto-select the address immediately
        final checkoutBloc = context.read<CheckoutBloc>();
        debugPrint('🔄 Auto-selecting address from CheckoutBloc state: ${addressToSelect.id} (${addressToSelect.city})${isOnlyAddress ? ' [Only address - always selected]' : ''}');
        checkoutBloc.add(SelectShippingAddress(addressId: addressToSelect.id));
      }
    }
  }

  void _onOrderBlocStateChanged(BuildContext context, OrderState state) {
    if (!mounted) return;

    if (state is OrderSubmitting) {
      _showProcessingDialog(context);
      return;
    }

    if (state is OrderSuccess) {
      _dismissProcessingDialog(context);
      
      // For non-Al Qaseh payments, order is already placed
      // Cart is already cleared in OrderBloc for non-Al Qaseh payments
      debugPrint('✅ Order placed successfully - Showing success dialog');
      debugPrint('   Order Reference: ${state.orderReference}');
      
      // Refresh cart state to reflect empty cart
      context.read<CartBloc>().add(const RefreshCart());
      
      // Clear shipping methods
      _shippingMethods = const [];
      
      // Show success dialog first, then navigate away
      _showSuccessDialog(state.orderReference, orderId: state.orderId);
      return;
    }

    if (state is AlQasehPaymentCreating) {
      // Show loading dialog for payment creation
      _showProcessingDialog(context);
      return;
    }

    if (state is AlQasehPaymentCreated) {
      _dismissProcessingDialog(context);
      debugPrint('✅ AlQasehPaymentCreated - Opening webview');
      debugPrint('   Payment URL: ${state.paymentUrl}');
      debugPrint('   Order ID: ${state.orderId}');
      debugPrint('   Address ID: ${state.addressId}');
      
      // Get OrderBloc from current context before navigating
      final orderBloc = context.read<OrderBloc>();
      
      // Open payment webview
      _openAlQasehPaymentPage(
        context: context,
        paymentUrl: state.paymentUrl,
        orderId: state.orderId,
        addressId: state.addressId,
        orderBloc: orderBloc,
      );
      return;
    }

    if (state is AlQasehPaymentFailure) {
      _dismissProcessingDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (state is AlQasehPaymentSuccess) {
      // Payment successful - now clear UI and show success
      _dismissProcessingDialog(context);
      
      // Refresh cart state to reflect empty cart
      context.read<CartBloc>().add(const RefreshCart());
      
      // Clear shipping methods
      _shippingMethods = const [];
      
      // Show success dialog first, then navigate away
      _showSuccessDialog(state.orderReference);
      return;
    }

    if (state is OrderFailure) {
      _dismissProcessingDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  void _openAlQasehPaymentPage({
    required BuildContext context,
    required String paymentUrl,
    required int orderId,
    required String addressId,
    required OrderBloc orderBloc,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (paymentContext) => AlQasehPaymentPage(
          paymentUrl: paymentUrl,
          orderReference: '', // Not needed anymore, but keeping for compatibility
          onPaymentComplete: (success, orderRef) {
            // Notify OrderBloc about payment completion
            // This will handle order placement and cart clearing
            orderBloc.add(AlQasehPaymentCompleted(
              orderId: orderId,
              addressId: addressId,
              success: success,
            ));
            
           
          },
        ),
      ),
    );
  }
}
