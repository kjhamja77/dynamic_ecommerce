import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:zalando_clone_app/core/network/api_client.dart';
import '../../../../core/constants/endpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_profile_model.dart';
import '../models/user_order_model.dart';
import '../../domain/entities/user_order.dart';
import 'profile_remote_data_source.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient api;

  ProfileRemoteDataSourceImpl(this.api);

  /// Converts a local image file to base64 string
  Future<String?> _convertImageToBase64(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    try {
      // If it's an existing network URL or already a data URL from the backend,
      // we don't re-send it as part of the update payload. The backend expects
      // a raw base64 string (no "data:image/..." prefix) only when the client
      // is uploading a new image. Returning null here will cause us to send an
      // empty string and let the server keep the current image.
      if (imagePath.startsWith('http://') ||
          imagePath.startsWith('https://') ||
          imagePath.startsWith('data:image/')) {
        return null;
      }
      
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('Image file does not exist: $imagePath');
        return null;
      }
      
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      // Backend expects plain base64 content (no data URI prefix)
      return base64String;
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      return null;
    }
  }
  
  /// Get MIME type based on file extension
  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg'; // Default to JPEG
    }
  }

  @override
  Future<UserProfileModel> getUserProfile() async {
    try {
      final Response resp = await api.requestRpc(Endpoints.getUserProfile);
      final envelope = api.parseRpcEnvelope(resp.data);
      if (envelope.status != 'success') {
        throw Exception(envelope.message ?? 'Failed to get user profile');
      }
      final data = envelope.data as Map<String, dynamic>?;
      final list = (data?['user_profile'] as List?)?.cast<dynamic>() ?? const [];
      if (list.isEmpty) {
        throw Exception('User profile not found');
      }
      final profileJson = list.first as Map<String, dynamic>;
      return UserProfileModel.fromApiJson(profileJson);
    } catch (e, s) {
      debugPrint('ProfileRemoteDataSourceImpl.getUserProfile error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      final params = <String, dynamic>{
        'action': 'update',
        'name': profile.name,
      };

      // Add optional fields if they exist
      if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) {
        // Ensure phone is sent with country code
        params['phone'] = profile.phoneNumber;
      }

      // Parse address components if address string exists
      if (profile.address != null && profile.address!.isNotEmpty) {
        final addressParts = profile.address!.split(',');
        if (addressParts.isNotEmpty) {
          params['street'] = addressParts[0].trim();
        }
        if (addressParts.length > 1) {
          params['city'] = addressParts[1].trim();
        }
        if (addressParts.length > 2) {
          params['zip'] = addressParts[2].trim();
        }
      }

      // Convert image to base64 if provided
      if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
        final base64Image = await _convertImageToBase64(profile.avatarUrl);
        params['image'] = base64Image ?? ''; // Use base64 or empty string
        debugPrint('Profile update: Image converted to base64: ${base64Image != null ? 'Yes' : 'No'}');
      } else {
        params['image'] = ''; // Empty string as per API spec
      }

      // Debug log the parameters being sent
      debugPrint('Profile update params: $params');
      
      final Response resp = await api.requestRpc(
        Endpoints.getUserProfile,
        method: 'POST',
        params: params,
      );

      final envelope = api.parseRpcEnvelope(resp.data);
      if (envelope.status != 'success') {
        throw Exception(envelope.message ?? 'Failed to update user profile');
      }

      // After successful update, fetch the updated profile
      return await getUserProfile();
    } catch (e, s) {
      debugPrint('ProfileRemoteDataSourceImpl.updateUserProfile error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<List<UserOrderModel>> getUserOrders() async {
    try {
      // Call the same orderHistory endpoint used by orders feature
      final response = await api.requestRaw(
        '/ecom/sale/orderHistory',
        method: 'GET',
        queryParameters: {
          'page': 1,
          'limit': 100, // Get all orders for count
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Unexpected response structure while fetching order history');
      }

      // Check for error response
      if (data['status'] == 'error' || response.statusCode != 200) {
        final errorMessage = data['message']?.toString() ?? 
                           'Failed to fetch order history (${response.statusCode ?? 'unknown'})';
        throw Exception(errorMessage);
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
        return const <UserOrderModel>[];
      }

      // Map API response to UserOrderModel
      return ordersList
          .whereType<Map<String, dynamic>>()
          .map((rawOrder) => _mapToUserOrder(rawOrder))
          .toList();
    } on DioException catch (e) {
      debugPrint('ProfileRemoteDataSourceImpl.getUserOrders DioException: $e');
      throw Exception('Network error while fetching order history: ${e.message}');
    } catch (e, s) {
      debugPrint('ProfileRemoteDataSourceImpl.getUserOrders error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  UserOrderModel _mapToUserOrder(Map<String, dynamic> json) {
    final int rawId = (json['id'] ?? 0) is String
        ? int.tryParse(json['id'] as String) ?? 0
        : (json['id'] as num?)?.toInt() ?? 0;
    final String id = rawId.toString();

    final String orderNumber = (json['name'] ?? '').toString();
    final String state = (json['state'] ?? '').toString().toLowerCase();
    final String currency = (json['currency'] ?? 'IQD').toString();
    
    final DateTime orderDate = _parseDateTime(json['date_order']) ?? DateTime.now();
    final DateTime? validityDate = _parseDate(json['validity_date']);

    // Map order status
    final OrderStatus status = _mapOrderStatus(state);

    // Map order lines to order items
    final List<dynamic> orderLines = (json['order_lines'] as List<dynamic>?) ?? const <dynamic>[];
    final List<OrderItemModel> items = orderLines
        .whereType<Map<String, dynamic>>()
        .map((line) => _mapOrderLineToItem(line))
        .toList();

    // Get delivery status as tracking number if available
    final String? trackingNumber = json['delivery_status']?.toString();

    return UserOrderModel(
      id: id,
      orderNumber: orderNumber.isEmpty ? 'ORDER-$id' : orderNumber,
      orderDate: orderDate,
      status: status,
      totalAmount: (json['amount_total'] as num?)?.toDouble() ?? 0.0,
      currency: currency,
      items: items,
      trackingNumber: trackingNumber?.isNotEmpty == true ? trackingNumber : null,
      estimatedDelivery: validityDate,
      notes: null,
    );
  }

  OrderItemModel _mapOrderLineToItem(Map<String, dynamic> line) {
    final String itemId = (line['id'] ?? '').toString();
    final String productId = (line['product_id'] ?? line['product_template_id'] ?? itemId).toString();
    final String name = (line['product_name'] ?? line['product_template_name'] ?? '').toString();
    final double price = (line['price_unit'] as num?)?.toDouble() ?? 0.0;
    final int quantity = ((line['product_uom_qty'] as num?)?.round()) ?? 1;
    
    // Try to get image from product_image
    String? imageUrl;
    final productImage = line['product_image']?.toString();
    if (productImage != null && productImage.isNotEmpty && productImage != 'null') {
      imageUrl = _resolveImageUrl(productImage);
    }

    return OrderItemModel(
      id: itemId,
      productId: productId,
      productName: name.isEmpty ? 'Product $productId' : name,
      productImage: imageUrl?.isNotEmpty == true ? imageUrl : null,
      quantity: quantity,
      unitPrice: price,
      size: (line['size'] ?? '').toString().isNotEmpty ? (line['size'] ?? '').toString() : null,
      color: (line['color'] ?? '').toString().isNotEmpty ? (line['color'] ?? '').toString() : null,
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
  Future<UserOrderModel> getOrderDetails(String orderId) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    return UserOrderModel(
      id: orderId,
      orderNumber: 'ORD-$orderId',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      status: OrderStatus.delivered,
      totalAmount: 129.99,
      currency: 'USD',
      items: [
        OrderItemModel(
          id: '1',
          productId: 'prod-1',
          productName: 'Nike Air Max',
          productImage: null,
          quantity: 1,
          unitPrice: 129.99,
          size: '42',
          color: 'Black',
        ),
      ],
      trackingNumber: 'TRK123456789',
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 2)),
      notes: null,
    );
  }

  @override
  Future<void> logout() async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> deleteAccount() async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
  }
}
