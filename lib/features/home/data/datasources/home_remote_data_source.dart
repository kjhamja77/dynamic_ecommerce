import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/endpoints.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import '../../../../core/services/language_service.dart';
import '../models/page_model.dart';
import '../models/component_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<PageModel>> getPages(int userId);
  Future<PageComponentsModel> getPageComponents(int componentId, int page, int pageSize);
  Future<List<String>> getWelcomeTexts();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<PageModel>> getPages(int userId) async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.getPages,
        method: 'POST',
        params: {
          'user_id': userId,
        },
      );

      final body = response.data;
      if (body is Map && body['result'] is Map) {
        final result = body['result'] as Map;
        final status = (result['status'] ?? '').toString().toLowerCase();
        
        if (status == 'error') {
          throw Exception((result['message'] ?? 'Failed to get pages').toString());
        }

        if (result['data'] is Map && (result['data'] as Map)['pages'] is List) {
          final data = result['data'] as Map;
          final pagesData = data['pages'] as List;
          return pagesData
              .map((pageJson) => PageModel.fromJson(Map<String, dynamic>.from(pageJson as Map)))
              .toList();
        }
      }

      // Fallback for non-RPC or different success structure
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body is List) {
          return body
              .map((pageJson) => PageModel.fromJson(Map<String, dynamic>.from(pageJson as Map)))
              .toList();
        }
      }

      throw Exception('Failed to get pages: Unexpected response format.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to get pages: ${e.toString()}');
    }
  }

  @override
  Future<PageComponentsModel> getPageComponents(int componentId, int page, int pageSize) async {
    try {
      // Ensure Accept-Language header is set before making the request
      // The ApiClient interceptor will add it automatically, but we verify it's available
      final apiLang = await LanguageService().getApiLanguageCode();
      debugPrint('🌐 HomeRemoteDataSource:getPageComponents → API Language: $apiLang, componentId: $componentId');
      
      final response = await apiClient.requestRpc(
        Endpoints.getPageComponents,
        method: 'POST',
        params: {
          'component_id': componentId,
          'page': page,
          'page_size': pageSize,
        },
      );

      final body = response.data;
      if (body is Map && body['result'] is Map) {
        final result = body['result'] as Map;
        final status = (result['status'] ?? '').toString().toLowerCase();
        
        if (status == 'error') {
          throw Exception((result['message'] ?? 'Failed to get page components').toString());
        }

        if (result['data'] is Map) {
          return PageComponentsModel.fromJson(Map<String, dynamic>.from(result['data'] as Map));
        }
      }

      // Fallback for non-RPC or different success structure
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body is Map) {
          return PageComponentsModel.fromJson(Map<String, dynamic>.from(body));
        }
      }

      throw Exception('Failed to get page components: Unexpected response format.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to get page components: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getWelcomeTexts() async {
    // Retry logic for welcome texts endpoint (sometimes times out)
    int maxRetries = 2;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        if (retryCount > 0) {
          print('🔄 HomeRemoteDataSource: Retrying welcome texts request (attempt ${retryCount + 1}/$maxRetries)');
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount * 1));
        }

        print('🌐 HomeRemoteDataSource: POST ${Endpoints.getWelcomeMessage}');
      final response = await apiClient.requestRpc(
        Endpoints.getWelcomeMessage,
        method: 'POST',
        params: const {},
      );

        print('📡 HomeRemoteDataSource: Welcome texts response status: ${response.statusCode}');
      final body = response.data;

      if (body is Map && body['result'] is Map) {
        final result = body['result'] as Map;
        final status = (result['status'] ?? '').toString().toLowerCase();
        if (status == 'error') {
            final errorMsg = (result['message'] ?? 'Failed to get welcome text').toString();
            print('❌ HomeRemoteDataSource: API returned error: $errorMsg');
            throw Exception(errorMsg);
        }
        if (result['data'] is Map && (result['data'] as Map)['welcome_text'] is List) {
          final list = (result['data'] as Map)['welcome_text'] as List;
          
          // Create a list of welcome text items with sequence information
          final welcomeTextItems = list
              .map((e) {
                if (e is Map && e['name'] != null) {
                  return {
                    'name': e['name'].toString(),
                    'sequence': e['sequence'] ?? e['id'] ?? 0, // Fallback to id if sequence not provided
                  };
                }
                return null;
              })
              .whereType<Map<String, dynamic>>()
              .toList();
          
          // Sort by sequence to ensure correct order
          welcomeTextItems.sort((a, b) => (a['sequence'] as int).compareTo(b['sequence'] as int));
          
          // Extract just the names in the correct order
          final names = welcomeTextItems.map((item) => item['name'] as String).toList();
            print('✅ HomeRemoteDataSource: Loaded ${names.length} welcome texts');
          return names;
        }
      }

      throw Exception('Failed to get welcome text: Unexpected response format.');
    } on DioException catch (e) {
        print('❌ HomeRemoteDataSource: DioException on attempt ${retryCount + 1}: ${e.message}');
        retryCount++;
        if (retryCount >= maxRetries) {
      final msg = e.response?.data is Map && (e.response?.data['result'] is Map) && (e.response?.data['result']['message'] != null)
          ? e.response?.data['result']['message'].toString()
          : e.message ?? 'Failed to get welcome text';
      throw Exception(msg);
        }
    } catch (e) {
        print('❌ HomeRemoteDataSource: Unexpected error on attempt ${retryCount + 1}: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
      throw Exception('Failed to get welcome text: ${e.toString()}');
    }
      }
    }
    throw Exception('Failed to get welcome text after $maxRetries attempts');
  }
}
