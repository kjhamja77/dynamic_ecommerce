import '../models/order_model.dart';
import '../../domain/entities/order.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../home/data/models/product_model.dart';

class OrderDemoDataSource {
  static List<OrderModel> getDemoOrders() {
    return [
      _createOrder1(),
      _createOrder2(),
      _createOrder3(),
    ];
  }

  static OrderModel _createOrder1() {
          final items = [
        CartItemModel(
          id: 'item1',
          product: ProductModel(
            id: '1',
            name: 'Nike Air Max 270',
            description: 'Comfortable running shoes',
            price: 129.99,
            originalPrice: 159.99,
            images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop'],
            category: 'Shoes',
            brand: 'Nike',
            type: 'variant',
            rating: 4.5,
            reviewCount: 128,
            isAvailable: true,
            sizes: ['7', '8', '9', '10'],
            colors: ['Black', 'White', 'Red'],
            createdAt: DateTime.now(),
          ),
          quantity: 1,
          selectedColor: 'Black',
          selectedSize: '9',
          price: 129.99,
          addedAt: DateTime.now(),
        ),
      ];

    return OrderModel(
      id: 'order1',
      orderNumber: 'ORD-2024-001',
      items: items,
      subtotal: 129.99,
      shippingCost: 9.99,
      taxAmount: 13.00,
      totalAmount: 152.98,
      status: OrderStatus.delivered,
      paymentStatus: PaymentStatus.paid,
      shippingAddress: '123 Main St, New York, NY 10001',
      billingAddress: '123 Main St, New York, NY 10001',
      paymentMethod: 'Credit Card',
      orderDate: DateTime.now().subtract(const Duration(days: 15)),
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 8)),
      deliveredDate: DateTime.now().subtract(const Duration(days: 7)),
      trackingNumber: 'TRK123456789',
      notes: 'Leave at front door if no answer',
      customerId: 'user1',
      customerName: 'John Doe',
      customerEmail: 'john.doe@email.com',
      customerPhone: '+1-555-0123',
    );
  }

  static OrderModel _createOrder2() {
          final items = [
        CartItemModel(
          id: 'item2',
          product: ProductModel(
            id: '2',
            name: 'Adidas Ultraboost 21',
            description: 'Premium running shoes',
            price: 179.99,
            originalPrice: 199.99,
            images: ['https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=400&fit=crop'],
            category: 'Shoes',
            brand: 'Adidas',
            type: 'variant',
            rating: 4.7,
            reviewCount: 89,
            isAvailable: true,
            sizes: ['8', '9', '10', '11'],
            colors: ['Blue', 'White'],
            createdAt: DateTime.now(),
          ),
          quantity: 1,
          selectedColor: 'Blue',
          selectedSize: '10',
          price: 179.99,
          addedAt: DateTime.now(),
        ),
      ];

    return OrderModel(
      id: 'order2',
      orderNumber: 'ORD-2024-002',
      items: items,
      subtotal: 179.99,
      shippingCost: 9.99,
      taxAmount: 18.00,
      totalAmount: 207.98,
      status: OrderStatus.shipped,
      paymentStatus: PaymentStatus.paid,
      shippingAddress: '456 Oak Ave, Los Angeles, CA 90210',
      billingAddress: '456 Oak Ave, Los Angeles, CA 90210',
      paymentMethod: 'PayPal',
      orderDate: DateTime.now().subtract(const Duration(days: 8)),
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
      deliveredDate: null,
      trackingNumber: 'TRK987654321',
      notes: 'Ring doorbell twice',
      customerId: 'user2',
      customerName: 'Jane Smith',
      customerEmail: 'jane.smith@email.com',
      customerPhone: '+1-555-0456',
    );
  }

  static OrderModel _createOrder3() {
          final items = [
        CartItemModel(
          id: 'item3',
          product: ProductModel(
            id: '3',
            name: 'Levi\'s 501 Original Jeans',
            description: 'Classic straight leg denim',
            price: 79.99,
            originalPrice: 99.99,
            images: ['https://images.unsplash.com/photo-1542272604-787c3835535d?w=400&h=400&fit=crop'],
            category: 'Clothing',
            brand: 'Levi\'s',
            type: 'variant',
            rating: 4.3,
            reviewCount: 256,
            isAvailable: true,
            sizes: ['30x32', '32x32', '34x32'],
            colors: ['Blue', 'Black'],
            createdAt: DateTime.now(),
          ),
          quantity: 2,
          selectedColor: 'Blue',
          selectedSize: '32x32',
          price: 79.99,
          addedAt: DateTime.now(),
        ),
      ];

    return OrderModel(
      id: 'order3',
      orderNumber: 'ORD-2024-003',
      items: items,
      subtotal: 159.98,
      shippingCost: 9.99,
      taxAmount: 16.00,
      totalAmount: 185.97,
      status: OrderStatus.processing,
      paymentStatus: PaymentStatus.paid,
      shippingAddress: '789 Pine St, Chicago, IL 60601',
      billingAddress: '789 Pine St, Chicago, IL 60601',
      paymentMethod: 'Credit Card',
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
      deliveredDate: null,
      trackingNumber: null,
      notes: 'Signature required',
      customerId: 'user3',
      customerName: 'Mike Johnson',
      customerEmail: 'mike.johnson@email.com',
      customerPhone: '+1-555-0789',
    );
  }
}
