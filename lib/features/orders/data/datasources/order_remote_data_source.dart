import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../home/data/models/product_model.dart';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';

class DeliveryStatusDto {
  final int orderId;
  final int deliveryTransactionId;
  final String status;
  final String? trackingPage;
  final List<DeliveryStatusHistoryDto> lastStatuses;

  DeliveryStatusDto({
    required this.orderId,
    required this.deliveryTransactionId,
    required this.status,
    this.trackingPage,
    required this.lastStatuses,
  });

  factory DeliveryStatusDto.fromJson(Map<String, dynamic> json) {
    final lastStatusesList = json['last_statuses'] as List<dynamic>? ?? [];
    return DeliveryStatusDto(
      orderId: (json['order_id'] as num).toInt(),
      deliveryTransactionId: (json['delivery_transaction_id'] as num).toInt(),
      status: (json['status'] ?? '').toString(),
      trackingPage: json['tracking_page']?.toString(),
      lastStatuses: lastStatusesList
          .whereType<Map<String, dynamic>>()
          .map((item) => DeliveryStatusHistoryDto.fromJson(item))
          .toList(),
    );
  }
}

class DeliveryStatusHistoryDto {
  final String title;
  final String slug;
  final DateTime createdAt;
  final String merchantTitle;
  final DeliveryStatusPivotDto? pivot;

  DeliveryStatusHistoryDto({
    required this.title,
    required this.slug,
    required this.createdAt,
    required this.merchantTitle,
    this.pivot,
  });

  factory DeliveryStatusHistoryDto.fromJson(Map<String, dynamic> json) {
    return DeliveryStatusHistoryDto(
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      createdAt: _parseDateTime(json['created_at']),
      merchantTitle: (json['merchant_title'] ?? '').toString(),
      pivot: json['pivot'] != null
          ? DeliveryStatusPivotDto.fromJson(json['pivot'] as Map<String, dynamic>)
          : null,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    final String raw = value.toString();
    if (raw.isEmpty) return DateTime.now();
    final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized) ?? DateTime.now();
  }
}

class DeliveryStatusPivotDto {
  final int id;
  final String issuerType;
  final int issuerId;
  final String? carrierMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryStatusPivotDto({
    required this.id,
    required this.issuerType,
    required this.issuerId,
    this.carrierMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryStatusPivotDto.fromJson(Map<String, dynamic> json) {
    return DeliveryStatusPivotDto(
      id: (json['id'] as num).toInt(),
      issuerType: (json['issuer_type'] ?? '').toString(),
      issuerId: (json['issuer_id'] as num).toInt(),
      carrierMessage: json['carrier_message']?.toString(),
      createdAt: DeliveryStatusHistoryDto._parseDateTime(json['created_at']),
      updatedAt: DeliveryStatusHistoryDto._parseDateTime(json['updated_at']),
    );
  }
}

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrderHistory({int page, int limit});
  Future<OrderModel> getOrderDetails({required int orderId});
  Future<DeliveryStatusDto> getDeliveryStatus({required int orderId});
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<OrderModel>> getOrderHistory({int page = 1, int limit = AppConstants.defaultPageSize}) async {
    try {
      // Queued raw GET (no RPC wrapping) so it won't run in parallel with other requests.
      final response = await apiClient.requestRaw(
        '/ecom/sale/orderHistory',
        method: 'GET',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerFailure('Unexpected response structure while fetching order history');
      }

      // Check for error response
      if (data['status'] == 'error' || response.statusCode != 200) {
        final errorMessage = data['message']?.toString() ?? 
                           'Failed to fetch order history (${response.statusCode ?? 'unknown'})';
        throw ServerFailure(errorMessage);
      }

      // Handle both RPC envelope format and direct format
      Map<String, dynamic>? ordersPayload;
      if (data.containsKey('result') && data['result'] is Map<String, dynamic>) {
        // RPC envelope format
        final result = data['result'] as Map<String, dynamic>;
        ordersPayload = result['data'] as Map<String, dynamic>?;
      } else if (data.containsKey('data')) {
        // Direct format
        ordersPayload = data['data'] as Map<String, dynamic>?;
      }

      final ordersList = ordersPayload?['orders'];
      if (ordersList is! List) {
        return const <OrderModel>[];
      }

      final DateTime now = DateTime.now();
      return ordersList
          .whereType<Map<String, dynamic>>()
          .map((rawOrder) => _mapOrderFromApi(rawOrder, now))
          .toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Network error while fetching order history');
    } catch (e) {
      throw ServerFailure('Unexpected error while fetching order history: $e');
    }
  }

  @override
  Future<OrderModel> getOrderDetails({required int orderId}) async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/sale/orderDetails',
        method: 'POST',
        params: {'order_id': orderId},
      );

