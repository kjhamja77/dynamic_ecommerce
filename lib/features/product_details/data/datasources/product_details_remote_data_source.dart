import 'dart:developer' as developer;
import 'package:zalando_clone_app/core/network/api_client.dart';
import '../../../../core/constants/endpoints.dart';

abstract class ProductDetailsRemoteDataSource {
  Future<Map<String, dynamic>> getProductDetails(String productId, {String productType = 'variant'});
}

class ProductDetailsRemoteDataSourceImpl implements ProductDetailsRemoteDataSource {
  final ApiClient apiClient;

  ProductDetailsRemoteDataSourceImpl(this.apiClient);
  
  @override
  Future<Map<String, dynamic>> getProductDetails(String productId, {String productType = 'variant'}) async {
    developer.log('🌐 RemoteDataSource: Fetching product details for ID: $productId, type: $productType');
    
    try {
      // API expects a unified payload: { id: <int>, type: '<template|variant>' }
      final params = <String, dynamic>{
        'id': int.parse(productId),
        'type': productType,
      };

      final response = await apiClient.requestRpc(
        Endpoints.getProduct,
        method: 'POST',
        params: params,
      );

      developer.log('🌐 API Response Status: ${response.statusCode}');
      developer.log('🌐 API Response Body: ${response.data}');

      final body = response.data;
      if (body is Map && body['result'] is Map) {
        final result = body['result'] as Map;
        final status = (result['status'] ?? '').toString().toLowerCase();
        
        if (status == 'error') {
          developer.log('❌ API returned error: ${result['message']}');
          throw Exception((result['message'] ?? 'Failed to get product').toString());
        }

        if (result['data'] is Map) {
          final productData = result['data'] as Map<String, dynamic>;
          developer.log('🌐 Extracted product data: $productData');
          return productData;
        }
      }

      developer.log('❌ Invalid API response structure');
      throw Exception('Invalid API response structure');
    } catch (e) {
      developer.log('❌ Error fetching product details: $e');
      rethrow;
    }
  }
}

