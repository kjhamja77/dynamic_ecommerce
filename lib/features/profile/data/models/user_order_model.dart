import '../../domain/entities/user_order.dart';

class UserOrderModel extends UserOrder {
  const UserOrderModel({
    required super.id,
    required super.orderNumber,
    required super.orderDate,
    required super.status,
    required super.totalAmount,
    required super.currency,
    required super.items,
    super.trackingNumber,
    super.estimatedDelivery,
    super.notes,
  });

  factory UserOrderModel.fromJson(Map<String, dynamic> json) {
    return UserOrderModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      orderDate: DateTime.parse(json['order_date'] as String),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      trackingNumber: json['tracking_number'] as String?,
      estimatedDelivery: json['estimated_delivery'] != null 
          ? DateTime.parse(json['estimated_delivery'] as String) 
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'order_date': orderDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'total_amount': totalAmount,
      'currency': currency,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      'tracking_number': trackingNumber,
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
      'notes': notes,
    };
  }

  factory UserOrderModel.fromEntity(UserOrder entity) {
    return UserOrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      orderDate: entity.orderDate,
      status: entity.status,
      totalAmount: entity.totalAmount,
      currency: entity.currency,
      items: entity.items,
      trackingNumber: entity.trackingNumber,
      estimatedDelivery: entity.estimatedDelivery,
      notes: entity.notes,
    );
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    super.productImage,
    required super.quantity,
    required super.unitPrice,
    super.size,
    super.color,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      size: json['size'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'unit_price': unitPrice,
      'size': size,
      'color': color,
    };
  }

  factory OrderItemModel.fromEntity(OrderItem entity) {
    return OrderItemModel(
      id: entity.id,
      productId: entity.productId,
      productName: entity.productName,
      productImage: entity.productImage,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      size: entity.size,
      color: entity.color,
    );
  }
}
