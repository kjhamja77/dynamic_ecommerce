import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import 'package:zalando_clone_app/core/constants/endpoints.dart';
import '../models/coupon_model.dart';

class ShippingMethodDto {
  final int id;
  final String name;
  final double price;

  ShippingMethodDto({required this.id, required this.name, required this.price});

  factory ShippingMethodDto.fromJson(Map<String, dynamic> json) {
    return ShippingMethodDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderTotalsDto {
  final int orderId;
  final double amountUntaxed;
  final double amountTax;
  final double amountTotal;
  final String currencyName;
  final String currencySymbol;
  final double shippingPrice;
  final String? shippingName;
  final double couponDiscountAmount;

  OrderTotalsDto({
    required this.orderId,
    required this.amountUntaxed,
    required this.amountTax,
    required this.amountTotal,
    required this.currencyName,
    required this.currencySymbol,
    required this.shippingPrice,
    this.shippingName,
    this.couponDiscountAmount = 0.0,
  });

  factory OrderTotalsDto.fromJson(Map<String, dynamic> json) {
    final shipping = (json['shipping'] is Map) ? (json['shipping'] as Map) : null;
    final double shippingPrice = (shipping != null && shipping['price'] is num)
        ? (shipping['price'] as num).toDouble()
        : 0.0;
    final String? shippingName = (shipping != null && shipping['name'] != null)
        ? shipping['name'].toString()
        : null;

    return OrderTotalsDto(
      orderId: (json['order_id'] as num).toInt(),
      amountUntaxed: (json['amount_untaxed'] as num).toDouble(),
      amountTax: (json['amount_tax'] as num).toDouble(),
      amountTotal: (json['amount_total'] as num).toDouble(),
      currencyName: (json['currency_name'] ?? '').toString(),
      currencySymbol: (json['currency_symbol'] ?? '').toString(),
      shippingPrice: shippingPrice,
      shippingName: shippingName,
      couponDiscountAmount: (json['coupon_discount_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PaymentMethodDto {
  final int id;
  final String name;
  final int? journalId;
  final String? url;

  PaymentMethodDto({
    required this.id,
    required this.name,
    this.journalId,
    this.url,
  });

  factory PaymentMethodDto.fromJson(Map<String, dynamic> json) {
    // Handle journal_id: can be num, false, or null
    int? journalId;
    final journalIdValue = json['journal_id'];
    if (journalIdValue is num) {
      journalId = journalIdValue.toInt();
    } else if (journalIdValue is bool && journalIdValue == false) {
      journalId = null;
    }
    
    // Handle url: can be empty string or null
    String? url;
    final urlValue = json['url'];
    if (urlValue is String && urlValue.isNotEmpty) {
      url = urlValue;
    }
    
    return PaymentMethodDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      journalId: journalId,
      url: url,
    );
  }
}

class AlQasehPaymentResponse {
  final String paymentUrl;
  final String paymentId;
  final String token;

  AlQasehPaymentResponse({
    required this.paymentUrl,
    required this.paymentId,
    required this.token,
  });

  factory AlQasehPaymentResponse.fromJson(Map<String, dynamic> json) {
    return AlQasehPaymentResponse(
      paymentUrl: json['payment_url'] ?? '',
      paymentId: json['payment_id'] ?? '',
      token: json['token'] ?? '',
    );
  }
}

abstract class CheckoutRemoteDataSource {
  Future<List<ShippingMethodDto>> getShippingMethods({
    required int orderId,
    int? addressId,
  });
  Future<OrderTotalsDto> applyShippingMethod({
    required int orderId,
    required int shippingMethodId,
    double? amount,
  });
  Future<List<Map<String, dynamic>>> getPromoPricelists({required int orderId});
  Future<OrderTotalsDto> applyPromo({required int orderId, required int pricelistId, required String promoCode});
  Future<List<CouponModel>> getCoupons();
  Future<OrderTotalsDto> applyCoupon({
    required int orderId,
    required int couponId,
  });
  Future<OrderTotalsDto> removeCoupon({
    required int orderId,
    required int couponId,
  });
  Future<List<PaymentMethodDto>> getPaymentMethods();
  Future<String> applyPaymentMethod({required int orderId, required int paymentMethodId});
  Future<String> placeOrder({required int orderId, required int addressId});
  Future<AlQasehPaymentResponse> createAlQasehPayment({required int orderId});
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final ApiClient apiClient;
  CheckoutRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ShippingMethodDto>> getShippingMethods({
    required int orderId,
    int? addressId,
  }) async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/get/ShippingMethods',
        method: 'POST',
        params: {
          'order_id': orderId,
          if (addressId != null) 'address_id': addressId,
        },
      );
      if (kDebugMode) {
        // Helpful for verifying which address/order produced which methods
        debugPrint('🟧 getShippingMethods response (order_id=$orderId, address_id=$addressId):');
        debugPrint(response.data.toString());
      }
      final envelope = apiClient.parseRpcEnvelope(response.data);
      final root = envelope.data;
      // Some endpoints return methods under data.shipping_method, others under shipping_method directly.
      final listNode = (root is Map && root['shipping_method'] is List)
          ? root['shipping_method']
          : (root is Map && root['data'] is Map && (root['data'] as Map)['shipping_method'] is List)
              ? (root['data'] as Map)['shipping_method']
              : null;
      if (listNode is List) {
        return (listNode)
            .whereType<Map>()
            .map((e) => ShippingMethodDto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return <ShippingMethodDto>[];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch shipping methods');
    }
  }

  @override
  Future<OrderTotalsDto> applyShippingMethod({
    required int orderId,
    required int shippingMethodId,
    double? amount,
  }) async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/apply/ShippingMethods',
        method: 'POST',
        params: {
          'order_id': orderId,
          'shipping_method_id': shippingMethodId,
          if (amount != null) 'amount': amount,
        },
      );
      final envelope = apiClient.parseRpcEnvelope(response.data);
      if (kDebugMode) {
        debugPrint('🟧 applyShippingMethod response (order_id=$orderId, shipping_method_id=$shippingMethodId, amount = $amount):');
        debugPrint(envelope.data.toString());
      }
      final root = envelope.data;
      final orderNode = (root is Map && root['order_details'] is Map)
          ? root['order_details']
          : (root is Map && root['data'] is Map && (root['data'] as Map)['order_details'] is Map)
              ? (root['data'] as Map)['order_details']
              : null;
      if (orderNode is Map) {
        return OrderTotalsDto.fromJson(Map<String, dynamic>.from(orderNode));
      }
      throw Exception('Invalid response for applyShippingMethod');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to apply shipping method');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPromoPricelists({required int orderId}) async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/get/Pricelists',
        method: 'POST',
        params: { 'order_id': orderId },
      );
      final envelope = apiClient.parseRpcEnvelope(response.data);
      final root = envelope.data;
      debugPrint('📦 getPromoPricelists raw envelope for order $orderId: status=${envelope.status}, message=${envelope.message}, data=${envelope.data}');
      final listNode = (root is Map && root['pricelists'] is List)
          ? root['pricelists']
          : (root is Map && root['data'] is Map && (root['data'] as Map)['pricelists'] is List)
              ? (root['data'] as Map)['pricelists']
              : null;
      if (listNode is List) {
        final mapped = listNode
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        debugPrint('✅ Parsed promo pricelists for order $orderId: $mapped');
        return mapped;
      }
      debugPrint('ℹ️ getPromoPricelists returned empty list for order $orderId (no pricelists key found)');
      return <Map<String, dynamic>>[];
    } on DioException catch (e, s) {
      debugPrint('❌ getPromoPricelists Dio error for order $orderId: $e\n$s');
      throw Exception(e.message ?? 'Failed to fetch promo pricelists');
    }
  }

