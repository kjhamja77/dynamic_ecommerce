import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary.dart';
import '../widgets/empty_cart.dart';
import '../widgets/cart_shimmer_loading.dart';
import '../../domain/entities/cart_item.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class CartPage extends StatefulWidget {
  final Function(int)? onTabChanged;
  
  const CartPage({super.key, this.onTabChanged});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _removingItems = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Always reload cart when page is opened so we get fresh data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CartBloc>().add(const LoadCart());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload cart when app becomes active (user returns from background)
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<CartBloc>().add(const LoadCart());
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  void _markItemAsRemoving(String cartItemId) {
    setState(() {
      _removingItems[cartItemId] = true;
    });
  }

  Future<void> _onRefreshCart() async {
    final bloc = context.read<CartBloc>();
    bloc.add(const LoadCart());
    await bloc.stream.where((CartState s) =>
        s is CartLoaded || s is CartError || s is CartStockError).first;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.shoppingCart,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.lgFontSize,
          fontWeight: FontWeight.w600,
          color: colorScheme.onBackground,
        ),
      ),
      backgroundColor: colorScheme.background,
      elevation: 0,
      iconTheme: IconThemeData(color: colorScheme.onBackground),
      centerTitle: true,
      actions: [
        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoaded && state.cartItems.isNotEmpty) {
              return IconButton(
                onPressed: () async {
                  await HapticService.buttonClick();
                  _showClearCartDialog(context);
                },
                icon: Icon(
                  Icons.delete_sweep_outlined,
                  color: colorScheme.error,
                  size: ResponsiveConstants.mdIconSize,
                ),
                tooltip: AppLocalizations.of(context)!.clearCart,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartStockError) {
          _showStockErrorSnackbar(state.message);
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartInitial) {
            // Show loading; initState already triggered LoadCart once.
            return _buildLoadingState();
          }

          if (state is CartLoading) {
            return _buildLoadingState();
          }

          if (state is CartError) {
            return _buildErrorState(state.message);
          }

          // Handle CartStockError as CartLoaded (snackbar already shown in listener)
          if (state is CartStockError) {
            final items = state.cartItems;
            if (items.isEmpty) {
              return _buildEmptyCartWithRefresh();
            }
            // Convert to CartLoaded for rendering
            final loaded = CartLoaded(state.cartItems, cartResponse: state.cartResponse);
            return _buildCartContent(loaded);
          }

          if (state is CartLoaded) {
            final items = state.cartItems;
            if (items.isEmpty) {
              return _buildEmptyCartWithRefresh();
            }
            return _buildCartContent(state);
          }

          if (state is CartUpdating) {
            final items = state.cartItems;
            if (items.isEmpty) {
              return _buildEmptyCartWithRefresh();
            }
            final loaded = CartLoaded(state.cartItems, cartResponse: state.cartResponse);
            return _buildCartContent(loaded);
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const CartShimmerLoading();
  }

  Widget _buildEmptyCartWithRefresh() {
    return RefreshIndicator(
      onRefresh: _onRefreshCart,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              (MediaQuery.of(context).padding.top + kToolbarHeight),
          child: EmptyCart(
            onTabChanged: widget.onTabChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveConstants.xlIconSize,
            color: colorScheme.error,
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Text(
            AppLocalizations.of(context)!.errorLoadingCart,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.mdFontSize,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          Text(
            message,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.lgSpacing),
          _buildRetryButton(),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ElevatedButton(
      onPressed: () async {
        await HapticService.buttonClick();
        context.read<CartBloc>().add(const LoadCart());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.lgPadding,
          vertical: ResponsiveConstants.mdPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        ),
      ),
      child: Text(
        AppLocalizations.of(context)!.retry,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.mdFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCartContent(CartLoaded state) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefreshCart,
            child: _buildCartItemsList(state.cartItems),
          ),
        ),
        CartSummary(cartItems: state.cartItems),
      ],
    );
  }

  Widget _buildCartItemsList(List<CartItem> cartItems) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = cartItems[index];
        final isRemoving = _removingItems[cartItem.id] ?? false;
        
        return _buildAnimatedCartItem(cartItem, isRemoving);
      },
    );
  }

  Widget _buildAnimatedCartItem(CartItem cartItem, bool isRemoving) {
    return AnimatedSlide(
      offset: isRemoving ? const Offset(1.0, 0.0) : Offset.zero,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: isRemoving ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: Padding(
          padding: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
          child: CartItemCard(
            cartItem: cartItem,
            onRemove: () => _markItemAsRemoving(cartItem.id),
          ),
        ),
      ),
    );
  }

  void _showStockErrorSnackbar(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    final localizedMessage = _localizeStockErrorMessage(message);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            localizedMessage,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              color: colorScheme.onError,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2200),
        ),
      );
  }

  String _localizeStockErrorMessage(String message) {
    final normalized = message.trim();
    if (normalized.isEmpty) return message;

    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    if (localeCode != 'ar') return message;

    final lower = normalized.toLowerCase();
    if (lower.contains('out of stock') ||
        lower.contains('cannot be added to your cart')) {
      return 'هذا المنتج غير متوفر حاليا ولا يمكن زيادة الكمية في السلة.';
    }
    if (lower.contains('only') &&
        lower.contains('item') &&
        lower.contains('available')) {
      return 'الكمية المطلوبة غير متوفرة بالكامل. يرجى تقليل الكمية.';
    }
    if (lower.contains('quantity exceeds') || lower.contains('exceed')) {
      return 'الكمية المطلوبة أكبر من المخزون المتاح. يرجى تقليل الكمية.';
    }
    return message;
  }

  void _showClearCartDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            AppLocalizations.of(context)!.clearCart,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.mdFontSize,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.areYouSureClearCart,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await HapticService.buttonClick();
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: AppFonts.getTextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await HapticService.buttonClick();
                Navigator.of(context).pop();
                context.read<CartBloc>().add(const ClearCartEvent());
              },
              child: Text(
                AppLocalizations.of(context)!.clear,
                style: AppFonts.getTextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
