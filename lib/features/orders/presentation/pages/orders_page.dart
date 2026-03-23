import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/responsive_constants.dart';
import '../bloc/orders_bloc.dart';
import '../widgets/order_card.dart';
import '../widgets/order_status_filter.dart';
import '../widgets/orders_shimmer.dart';
import 'order_details_page.dart';
import '../../domain/entities/order.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/app_localization_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with AutomaticKeepAliveClientMixin {
  String? selectedStatusFilter;
  List<Order> _cachedOrders = [];
  final ScrollController _statusFilterScrollController = ScrollController();
  Locale? _lastLocale;
  bool _isRefreshingForLocale = false;

  @override
  void initState() {
    super.initState();
    // Trigger initial orders load once when the screen is first created.
    final bloc = context.read<OrdersBloc>();
    if (bloc.state is OrdersInitial) {
      bloc.add(const LoadOrders());
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_lastLocale != locale) {
      final hadLocaleBefore = _lastLocale != null;
      _lastLocale = locale;
      // On runtime locale switch, avoid showing stale-language cached orders.
      if (hadLocaleBefore) {
        _cachedOrders = <Order>[];
        _isRefreshingForLocale = true;
        context.read<OrdersBloc>().add(const LoadOrders());
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _statusFilterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(),
      body: BlocListener<OrdersBloc, OrdersState>(
        listener: (context, state) {
          // Cache orders when loaded
          if (state is OrdersLoaded) {
            _cachedOrders = state.orders;
            _isRefreshingForLocale = false;
          } else if (state is OrdersError) {
            _isRefreshingForLocale = false;
          }
        },
        child: BlocBuilder<OrdersBloc, OrdersState>(
          buildWhen: (previous, current) {
            // Rebuild when transitioning between different state types
            if (previous.runtimeType != current.runtimeType) {
              return true;
            }
            // For OrdersLoaded states, always rebuild so that locale changes
            // (e.g. EN ↔ AR) update filter chip labels dynamically
            if (previous is OrdersLoaded && current is OrdersLoaded) {
              return true;
            }
            // For other same-type states, don't rebuild (they're the same)
            return false;
          },
          builder: (context, state) {
            return _buildBody(state);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.myOrders,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.lgFontSize,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      backgroundColor: colorScheme.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildBody(OrdersState state) {
    final localizationService = AppLocalizationService();

    // During language change/refresh, always show shimmer to avoid stale text flash.
    if (localizationService.isChangingLanguage || _isRefreshingForLocale) {
      return const OrdersShimmer();
    }

    // Show shimmer loading on initial load
    if (state is OrdersLoading && _cachedOrders.isEmpty) {
      return const OrdersShimmer();
    }

    if (state is OrdersError && _cachedOrders.isEmpty) {
      return _buildErrorState(state.message);
    }

    // Use cached orders if available, otherwise use state orders
    final List<Order> ordersToDisplay = _cachedOrders.isNotEmpty 
        ? _cachedOrders 
        : (state is OrdersLoaded ? state.orders : <Order>[]);

    if (ordersToDisplay.isNotEmpty || state is OrdersLoaded) {
      return _buildOrdersContent(ordersToDisplay);
    }

    if (state is OrdersLoading) {
      return _buildOrdersContent(ordersToDisplay); // Show cached while loading
    }

    // Show shimmer for initial state
    if (state is OrdersInitial) {
      return const OrdersShimmer();
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
              decoration: BoxDecoration(
                color: isDark 
                    ? colorScheme.error.withOpacity(0.2)
                    : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: ResponsiveConstants.errorIconSize,
                color: colorScheme.error,
              ),
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            Text(
              AppLocalizations.of(context)!.failedToLoadOrders,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.lgFontSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Text(
              message,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            ElevatedButton(
              onPressed: () async {
                await HapticService.buttonClick();
                context.read<OrdersBloc>().add(const LoadOrders());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.lgPadding,
                  vertical: ResponsiveConstants.mdPadding,
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.retry,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersContent(List<Order> orders) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Derive the set of statuses that actually exist in the current
    // order history. This effectively mirrors the backend's status list
    // while still using our domain enum values.
    final Set<OrderStatus> existingStatuses =
        orders.map((order) => order.status).toSet()
          ..remove(OrderStatus.returned);
    final List<OrderStatus> availableStatuses = OrderStatus.values
        .where(existingStatuses.contains)
        .toList();
    // Detect if there are any refund-type orders based on backend order_status.
    final bool hasRefundOrders = orders.any(
      (order) => (order.orderStatus ?? '').toLowerCase().contains('refund'),
    );
    
    return Column(
      children: [
        // Status Filter with better styling
        Container(
          color: colorScheme.surface,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveConstants.mdPadding,
            vertical: ResponsiveConstants.smPadding,
          ),
          child: OrderStatusFilter(
            selectedStatus: selectedStatusFilter,
            scrollController: _statusFilterScrollController,
            availableStatuses: availableStatuses,
            showRefundChip: hasRefundOrders,
            onStatusChanged: (status) {
              // Only update local state, no BLoC event needed
              setState(() {
                selectedStatusFilter = status;
              });
            },
          ),
        ),
        // Divider
        Container(
          height: 1,
          color: colorScheme.outline.withOpacity(0.2),
        ),
        // Orders List
        Expanded(
          child: _buildOrdersList(orders),
        ),
      ],
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    List<Order> baseOrders;

    // Helper to detect refund orders from backend order_status.
    bool isRefundOrder(Order order) =>
        (order.orderStatus ?? '').toLowerCase().contains('refund');

    if (selectedStatusFilter == 'refund') {
      // Refund filter: show only refund-type orders.
      baseOrders = orders.where(isRefundOrder).toList();
    } else if (selectedStatusFilter != null) {
      baseOrders = orders.where((order) {
        final matchesStatus = order.status.name == selectedStatusFilter!;
        if (selectedStatusFilter == OrderStatus.pending.name) {
          // Pending filter: exclude refund orders.
          return matchesStatus && !isRefundOrder(order);
        }
        return matchesStatus;
      }).toList();
    } else {
      baseOrders = orders;
    }

    if (baseOrders.isEmpty) {
      return _buildEmptyState();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrdersBloc>().add(const LoadOrders());
      },
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      child: ListView.builder(
        key: ValueKey(
          'orders_list_${selectedStatusFilter ?? 'all'}',
        ),
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        itemCount: baseOrders.length,
        itemBuilder: (context, index) {
          final order = baseOrders[index];
          debugPrint('order status from the order card ${order.status}');
          return Padding(
            key: ValueKey(
              'order_${order.id}_${order.orderNumber}',
            ),
            padding: EdgeInsets.only(
              bottom: ResponsiveConstants.mdSpacing,
            ),
            child: OrderCard(
              order: order,
              onTap: () async {
                await HapticService.buttonClick();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => di.sl<OrdersBloc>(),
                      child: OrderDetailsPage(order: order),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surface : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: ResponsiveConstants.emptyStateIconSize,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            Text(
              selectedStatusFilter != null 
                  ? AppLocalizations.of(context)!.noOrdersWithThisStatus
                  : AppLocalizations.of(context)!.noOrdersYet,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.lgFontSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.lgPadding),
              child: Text(
                selectedStatusFilter != null
                    ? AppLocalizations.of(context)!.trySelectingDifferentStatus
                    : AppLocalizations.of(context)!.startShoppingToSeeOrders,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (selectedStatusFilter != null) ...[
              SizedBox(height: ResponsiveConstants.lgSpacing),
              TextButton(
                onPressed: () async {
                  await HapticService.buttonClick();
                  setState(() {
                    selectedStatusFilter = null;
                  });
                  if (_statusFilterScrollController.hasClients) {
                    _statusFilterScrollController.animateTo(
                      0,
                      duration: AppConstants.shortAnimation,
                      curve: Curves.easeOut,
                    );
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveConstants.lgPadding,
                    vertical: ResponsiveConstants.mdPadding,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.viewAllOrders,
                  style: AppFonts.getTextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveConstants.mdFontSize,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
