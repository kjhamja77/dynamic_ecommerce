import 'package:equatable/equatable.dart';
import '../../../cart/domain/entities/cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

enum DeliveryState {
  notStarted,
  preparing,
  readyToShip,
  inTransit,
  outForDelivery,
  delivered,
  deliveryFailed,
  returned,
}

class Order extends Equatable {
  final String id;
  final String orderNumber;
  final List<CartItem> items;
  final double subtotal;
  final double shippingCost;
  final double taxAmount;
  final double totalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String shippingAddress;
  final String billingAddress;
  final String paymentMethod;
  final DateTime orderDate;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredDate;
  final String? trackingNumber;
  final String? trackingPage;
  final DeliveryState? deliveryState;
  final String? deliveryCarrier;
  final String? currentLocation;
  final DateTime? shippedDate;
  final DateTime? outForDeliveryDate;
  final String? deliveryNotes;
  final String? notes;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  
  // New API fields
  final String? state; // Order state from API (e.g., "sale", "draft")
  final String? stateDisplay; // Display name for state (e.g., "Sales Order")
  final String? currency; // Currency code (e.g., "IQD")
  final int? orderLineCount; // Total number of order lines
  final String? deliveryStatus; // Delivery status string (e.g., "pending")
  final String? invoiceStatus; // Invoice status string (e.g., "to invoice")
  final DateTime? validityDate; // Order validity date
  final Map<String, dynamic>? partnerShipping; // Full shipping partner object
  final Map<String, dynamic>? shippingMethod; // Full shipping method object

  const Order({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.taxAmount,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.shippingAddress,
    required this.billingAddress,
    required this.paymentMethod,
    required this.orderDate,
    this.estimatedDelivery,
      this.deliveredDate,
      this.trackingNumber,
      this.trackingPage,
      this.deliveryState,
      this.deliveryCarrier,
      this.currentLocation,
      this.shippedDate,
      this.outForDeliveryDate,
      this.deliveryNotes,
      this.notes,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.state,
    this.stateDisplay,
    this.currency,
    this.orderLineCount,
    this.deliveryStatus,
    this.invoiceStatus,
    this.validityDate,
    this.partnerShipping,
    this.shippingMethod,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isShipped => status == OrderStatus.shipped;
  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;
  bool get canBeTracked => status == OrderStatus.shipped || status == OrderStatus.delivered;
  
  // Delivery state helpers
  bool get isDeliveryInProgress => deliveryState != null && 
    (deliveryState == DeliveryState.preparing ||
     deliveryState == DeliveryState.readyToShip ||
     deliveryState == DeliveryState.inTransit ||
     deliveryState == DeliveryState.outForDelivery);
  bool get isDeliveryCompleted => deliveryState == DeliveryState.delivered;
  bool get isDeliveryFailed => deliveryState == DeliveryState.deliveryFailed;

  Order copyWith({
    String? id,
    String? orderNumber,
    List<CartItem>? items,
    double? subtotal,
    double? shippingCost,
    double? taxAmount,
    double? totalAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? shippingAddress,
    String? billingAddress,
    String? paymentMethod,
    DateTime? orderDate,
    DateTime? estimatedDelivery,
    DateTime? deliveredDate,
    String? trackingNumber,
    String? trackingPage,
    DeliveryState? deliveryState,
    String? deliveryCarrier,
    String? currentLocation,
    DateTime? shippedDate,
    DateTime? outForDeliveryDate,
    String? deliveryNotes,
    String? notes,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? state,
    String? stateDisplay,
    String? currency,
    int? orderLineCount,
    String? deliveryStatus,
    String? invoiceStatus,
    DateTime? validityDate,
    Map<String, dynamic>? partnerShipping,
    Map<String, dynamic>? shippingMethod,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderDate: orderDate ?? this.orderDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      trackingPage: trackingPage ?? this.trackingPage,
      deliveryState: deliveryState ?? this.deliveryState,
      deliveryCarrier: deliveryCarrier ?? this.deliveryCarrier,
      currentLocation: currentLocation ?? this.currentLocation,
      shippedDate: shippedDate ?? this.shippedDate,
      outForDeliveryDate: outForDeliveryDate ?? this.outForDeliveryDate,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      notes: notes ?? this.notes,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      state: state ?? this.state,
      stateDisplay: stateDisplay ?? this.stateDisplay,
      currency: currency ?? this.currency,
      orderLineCount: orderLineCount ?? this.orderLineCount,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      validityDate: validityDate ?? this.validityDate,
      partnerShipping: partnerShipping ?? this.partnerShipping,
      shippingMethod: shippingMethod ?? this.shippingMethod,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        items,
        subtotal,
        shippingCost,
        taxAmount,
        totalAmount,
        status,
        paymentStatus,
        shippingAddress,
        billingAddress,
        paymentMethod,
        orderDate,
        estimatedDelivery,
        deliveredDate,
        trackingNumber,
        trackingPage,
        deliveryState,
        deliveryCarrier,
        currentLocation,
        shippedDate,
        outForDeliveryDate,
        deliveryNotes,
        notes,
        customerId,
        customerName,
        customerEmail,
        customerPhone,
        state,
        stateDisplay,
        currency,
        orderLineCount,
        deliveryStatus,
        invoiceStatus,
        validityDate,
        partnerShipping,
        shippingMethod,
      ];
}
