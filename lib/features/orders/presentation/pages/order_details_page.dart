import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/order.dart';
import '../widgets/order_item_card.dart';
import '../widgets/shipping_delivery_info.dart';
import '../widgets/delivery_details_widget.dart';
import '../widgets/payment_details_card.dart';
import '../widgets/order_action_buttons.dart';
import '../widgets/order_help_button.dart';
import '../widgets/order_details_shimmer.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/orders_bloc.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../core/utils/order_date_utils.dart';
import '../../core/constants/order_constants.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showFab = ValueNotifier<bool>(true);
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final ordersBloc = context.read<OrdersBloc>();
    if (widget.order.id.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ordersBloc.add(LoadOrderById(widget.order.id));
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _showFab.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    final isScrollingDown = currentOffset > _lastScrollOffset;
    final isScrollingUp = currentOffset < _lastScrollOffset;

    // Show FAB when scrolling up or at top, hide when scrolling down
    if (isScrollingDown && _showFab.value && currentOffset > 100) {
      _showFab.value = false;
    } else if ((isScrollingUp || currentOffset <= 100) && !_showFab.value) {
      _showFab.value = true;
    }

    _lastScrollOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          // FULL shimmer until we have real order details (no initial widget.order data)
          final hasLoadedOrder = state is OrderDetailsLoaded ||
              state is OrderDetailsError ||
              state is DeliveryStatusLoading;

          if (!hasLoadedOrder) {
            final colorScheme = Theme.of(context).colorScheme;
            return Scaffold(
              backgroundColor: colorScheme.surfaceContainerLowest,
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.orderHistory,
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
              ),
              body: const OrderDetailsShimmer(),
            );
          }

          final currentOrder = _getCurrentOrder(state);

          final colorScheme = Theme.of(context).colorScheme;
          return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLowest,
          appBar: _buildAppBar(context, currentOrder),
          floatingActionButton: ValueListenableBuilder<bool>(
            valueListenable: _showFab,
            builder: (context, showFab, _) {
              return AnimatedScale(
                scale: showFab ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedOpacity(
                  opacity: showFab ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: OrderHelpButton(order: currentOrder),
                ),
              );
            },
          ),
          body: _buildBody(context, state, currentOrder),
        );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrdersState state, Order currentOrder) {
    // Get delivery status and error message from state
    final deliveryStatus = _getDeliveryStatus(state);
    final errorMessage = _getErrorMessage(state);

    return Stack(
      children: [
        Column(
          children: [
            // Redesigned hero header with key order information
            _buildHeroHeader(context, currentOrder, deliveryStatus),
            // Tabs for better organization: Overview, Items, Tracking
            _buildTabBar(context),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOverviewTab(context, currentOrder, deliveryStatus),
                  _buildItemsTab(context, currentOrder),
                  _buildTrackingTab(context, currentOrder, deliveryStatus),
                ],
              ),
            ),
          ],
        ),
        if (errorMessage != null)
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Material(
              color: OrderConstants.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: OrderConstants.errorColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.smFontSize,
                          color: OrderConstants.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Top hero section with order number, status, date, total amount and delivery summary.
  Widget _buildHeroHeader(
    BuildContext context,
    Order order,
    DeliveryStatusDto? deliveryStatus,
  ) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shadowOpacity = theme.brightness == Brightness.dark ? 0.25 : 0.08;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(ResponsiveConstants.mdPadding),
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
        border: Border.all(
          color: OrderConstants.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: shadowOpacity),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: shadowOpacity * 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Modern decorative background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
              child: CustomPaint(
                painter: _ModernHeaderPainter(
                  primaryColor: OrderConstants.primaryColor,
                ),
              ),
            ),
          ),
          // Content
          Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order number and state
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: OrderConstants.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            loc.orderNumberWithValue(order.orderNumber),
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.lgFontSize,
                              fontWeight: FontWeight.w700,
                              color: OrderConstants.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveConstants.smSpacing),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: OrderConstants.statusColors[order.status.name]?.withValues(alpha: 0.1) ?? 
                                   OrderConstants.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            OrderConstants.localizedStatus(context, order.status),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.smFontSize,
                              fontWeight: FontWeight.w600,
                              color: OrderConstants.statusColors[order.status.name] ?? 
                                     OrderConstants.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          // Order meta: date and total amount
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: ResponsiveConstants.xsSpacing),
              Expanded(
                child: Text(
                  OrderDateUtils.formatDate(context, order.orderDate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.smFontSize,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    loc.totalAmount,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.xsFontSize,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${order.totalAmount.toStringAsFixed(2)} ${order.currency ?? ''}',
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.lgFontSize,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      child: TabBar(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        indicatorWeight: 3,
        tabs: [
          Tab(text: loc.orderSummary),
          Tab(text: loc.orderItemsTitle),
          Tab(text: loc.deliveryStatus),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    Order order,
    DeliveryStatusDto? deliveryStatus,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: ResponsiveConstants.mdPadding,
        right: ResponsiveConstants.mdPadding,
        bottom: MediaQuery.of(context).padding.bottom + 20,
        top: ResponsiveConstants.mdPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShippingDeliveryInfo(order: order),
          SizedBox(height: ResponsiveConstants.lgSpacing),
          PaymentDetailsCard(order: order),
          SizedBox(height: ResponsiveConstants.lgSpacing),
          OrderActionButtons(order: order),
        ],
      ),
    );
  }

  Widget _buildItemsTab(BuildContext context, Order order) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: _buildOrderItems(context, order),
    );
  }

  Widget _buildTrackingTab(
    BuildContext context,
    Order order,
    DeliveryStatusDto? deliveryStatus,
  ) {
    final loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: ResponsiveConstants.mdPadding,
        right: ResponsiveConstants.mdPadding,
        bottom: MediaQuery.of(context).padding.bottom + 20,
        top: ResponsiveConstants.mdPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Small intro header
          Builder(
            builder: (context) {
              final cs = Theme.of(context).colorScheme;
              return Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: cs.onSurface,
                    size: ResponsiveConstants.mdIconSize,
                  ),
                  SizedBox(width: ResponsiveConstants.smSpacing),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.deliveryStatus,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.mdFontSize,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Text(
                        loc.viewDetailedTrackingInformation,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.xsFontSize,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),

          if (deliveryStatus != null)
            DeliveryDetailsWidget(deliveryStatus: deliveryStatus)
          else
            _buildTrackingEmptyState(context, order),
        ],
      ),
    );
  }

  Widget _buildTrackingEmptyState(BuildContext context, Order order) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.2 : 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  Icons.help_outline,
                  color: colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              SizedBox(width: ResponsiveConstants.mdSpacing),
              Expanded(
                child: Text(
                  loc.viewTrackingDetails,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          Text(
            loc.orderOnWayMessage,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Order order) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(
        loc.orderNumberWithValue(order.orderNumber),
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
    );
  }

  Widget _buildOrderItems(BuildContext context, Order order) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: EdgeInsets.all(ResponsiveConstants.mdPadding),
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.25 : 0.08,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                color: colorScheme.onSurface,
                size: ResponsiveConstants.mdIconSize,
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Text(
                loc.orderItemsTitle,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          Text(
            loc.orderItemsSubtitle(order.itemCount),
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          ...order.items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
              child: OrderItemCard(item: item),
            ),
          ),
        ],
      ),
    );
  }

  Order _getCurrentOrder(OrdersState state) {
    if (state is OrderDetailsLoaded) {
      return state.order;
    }
    if (state is OrderDetailsError && state.cachedOrder != null) {
      return state.cachedOrder!;
    }
    if (state is DeliveryStatusLoading) {
      return state.order;
    }
    return widget.order;
  }

  DeliveryStatusDto? _getDeliveryStatus(OrdersState state) {
    if (state is OrderDetailsLoaded) {
      return state.deliveryStatus;
    }
    return null;
  }

  String? _getErrorMessage(OrdersState state) {
    if (state is OrderDetailsError) {
      return state.message;
    }
    if (state is OrderDetailsLoaded && state.errorMessage != null) {
      return state.errorMessage;
    }
    return null;
  }
}

// Modern decorative background painter
class _ModernHeaderPainter extends CustomPainter {
  final Color primaryColor;

  _ModernHeaderPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: 0.03);

    // Draw subtle geometric shapes
    final path1 = Path()
      ..moveTo(size.width * 0.7, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..close();
    canvas.drawPath(path1, paint);

    final path2 = Path()
      ..moveTo(size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.6, size.height)
      ..lineTo(size.width * 0.8, size.height * 0.7)
      ..close();
    canvas.drawPath(path2, paint);

    // Draw subtle circles
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: 0.02);

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.2),
      size.width * 0.15,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.8),
      size.width * 0.12,
      circlePaint,
    );

    // Draw subtle diagonal lines
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = primaryColor.withValues(alpha: 0.05);

    for (int i = 0; i < 3; i++) {
      final y = size.height * (0.3 + i * 0.2);
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.4, y + size.height * 0.1),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
