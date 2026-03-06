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

  /// Returns the value to send in the 'image' key for update profile API (always raw base64 or empty).
  Future<String> _imageValueForUpdateApi(String? avatarUrl) async {
    if (avatarUrl == null || avatarUrl.trim().isEmpty) return '';
    final s = avatarUrl.trim();
    if (s.startsWith('http://') || s.startsWith('https://')) return '';
    if (s.toLowerCase().startsWith('data:image/') && s.contains(',')) {
      final payload = s.split(',').last.trim();
      if (payload.isNotEmpty) {
        debugPrint('Profile update: Using base64 from data URI, length=${payload.length}');
        return payload;
      }
      return '';
    }
    if (s.length > 100 && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(s.replaceAll(RegExp(r'\s'), ''))) {
      debugPrint('Profile update: Using avatarUrl as raw base64, length=${s.length}');
      return s;
    }
    final fromFile = await _convertImageToBase64(s);
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;
    return '';
  }

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

  /// Summarizes a value for debug (type + length, no huge payloads).
  void _printValueSummary(String key, dynamic value) {
    if (value == null) {
      debugPrint('    $key: null');
      return;
    }
    if (value is String) {
      debugPrint('    $key: String, length=${value.length}${value.isEmpty ? " (empty)" : ", preview: ${value.length > 50 ? "${value.substring(0, 50)}..." : value}"}');
      return;
    }
    if (value is List) {
      debugPrint('    $key: List, length=${value.length}');
      if (value.isNotEmpty && value.first is Map) {
        debugPrint('      first item keys: ${(value.first as Map).keys.toList()}');
      }
      return;
    }
    if (value is Map) {
      debugPrint('    $key: Map, keys: ${(value as Map).keys.toList()}');
      return;
    }
    debugPrint('    $key: ${value.runtimeType}, value: $value');
  }

  @override
  Future<UserProfileModel> getUserProfile() async {
    try {
      final Response resp = await api.requestRpc(Endpoints.getUserProfile);
      debugPrint('full response form the get user profile ${resp.data}');
      final envelope = api.parseRpcEnvelope(resp.data);

      // --- PRINT TOTAL GET USER PROFILE RESPONSE ---
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('GET USER PROFILE - total response:');
      debugPrint('  envelope.status: ${envelope.status}');
      debugPrint('  envelope.message: ${envelope.message}');
      final data = envelope.data;
      if (data == null) {
        debugPrint('  envelope.data: null');
      } else if (data is Map<String, dynamic>) {
        debugPrint('  envelope.data keys: ${data.keys.toList()}');
        for (final k in data.keys) {
          _printValueSummary(k, data[k]);
        }
      } else {
        debugPrint('  envelope.data: ${data.runtimeType}');
      }
      debugPrint('═══════════════════════════════════════════════════════════');

      if (envelope.status != 'success') {
        throw Exception(envelope.message ?? 'Failed to get user profile');
      }
      final dataMap = envelope.data as Map<String, dynamic>?;
      final list = (dataMap?['user_profile'] as List?)?.cast<dynamic>() ?? const [];
      if (list.isEmpty) {
        debugPrint('ProfileRemoteDataSourceImpl.getUserProfile: user_profile list is empty. data keys: ${dataMap?.keys.toList()}');
        throw Exception('User profile not found');
      }
      // Merge data-level fields with first profile so we get "image" from either place
      final firstProfile = list.first as Map<String, dynamic>;
      final profileJson = Map<String, dynamic>.from(dataMap ?? {})
        ..addAll(Map<String, dynamic>.from(firstProfile));

      // --- VALIDATION: Check whether we are getting image from API or not ---
      final rawImage = profileJson['image'];
      final hasImageKey = profileJson.containsKey('image');
      final imageIsNull = rawImage == null;
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('IMAGE VALIDATION (get user profile):');
      debugPrint('  key "image" present: $hasImageKey');
      debugPrint('  value is null: $imageIsNull');
      if (rawImage != null) {
        debugPrint('  value type: ${rawImage.runtimeType}');
        if (rawImage is String) {
          debugPrint('  value length: ${rawImage.length}');
          debugPrint('  value preview: ${rawImage.length > 60 ? "${rawImage.substring(0, 60)}..." : rawImage}');
        } else if (rawImage is List) {
          debugPrint('  value length (list): ${rawImage.length}');
        }
      } else {
        debugPrint('  → image url from API is null (key missing or value null).');
        debugPrint('  Available keys in merged profile: ${profileJson.keys.toList()}');
      }
      debugPrint('───────────────────────────────────────────────────────────');

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

      // Always send email if provided
      if (profile.email.isNotEmpty) {
        params['email'] = profile.email;
        debugPrint('Profile update: Email: ${profile.email}');
      }

      // Always send phone number (can be null/empty to clear it)
      // Normalize to national digits only (no country code prefix) using profile.countryCode when available.
      final rawPhone = profile.phoneNumber ?? '';
      final rawCode = profile.countryCode ?? '';
      final digitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
      String nationalPhone = digitsOnly;
      final ccDigits = rawCode.replaceAll(RegExp(r'[^0-9]'), '');
      if (ccDigits.isNotEmpty && nationalPhone.startsWith(ccDigits)) {
        nationalPhone = nationalPhone.substring(ccDigits.length);
      }
      params['phone'] = nationalPhone;
      debugPrint('Profile update: Phone (normalized): $nationalPhone (raw="$rawPhone", country="$rawCode")');

      // Always send country code (can be null/empty to clear it)
      params['country_code'] = rawCode;
      debugPrint('Profile update: Country code: ${rawCode.isEmpty ? "empty" : rawCode}');

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

      // Always send avatar/image to update profile API (backend may expect 'image' or 'avatar_url')
      final String imageValueForApi = await _imageValueForUpdateApi(profile.avatarUrl);
      params['image'] = imageValueForApi;
      params['avatar_url'] = imageValueForApi;
      debugPrint('Profile update: image/avatar_url sent, length=${imageValueForApi.length}');
      if (imageValueForApi.isNotEmpty) {
        debugPrint('🟢 [SAVE] IMAGE SENT in keys "image" and "avatar_url": base64 length=${imageValueForApi.length}');
      } else {
        debugPrint('🟢 [SAVE] IMAGE SENT in keys "image" and "avatar_url": (empty)');
      }

      // Debug log the parameters being sent (omit full base64 to avoid log flood)
      debugPrint('Profile update params keys: ${params.keys.toList()}, image param length: ${params['image'] is String ? (params['image'] as String).length : 0}');
      
      final Response resp = await api.requestRpc(
        Endpoints.getUserProfile,
        method: 'POST',
        params: params,
      );
      print('full response from the update user profile ${resp.data}');

      final envelope = api.parseRpcEnvelope(resp.data);
      if (envelope.status != 'success') {
        throw Exception(envelope.message ?? 'Failed to update user profile');
      }

      debugPrint('ProfileRemoteDataSourceImpl: Update API call successful');
      debugPrint('ProfileRemoteDataSourceImpl: Fetching updated profile...');

      // After successful update, fetch the updated profile
      final updatedProfile = await getUserProfile();

      debugPrint('ProfileRemoteDataSourceImpl: Updated profile fetched');
      debugPrint('ProfileRemoteDataSourceImpl: Updated profile - Name: ${updatedProfile.name}');
      debugPrint('ProfileRemoteDataSourceImpl: Updated profile - Email: ${updatedProfile.email}');
      debugPrint('ProfileRemoteDataSourceImpl: Updated profile - Phone: ${updatedProfile.phoneNumber}');
      debugPrint('ProfileRemoteDataSourceImpl: Updated profile - Country Code: ${updatedProfile.countryCode}');
      // --- DEBUG: Image URL from GET USER PROFILE (after save) ---
      if (updatedProfile.avatarUrl == null || updatedProfile.avatarUrl!.isEmpty) {
        debugPrint('🟡 [GET USER PROFILE after SAVE] image url (avatarUrl): null or empty');
      } else {
        final av = updatedProfile.avatarUrl!;
        debugPrint('🟡 [GET USER PROFILE after SAVE] image url (avatarUrl): length=${av.length}, preview: ${av.length > 80 ? "${av.substring(0, 80)}..." : av}');
      }
      // --- END DEBUG ---
      
      return updatedProfile;
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
    final String orderStatusLabel =
        (json['order_status'] ?? '').toString().toLowerCase();
    final String currency = (json['currency'] ?? 'IQD').toString();
    
    final DateTime orderDate = _parseDateTime(json['date_order']) ?? DateTime.now();
    final DateTime? validityDate = _parseDate(json['validity_date']);

    // Map order status, preferring business-level order_status when available
    final OrderStatus status = _mapOrderStatus(
      orderStatusLabel.isNotEmpty ? orderStatusLabel : state,
    );

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

  OrderStatus _mapOrderStatus(String rawStatus) {
    final state = rawStatus.toLowerCase().trim();
    switch (state) {
      // Pending / draft
      case 'draft':
      case 'sent':
      case 'pending':
        return OrderStatus.pending;

      // Confirmed
      case 'confirmed':
      case 'confirm':
      case 'order confirmed':
        return OrderStatus.confirmed;

      // Processing / in progress / sale
      case 'sale':
      case 'processing':
      case 'in progress':
      case 'in_progress':
        return OrderStatus.processing;

      // Shipped / in transit
      case 'shipped':
      case 'in_transit':
      case 'in transit':
        return OrderStatus.shipped;

      // Delivered / completed / done
      case 'done':
      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;

      // Cancelled
      case 'cancel':
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;

      // Returned
      case 'returned':
      case 'return':
        return OrderStatus.returned;

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