      if (response.statusCode != 200) {
        throw ServerFailure('Failed to fetch order details (${response.statusCode})');
      }

      final root = response.data;
      if (root is Map<String, dynamic>) {
        final result = root['result'];
        if (result is Map<String, dynamic>) {
          final data = result['data'];
          if (data is Map<String, dynamic>) {
            return _mapOrderFromApi(data, DateTime.now());
          }
        }

        // Some endpoints may respond without RPC envelope
        final data = root['data'];
        if (data is Map<String, dynamic>) {
          return _mapOrderFromApi(data, DateTime.now());
        }
      }

      throw ServerFailure('Unexpected response structure while fetching order details');
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Network error while fetching order details');
    } catch (e) {
      throw ServerFailure('Unexpected error while fetching order details: $e');
    }
  }

  OrderModel _mapOrderFromApi(Map<String, dynamic> json, DateTime defaultDate) {
    final int rawId = (json['id'] ?? 0) is String
        ? int.tryParse(json['id'] as String) ?? 0
        : (json['id'] as num?)?.toInt() ?? 0;
    final String id = rawId.toString();

    final String orderNumber = (json['name'] ?? '').toString();
    final String state = (json['state'] ?? '').toString().toLowerCase();
    final String stateDisplay = (json['state_display'] ?? '').toString();
    final String invoiceStatus = (json['invoice_status'] ?? '').toString().toLowerCase();
    final String alqasehStatus = (json['alqaseh_status'] ?? '').toString().toLowerCase();
    final String deliveryStatus = (json['delivery_status'] ?? '').toString();
    final String currency = (json['currency'] ?? '').toString();
    final int? orderLineCount = json['order_line_count'] != null 
        ? (json['order_line_count'] as num).toInt() 
        : null;
    
    // Extract payment_state from invoices array (priority source for payment status)
    String paymentState = '';
    final List<dynamic> invoices = (json['invoices'] as List<dynamic>?) ?? const <dynamic>[];
    if (invoices.isNotEmpty) {
      final firstInvoice = invoices.first;
      if (firstInvoice is Map<String, dynamic>) {
        paymentState = (firstInvoice['payment_state'] ?? '').toString().toLowerCase();
      }
    }
    
    final Map<String, dynamic> shippingPartner = (json['partner_shipping'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final List<dynamic> orderLines = (json['order_lines'] as List<dynamic>?) ?? const <dynamic>[];
    final Map<String, dynamic>? shippingMethod = json['shipping_method'] as Map<String, dynamic>?;

    final DateTime orderDate = _parseDateTime(json['date_order']) ?? defaultDate;
    final DateTime? validityDate = _parseDate(json['validity_date']);

    final List<CartItem> items = orderLines
        .whereType<Map<String, dynamic>>()
        .map((line) => _mapCartItemFromOrderLine(line, orderDate))
        .toList();

    final double shippingCost = shippingMethod != null
        ? (shippingMethod['price_total'] as num?)?.toDouble() ?? 0.0
        : 0.0;

    // Create copies of partnerShipping and shippingMethod maps
    final Map<String, dynamic>? partnerShippingCopy = shippingPartner.isNotEmpty
        ? Map<String, dynamic>.from(shippingPartner)
        : null;
    final Map<String, dynamic>? shippingMethodCopy = shippingMethod != null
        ? Map<String, dynamic>.from(shippingMethod)
        : null;

    final OrderModel order = OrderModel(
      id: id,
      orderNumber: orderNumber.isEmpty ? 'ORDER-$id' : orderNumber,
      items: items,
      subtotal: (json['amount_untaxed'] as num?)?.toDouble() ?? 0.0,
      shippingCost: shippingCost,
      taxAmount: (json['amount_tax'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['amount_total'] as num?)?.toDouble() ?? 0.0,
      status: _mapOrderStatus(state),
      paymentStatus: _mapPaymentStatus(paymentState.isNotEmpty ? paymentState : invoiceStatus, alqasehStatus),
      shippingAddress: _buildShippingAddress(shippingPartner),
      billingAddress: _buildShippingAddress(shippingPartner),
      paymentMethod: _inferPaymentMethod(json),
      orderDate: orderDate,
      estimatedDelivery: validityDate,
      deliveredDate: null,
      trackingNumber: deliveryStatus.isNotEmpty ? deliveryStatus : null,
      notes: null,
      customerId: (shippingPartner['id'] ?? '').toString(),
      customerName: (shippingPartner['name'] ?? '').toString(),
      customerEmail: (shippingPartner['email'] ?? '').toString(),
      customerPhone: (shippingPartner['phone'] ?? shippingPartner['mobile'] ?? '').toString(),
      state: state.isNotEmpty ? state : null,
      stateDisplay: stateDisplay.isNotEmpty ? stateDisplay : null,
      currency: currency.isNotEmpty ? currency : null,
      orderLineCount: orderLineCount,
      deliveryStatus: deliveryStatus.isNotEmpty ? deliveryStatus : null,
      invoiceStatus: invoiceStatus.isNotEmpty ? invoiceStatus : null,
      validityDate: validityDate,
      partnerShipping: partnerShippingCopy,
      shippingMethod: shippingMethodCopy,
    );

    return order;
  }

  CartItem _mapCartItemFromOrderLine(Map<String, dynamic> line, DateTime orderDate) {
    final String itemId = (line['id'] ?? line['line_id'] ?? '').toString();
    final String productId = (line['product_id'] ?? line['product_template_id'] ?? itemId).toString();
    final String productTemplateId = (line['product_template_id'] ?? productId).toString();
    final String name = (line['product_name'] ?? line['product_template_name'] ?? '').toString();
    final double price = (line['price_unit'] as num?)?.toDouble() ?? 0.0;
    final int quantity = ((line['product_uom_qty'] as num?)?.round()) ?? 1;
    
    // Try to get image from product_image, otherwise construct fallback URL
    String imageUrl = '';
    final productImage = line['product_image']?.toString();
    if (productImage != null && productImage.isNotEmpty && productImage != 'null') {
      imageUrl = _resolveImageUrl(productImage);
    } else {
      // Fallback: construct image URL from product_id (variant) or product_template_id
      // Try variant image first: /web/image/product.product/{product_id}/image_1920
      final variantId = line['product_id'];
      if (variantId != null) {
        imageUrl = _resolveImageUrl('/web/image/product.product/$variantId/image_1920');
      } else if (productTemplateId.isNotEmpty) {
        // If no variant ID, use template image
        imageUrl = _resolveImageUrl('/web/image/product.template/$productTemplateId/image_1920');
      }
    }

    final ProductModel product = ProductModel(
      id: productId,
      name: name.isEmpty ? 'Product $productId' : name,
      description: (line['product_default_code'] ?? '').toString(),
      price: price,
      originalPrice: price,
      images: imageUrl.isNotEmpty ? <String>[imageUrl] : <String>[],
      category: (line['category_name'] ?? '').toString(),
      brand: (line['brand'] ?? '').toString(),
      type: 'variant',
      rating: 0,
      reviewCount: 0,
      isAvailable: true,
      sizes: const <String>[],
      colors: const <String>[],
      createdAt: orderDate,
      favourite: false,
    );

    // Extract variant attributes from order line
    // Try multiple possible field names for color and size
    String color = '';
    String size = '';
    
    // Check various possible field names for color
    color = (line['color'] ?? 
             line['color_name'] ?? 
             line['product_color'] ?? 
             line['variant_color'] ??
             '').toString();
    
    // Check various possible field names for size
    size = (line['size'] ?? 
            line['size_name'] ?? 
            line['product_size'] ?? 
            line['variant_size'] ??
            '').toString();
    
    // Also try to extract from product_attributes or variant_attributes if they exist
    if (color.isEmpty || size.isEmpty) {
      final attributes = line['product_attributes'] ?? line['variant_attributes'] ?? line['attributes'];
      if (attributes is Map) {
        if (color.isEmpty) {
          color = (attributes['color'] ?? 
                   attributes['color_name'] ?? 
                   attributes['COLOR NAME'] ?? 
                   '').toString();
        }
        if (size.isEmpty) {
          size = (attributes['size'] ?? 
                  attributes['size_name'] ?? 
                  attributes['SIZE'] ?? 
                  '').toString();
        }
      } else if (attributes is List) {
        // Handle list of attributes
        for (final attr in attributes) {
          if (attr is Map) {
            final attrName = (attr['attribute_name'] ?? attr['name'] ?? '').toString().toLowerCase();
            final attrValue = (attr['value_name'] ?? attr['value'] ?? '').toString();
            if (color.isEmpty && (attrName.contains('color') || attrName == 'اللون')) {
              color = attrValue;
            }
            if (size.isEmpty && attrName.contains('size')) {
              size = attrValue;
            }
          }
        }
      }
    }
    
    return CartItemModel(
      id: itemId,
      product: product,
      quantity: quantity,
      selectedColor: color,
      selectedSize: size,
      price: price,
      addedAt: orderDate,
    );
  }

  OrderStatus _mapOrderStatus(String state) {
    switch (state) {
      case 'draft':
      case 'sent':
        return OrderStatus.pending;
      case 'sale':
        return OrderStatus.processing;
      case 'done':
        return OrderStatus.delivered;
      case 'cancel':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  PaymentStatus _mapPaymentStatus(String paymentStateOrInvoiceStatus, String alqasehStatus) {
    // Priority 1: Check Al Qaseh payment status (most accurate for Al Qaseh payments)
    if (alqasehStatus.isNotEmpty) {
      final alqasehStatusLower = alqasehStatus.toLowerCase();
      if (alqasehStatusLower == 'succeeded' || 
          alqasehStatusLower == 'success' ||
          alqasehStatusLower == 'successed' ||
          alqasehStatusLower == 'succeed' ||
          alqasehStatusLower == 'successfull') {
        return PaymentStatus.paid;
      } else if (alqasehStatusLower == 'failed' ||
                 alqasehStatusLower == 'declined' ||
                 alqasehStatusLower == 'cancelled') {
        return PaymentStatus.failed;
      }
    }
    
    // Priority 2: Check payment_state from invoice (primary source for payment status)
    // payment_state values: "paid", "not_paid", "partial", "in_payment", "reversed", "refund"
    // Falls back to invoice_status if payment_state is not available
    final statusLower = paymentStateOrInvoiceStatus.toLowerCase();
    switch (statusLower) {
      case 'paid':
        return PaymentStatus.paid;
      case 'refund':
      case 'refunded':
        return PaymentStatus.refunded;
      case 'failed':
        return PaymentStatus.failed;
      case 'not_paid':
      case 'not paid':
      case 'in_payment':
      case 'in payment':
      case 'partial':
      case 'reversed':
        // "not_paid" and other non-paid states map to pending
        return PaymentStatus.pending;
      case 'invoiced':
      case 'to invoice':
        // Legacy invoice_status values - invoice created but not necessarily paid
        return PaymentStatus.pending;
      default:
        // Default to pending for unknown states
        return PaymentStatus.pending;
    }
  }

  String _buildShippingAddress(Map<String, dynamic> partner) {
    final parts = <String>[
      partner['street']?.toString() ?? '',
      partner['street2']?.toString() ?? '',
      partner['city']?.toString() ?? '',
      partner['state']?.toString() ?? '',
      partner['zip']?.toString() ?? '',
      partner['country']?.toString() ?? '',
    ];

    return parts.where((part) => part.trim().isNotEmpty).join(', ');
  }

  String _inferPaymentMethod(Map<String, dynamic> json) {
    final shippingMethod = json['shipping_method'];
    if (shippingMethod is Map<String, dynamic>) {
      final name = shippingMethod['product_name']?.toString();
      if (name != null && name.isNotEmpty) {
        return name;
      }
    }
    return 'Online Payment';
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    final String raw = value.toString();
    if (raw.isEmpty) return null;
    final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized);
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final String raw = value.toString();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw) ?? _parseDateTime(raw)?.toLocal();
  }

  String _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    
    // If already a full URL, return as-is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // Construct full URL from base URL and relative path
    final base = AppConstants.baseUrl;
    
    // Remove trailing slash from base if present
    final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    
    // Ensure path starts with /
    final cleanPath = path.startsWith('/') ? path : '/$path';
    
    return '$cleanBase$cleanPath';
  }

  @override
  Future<DeliveryStatusDto> getDeliveryStatus({required int orderId}) async {
    try {
      // Queued raw GET (no RPC wrapping)
      final response = await apiClient.requestRaw(
        '/ecom/get/delivery-status',
        method: 'GET',
        queryParameters: {
          'order_id': orderId,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerFailure('Unexpected response structure while fetching delivery status');
      }

      // Check for error response
      if (data['status'] == 'error' || response.statusCode != 200) {
        final errorMessage = data['message']?.toString() ?? 
                           'Failed to fetch delivery status (${response.statusCode ?? 'unknown'})';
        
        // If error message indicates missing external UID (backend data issue),
        // this is expected and we should handle it gracefully
        if (errorMessage.toLowerCase().contains('missing external uid') ||
            errorMessage.toLowerCase().contains('external uid')) {
          // Return a delivery status DTO with no tracking page (backend data issue)
          // This allows the UI to show gracefully that tracking is not available
          final errorData = data['data'] as Map<String, dynamic>?;
          if (errorData != null && errorData['order_id'] != null) {
            return DeliveryStatusDto(
              orderId: (errorData['order_id'] as num).toInt(),
              deliveryTransactionId: (errorData['delivery_transaction_id'] as num?)?.toInt() ?? 0,
              status: (errorData['status'] ?? false).toString(),
              trackingPage: null, // No tracking page available due to missing external UID
              lastStatuses: const [],
            );
          }
        }
        
        throw ServerFailure(errorMessage);
      }

      // Extract data from response
      Map<String, dynamic>? deliveryData;
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        deliveryData = data['data'] as Map<String, dynamic>;
      } else if (data.containsKey('result') && data['result'] is Map<String, dynamic>) {
        final result = data['result'] as Map<String, dynamic>;
        deliveryData = result['data'] as Map<String, dynamic>?;
      }

      if (deliveryData == null) {
        throw ServerFailure('Delivery status data not found in response');
      }

      return DeliveryStatusDto.fromJson(deliveryData);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Network error while fetching delivery status');
    } catch (e) {
      throw ServerFailure('Unexpected error while fetching delivery status: $e');
    }
  }
}

