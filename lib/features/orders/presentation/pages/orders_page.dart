import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/responsive_constants.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/refund_requests_bloc.dart';
import '../widgets/order_card.dart';
import '../widgets/order_status_filter.dart';
import '../widgets/orders_shimmer.dart';
import '../widgets/refund_request_card.dart';
import 'order_details_page.dart';
import 'refund_request_details_page.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/refund_request.dart';
import '../../../../core/di/injection_container.dart' as di;
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

  @override
  bool get wantKeepAlive => true;

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
          }
        },
        child: BlocBuilder<OrdersBloc, OrdersState>(
          buildWhen: (previous, current) {
            // Rebuild when transitioning between different state types
            if (previous.runtimeType != current.runtimeType) {
              return true;
            }
            // For OrdersLoaded states, only rebuild if orders list actually changed
            if (previous is OrdersLoaded && current is OrdersLoaded) {
              return previous.orders != current.orders;
            }
            // For other same-type states, don't rebuild (they're the same)
            return false;
          },
          builder: (context, state) {
            // Load orders on first build if not already loaded
            if (state is OrdersInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<OrdersBloc>().add(const LoadOrders());
              });
            }
            
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
    // When "Returned" is selected, show refund requests list instead of regular orders.
    if (selectedStatusFilter == OrderStatus.returned.name) {
      return _buildRefundRequestsList();
    }

    // For other filters, optionally merge refund requests into "All" view.
    return BlocBuilder<RefundRequestsBloc, RefundRequestsState>(
      builder: (context, refundState) {
        // Trigger refund requests load when viewing "All" for the first time.
        final bool isAllFilter = selectedStatusFilter == null;

        if (isAllFilter && refundState is RefundRequestsInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final bloc = context.read<RefundRequestsBloc>();
            if (bloc.state is RefundRequestsInitial) {
              bloc.add(const LoadRefundRequests());
            }
          });
        }

        // For the "All" tab, don't show partial data. Wait until both
        // orders and refund requests are loaded, then render the merged list.
        if (isAllFilter &&
            (refundState is RefundRequestsInitial ||
             refundState is RefundRequestsLoading)) {
          return const OrdersShimmer();
        }

        final List<Order> baseOrders = selectedStatusFilter != null
            ? orders
                .where(
                  (order) => order.status.name == selectedStatusFilter!,
                )
                .toList()
            : orders;

        // If a specific status filter (other than "returned") is selected,
        // only show regular orders.
        if (selectedStatusFilter != null) {
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

        // "All" view: merge orders and refund requests, sorted by date (most recent first).
        final List<RefundRequest> refundRequests =
            refundState is RefundRequestsLoaded
                ? refundState.requests
                : const <RefundRequest>[];

        final List<_OrderListItem> items = <_OrderListItem>[
          ...baseOrders.map(
            (order) => _OrderListItem.order(
              order: order,
              date: order.orderDate,
            ),
          ),
          ...refundRequests.map(
            (request) => _OrderListItem.refund(
              refund: request,
              date: request.createdAt ?? DateTime.now(),
            ),
          ),
        ];

        if (items.isEmpty) {
          return _buildEmptyState();
        }

        items.sort(
          (a, b) => b.date.compareTo(a.date),
        );

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<OrdersBloc>().add(const LoadOrders());
            context
                .read<RefundRequestsBloc>()
                .add(const RefreshRefundRequests());
          },
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          child: ListView.builder(
            key: const ValueKey('orders_and_refunds_list_all'),
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              if (item.isRefund && item.refund != null) {
                final refund = item.refund!;
                return Padding(
                  key: ValueKey(
                    'refund_${refund.id}_${refund.number}',
                  ),
                  padding: EdgeInsets.only(
                    bottom: ResponsiveConstants.mdSpacing,
                  ),
                  child: RefundRequestCard(
                    refundRequest: refund,
                    onTap: () async {
                      await HapticService.buttonClick();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RefundRequestDetailsPage(
                            refundRequest: refund,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }

              final order = item.order!;
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
      },
    );
  }

  Widget _buildRefundRequestsList() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<RefundRequestsBloc, RefundRequestsState>(
      builder: (context, state) {
        if (state is RefundRequestsInitial) {
          // Trigger initial load after first frame to avoid setState in build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final bloc = context.read<RefundRequestsBloc>();
            if (bloc.state is RefundRequestsInitial) {
              bloc.add(const LoadRefundRequests());
            }
          });
          return const OrdersShimmer();
        }

        if (state is RefundRequestsLoading) {
          return const OrdersShimmer();
        }

        if (state is RefundRequestsError) {
          return _buildRefundErrorState(state.message);
        }

        if (state is RefundRequestsLoaded) {
          final List<RefundRequest> requests = state.requests;
          if (requests.isEmpty) {
            return _buildRefundEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<RefundRequestsBloc>()
                  .add(const RefreshRefundRequests());
            },
            color: colorScheme.primary,
            backgroundColor: colorScheme.surface,
            child: ListView.builder(
              key: const ValueKey('refund_requests_list'),
              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Padding(
                  key: ValueKey(
                    'refund_${request.id}_${request.number}',
                  ),
                  padding: EdgeInsets.only(
                    bottom: ResponsiveConstants.mdSpacing,
                  ),
                  child: RefundRequestCard(
                    refundRequest: request,
                    onTap: () async {
                      await HapticService.buttonClick();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RefundRequestDetailsPage(
                            refundRequest: request,
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

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRefundErrorState(String message) {
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
                context
                    .read<RefundRequestsBloc>()
                    .add(const LoadRefundRequests());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ResponsiveConstants.mdRadius),
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

  Widget _buildRefundEmptyState() {
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
                Icons.assignment_return_outlined,
                size: ResponsiveConstants.emptyStateIconSize,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            Text(
              AppLocalizations.of(context)!.returns,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.lgFontSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.lgPadding,
              ),
              child: Text(
                AppLocalizations.of(context)!.noOrdersYet,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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

class _OrderListItem {
  final DateTime date;
  final bool isRefund;
  final Order? order;
  final RefundRequest? refund;

  const _OrderListItem._({
    required this.date,
    required this.isRefund,
    this.order,
    this.refund,
  });

  factory _OrderListItem.order({
    required Order order,
    required DateTime date,
  }) {
    return _OrderListItem._(
      date: date,
      isRefund: false,
      order: order,
      refund: null,
    );
  }

  factory _OrderListItem.refund({
    required RefundRequest refund,
    required DateTime date,
  }) {
    return _OrderListItem._(
      date: date,
      isRefund: true,
      order: null,
      refund: refund,
    );
  }
}