  @override
  Future<List<CouponModel>> getCoupons() async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.getCoupons,
        method: 'GET',
        params: const {},
      );
      final envelope = apiClient.parseRpcEnvelope(response.data);
      final root = envelope.data;
      debugPrint('🎟️ getCoupons raw envelope: status=${envelope.status}, message=${envelope.message}, data=${envelope.data}');
      final listNode = (root is Map && root['items'] is List)
          ? root['items']
          : (root is Map && root['data'] is Map && (root['data'] as Map)['items'] is List)
              ? (root['data'] as Map)['items']
              : null;
      if (listNode is List) {
        final mapped = listNode
            .whereType<Map>()
            .map((e) => CouponModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        debugPrint('✅ Parsed coupons: $mapped');
        return mapped;
      }
      debugPrint('ℹ️ getCoupons returned empty list (no items key found)');
      return <CouponModel>[];
    } on DioException catch (e, s) {
      debugPrint('❌ getCoupons Dio error: $e\n$s');
      throw Exception(e.message ?? 'Failed to fetch coupons');
    }
  }

  @override
  Future<OrderTotalsDto> applyCoupon({
    required int orderId,
    required int couponId,
  }) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.applyCoupon,
        method: 'POST',
        params: {
          'order_id': orderId,
          'coupon_id': couponId,
        },
      );

      final data = response.data;
      Map<String, dynamic>? orderNode;

      if (data is Map<String, dynamic>) {
        final result = data['result'];
        if (result is Map<String, dynamic>) {
          final resultData = result['data'];
          if (resultData is Map<String, dynamic>) {
            final order = resultData['order'];
            if (order is Map<String, dynamic>) {
              orderNode = order;
            }
          }
        }
      }

      if (orderNode == null) {
        throw Exception('Invalid response for applyCoupon');
      }

      return OrderTotalsDto.fromJson(orderNode);
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to apply coupon');
    }
  }

  @override
  Future<OrderTotalsDto> removeCoupon({
    required int orderId,
    required int couponId,
  }) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.removeCoupon,
        method: 'POST',
        params: {
          'order_id': orderId,
          'coupon_id': couponId,
        },
      );

      final data = response.data;
      Map<String, dynamic>? orderNode;

      if (data is Map<String, dynamic>) {
        final result = data['result'];
        if (result is Map<String, dynamic>) {
          final resultData = result['data'];
          if (resultData is Map<String, dynamic>) {
            final order = resultData['order'];
            if (order is Map<String, dynamic>) {
              orderNode = order;
            }
          }
        }
      }

      if (orderNode == null) {
        throw Exception('Invalid response for removeCoupon');
      }

      return OrderTotalsDto.fromJson(orderNode);
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to remove coupon');
    }
  }

  @override
  Future<OrderTotalsDto> applyPromo({required int orderId, required int pricelistId, required String promoCode}) async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/apply/Pricelist',
        method: 'POST',
        params: {
          'order_id': orderId,
          'pricelist_id': pricelistId,
          'promo_code': promoCode,
        },
      );
      final envelope = apiClient.parseRpcEnvelope(response.data);
      final root = envelope.data;
      final orderNode = (root is Map && root['order_details'] is Map)
          ? root['order_details']
          : (root is Map && root['data'] is Map && (root['data'] as Map)['order_details'] is Map)
              ? (root['data'] as Map)['order_details']
              : null;
      if (orderNode is Map) {
        return OrderTotalsDto.fromJson(Map<String, dynamic>.from(orderNode));
      }
      throw Exception('Invalid response for applyPromo');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to apply promo code');
    }
  }

  @override
  Future<List<PaymentMethodDto>> getPaymentMethods() async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/get/PaymentMethods',
        method: 'GET',
      );
      final envelope = apiClient.parseRpcEnvelope(response.data);
      final root = envelope.data;
      final listNode = (root is Map && root['payment_method'] is List)
          ? root['payment_method']
          : (root is Map && root['data'] is Map && (root['data'] as Map)['payment_method'] is List)
              ? (root['data'] as Map)['payment_method']
              : null;
      if (listNode is List) {
        return listNode
            .whereType<Map>()
            .map((e) => PaymentMethodDto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return <PaymentMethodDto>[];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch payment methods');
    }
  }

  @override
  Future<String> applyPaymentMethod({required int orderId, required int paymentMethodId}) async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/apply/PaymentMethod',
        method: 'POST',
        params: {
          'order_id': orderId,
          'payment_method_id': paymentMethodId,
        },
      );
      final envelope = apiClient.parseRpcEnvelope(response.data);
      if (envelope.status.toLowerCase() != 'success') {
        throw Exception(envelope.message ?? 'Failed to apply payment method');
      }
      return envelope.message ?? 'Payment method applied successfully';
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to apply payment method');
    }
  }

  @override
  Future<String> placeOrder({required int orderId, required int addressId}) async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/sale/placeOrder',
        method: 'POST',
        params: {
          'order_id': orderId,
          'address_id': addressId,
        },
      );
      final envelope = apiClient.parseRpcEnvelope(response.data);
      if (envelope.status.toLowerCase() != 'success') {
        throw Exception(envelope.message ?? 'Failed to place order');
      }
      final data = envelope.data;
      if (data is Map) {
        // Try multiple possible keys for order reference/number
        final orderRef = data['order_name'] ?? 
                        data['order_reference'] ?? 
                        data['order_number'] ??
                        data['name'] ??
                        data['order_id'];
        if (orderRef != null) {
          final orderRefString = orderRef.toString().trim();
          // Only return if it looks like an order number (not a success message)
          if (orderRefString.isNotEmpty && 
              !orderRefString.toLowerCase().contains('successfully') &&
              !orderRefString.toLowerCase().contains('placed') &&
              !orderRefString.toLowerCase().contains('confirm')) {
            return orderRefString;
          }
        }
        // Fallback: try to extract order ID if available
        if (data['order_id'] != null) {
          return data['order_id'].toString();
        }
      }
      // Last resort: return empty string so UI can handle it
      return '';
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to place order');
    }
  }

  @override
  Future<AlQasehPaymentResponse> createAlQasehPayment({required int orderId}) async {
    try {
      // The backend endpoint uses JSON-RPC format
      final response = await apiClient.requestRpc(
        '/api/alqaseh/create_payment',
        method: 'POST',
        params: {
          'order_id': orderId,
        },
      );

      // Al Qaseh response is in JSON-RPC format: {"jsonrpc": "2.0", "id": null, "result": {...}}
      final responseData = response.data;
      Map<String, dynamic>? paymentData;
      
      if (responseData is Map<String, dynamic>) {
        // Check for JSON-RPC format
        if (responseData.containsKey('result')) {
          final result = responseData['result'];
          if (result is Map<String, dynamic>) {
            // Check if result has error
            if (result.containsKey('error')) {
              final error = result['error'];
              if (error is String) {
                throw Exception(error);
              } else if (error is Map && error.containsKey('message')) {
                throw Exception(error['message']?.toString() ?? 'Failed to create payment');
              }
              throw Exception('Payment creation failed');
            }
            // Payment data is directly in result
            paymentData = result;
          }
        } else if (responseData.containsKey('error')) {
          // Direct error in response
          throw Exception(responseData['error']?.toString() ?? 'Failed to create payment');
        } else {
          // Try to use response data directly (fallback)
          paymentData = responseData;
        }
      } else {
        throw Exception('Invalid response format: expected map but got ${responseData.runtimeType}');
      }

      if (paymentData == null) {
        throw Exception('Payment data is missing from response');
      }

      // Validate required fields
      if (!paymentData.containsKey('payment_url') || 
          paymentData['payment_url'] == null || 
          paymentData['payment_url'].toString().isEmpty) {
        throw Exception('Payment URL is missing from response');
      }

      return AlQasehPaymentResponse.fromJson(paymentData);
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final errorData = e.response!.data as Map<String, dynamic>;
        
        // Check for JSON-RPC error format
        if (errorData.containsKey('result')) {
          final result = errorData['result'];
          if (result is Map && result.containsKey('error')) {
            throw Exception(result['error']?.toString() ?? 'Failed to create payment');
          }
        }
        
        // Check for direct error fields
        if (errorData.containsKey('error')) {
          throw Exception(errorData['error']?.toString() ?? 'Failed to create payment');
        }
        if (errorData.containsKey('message')) {
          throw Exception(errorData['message']?.toString() ?? 'Failed to create payment');
        }
      }
      throw Exception(e.message ?? 'Failed to create payment');
    }
  }
}


