import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

class UserOrder extends Equatable {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final OrderStatus status;
  final double totalAmount;
  final String currency;
  final List<OrderItem> items;
  final String? trackingNumber;
  final DateTime? estimatedDelivery;
  final String? notes;

  const UserOrder({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.currency,
    required this.items,
    this.trackingNumber,
    this.estimatedDelivery,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        orderDate,
        status,
        totalAmount,
        currency,
        items,
        trackingNumber,
        estimatedDelivery,
        notes,
      ];
}

class OrderItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final String? size;
  final String? color;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    this.size,
    this.color,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productImage,
        quantity,
        unitPrice,
        size,
        color,
      ];
}
