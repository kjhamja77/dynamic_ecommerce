import 'package:dio/dio.dart';
import '../../../../core/constants/endpoints.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import '../models/product_model.dart';
import '../models/product_list_response_model.dart';
import '../models/product_category_model.dart';
import 'product_remote_data_source.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ProductModel> getProductById({
    required int productId,
    required String type,
    int? templateId,
  }) async {
    try {
      final params = <String, dynamic>{
        'product_id': productId,
        'type': type,
      };

      if (templateId != null) {
        params['template_id'] = templateId;
      }

      final response = await apiClient.requestRpc(
        Endpoints.getProduct,
        method: 'POST',
        params: params,
      );

      final body = response.data;
      if (body is Map && body['result'] is Map) {
        final result = body['result'] as Map;
        final status = (result['status'] ?? '').toString().toLowerCase();
        
        if (status == 'error') {
          throw Exception((result['message'] ?? 'Failed to get product').toString());
        }

        if (result['data'] is Map) {
          return ProductModel.fromJson(result['data'] as Map<String, dynamic>);
        }
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : e.message ?? 'Failed to get product';
      throw Exception(msg);
    }
  }

  @override
  Future<ProductListResponseModel> getProductList({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.getProduct,
        method: 'POST',
        params: {
          'limit': limit,
          'offset': offset,
        },
      );

      final body = response.data;
      if (body is Map && body['result'] is Map) {
        final result = body['result'] as Map;
        final status = (result['status'] ?? '').toString().toLowerCase();
        
        if (status == 'error') {
          throw Exception((result['message'] ?? 'Failed to get product list').toString());
        }

        if (result['data'] is Map) {
          return ProductListResponseModel.fromJson(result['data'] as Map<String, dynamic>);
        }
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : e.message ?? 'Failed to get product list';
      throw Exception(msg);
    }
  }

  @override
  Future<ProductListResponseModel> getProductsByCategory({
    required List<int> categoryIds,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      print('🌐 ProductRemoteDataSource: Making API call to ${Endpoints.getProduct}');
      print('📋 ProductRemoteDataSource: Params: public_categ_ids=$categoryIds, limit=$limit, offset=$offset');
      
      final response = await apiClient.requestRpc(
        Endpoints.getProduct,
        method: 'POST',
        params: {
          'public_categ_ids': categoryIds,
          'limit': limit,
          'offset': offset,
        },
      );
      
      print('📡 ProductRemoteDataSource: Response received: ${response.statusCode}');

      final body = response.data;
      if (body is Map && body['result'] is Map) {
        final result = body['result'] as Map;
        final status = (result['status'] ?? '').toString().toLowerCase();
        
        if (status == 'error') {
          throw Exception((result['message'] ?? 'Failed to get products by category').toString());
        }

        if (result['data'] is Map) {
          final data = result['data'] as Map<String, dynamic>;
          final products = data['products'] as List<dynamic>? ?? [];
          print('🎉 ProductRemoteDataSource: Success! Found ${products.length} products');
          return ProductListResponseModel.fromJson(data);
        }
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : e.message ?? 'Failed to get products by category';
      throw Exception(msg);
    }
  }

  @override
  Future<ProductListResponseModel> searchProducts({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.getProduct,
        method: 'POST',
        params: {
          'search': query,
          'limit': limit,
          'offset': offset,
        },
      );

      final body = response.data;
      if (body is Map && body['result'] is Map) {
        final result = body['result'] as Map;
        final status = (result['status'] ?? '').toString().toLowerCase();
        
        if (status == 'error') {
          throw Exception((result['message'] ?? 'Failed to search products').toString());
        }

        if (result['data'] is Map) {
          return ProductListResponseModel.fromJson(result['data'] as Map<String, dynamic>);
        }
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : e.message ?? 'Failed to search products';
      throw Exception(msg);
    }
  }

  @override
  Future<List<ProductCategoryModel>> getRootCategories({
    int maxDepth = 1,
  }) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.getProductCategory,
        method: 'POST',
        params: {
          'max_depth': maxDepth,
        },
      );

      final body = response.data;
      if (body is Map && body['result'] is Map) {
        final result = body['result'] as Map;
        final status = (result['status'] ?? '').toString().toLowerCase();
        
        if (status == 'error') {
          throw Exception((result['message'] ?? 'Failed to get root categories').toString());
        }

        // Handle both direct array and items array formats
        dynamic categoriesData;
        if (result['data'] is List) {
          categoriesData = result['data'];
        } else if (result['data'] is Map && result['data']['items'] is List) {
          categoriesData = result['data']['items'];
        }
        
        if (categoriesData is List) {
          final categories = categoriesData
              .map((json) => ProductCategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
          return categories;
        }
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : e.message ?? 'Failed to get root categories';
      throw Exception(msg);
    }
  }

  @override
  Future<List<ProductCategoryModel>> getCategoriesByParentId({
    required int parentId,
    int maxDepth = 1,
  }) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.getProductCategory,
        method: 'POST',
        params: {
          'parent_id': parentId,
          'max_depth': maxDepth,
        },
      );

      final body = response.data;
      if (body is Map && body['result'] is Map) {
        final result = body['result'] as Map;
        final status = (result['status'] ?? '').toString().toLowerCase();
        
        if (status == 'error') {
          throw Exception((result['message'] ?? 'Failed to get categories by parent ID').toString());
        }

        // Handle both direct array and items array formats
        dynamic categoriesData;
        if (result['data'] is List) {
          categoriesData = result['data'];
        } else if (result['data'] is Map && result['data']['items'] is List) {
          categoriesData = result['data']['items'];
        }
        
        if (categoriesData is List) {
          return categoriesData
              .map((json) => ProductCategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : e.message ?? 'Failed to get categories by parent ID';
      throw Exception(msg);
    }
  }

  @override
  Future<List<ProductCategoryModel>> getAllCategories({
    int maxDepth = 1,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.getProductCategory,
        method: 'POST',
        params: {
          'max_depth': maxDepth,
          'limit': limit,
          'offset': offset,
        },
      );

      final body = response.data;
      if (body is Map && body['result'] is Map) {
        final result = body['result'] as Map;
        final status = (result['status'] ?? '').toString().toLowerCase();
        
        if (status == 'error') {
          throw Exception((result['message'] ?? 'Failed to get all categories').toString());
        }

        // Handle both direct array and items array formats
        dynamic categoriesData;
        if (result['data'] is List) {
          categoriesData = result['data'];
        } else if (result['data'] is Map && result['data']['items'] is List) {
          categoriesData = result['data']['items'];
        }
        
        if (categoriesData is List) {
          return categoriesData
              .map((json) => ProductCategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : e.message ?? 'Failed to get all categories';
      throw Exception(msg);
    }
  }
}


