import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/endpoints.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import '../../../../core/services/language_service.dart';
import '../models/page_model.dart';
import '../models/component_model.dart';
import '../home_isolate.dart';

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
          final pagesData = (data['pages'] as List)
              .map((pageJson) => Map<String, dynamic>.from(pageJson as Map))
              .toList();

          // Offload heavy JSON → PageModel parsing to a background isolate.
          return parseHomePagesInBackground(pagesData);
        }
      }

      // Fallback for non-RPC or different success structure
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body is List) {
          final pagesData = body
              .map((pageJson) => Map<String, dynamic>.from(pageJson as Map))
              .toList();

          // Offload heavy JSON → PageModel parsing to a background isolate.
          return parseHomePagesInBackground(pagesData);
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
          final data =
              Map<String, dynamic>.from(result['data'] as Map);

          // Offload heavy JSON → PageComponentsModel parsing to a background isolate.
          return parseHomePageComponentsInBackground(data);
        }
      }

      // Fallback for non-RPC or different success structure
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body is Map) {
          final data = Map<String, dynamic>.from(body);

          // Offload heavy JSON → PageComponentsModel parsing to a background isolate.
          return parseHomePageComponentsInBackground(data);
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
    try {
      // Reuse the Home "getPages" endpoint to fetch welcome messages instead
      // of calling a dedicated welcome_text endpoint.
      //
      // In this API, welcome messages are returned inside the pages payload as:
      // "welcome_messages": {
      //   "welcome_text": [
      //     { "id": 1, "name": "NEW SALES", "sequence": 10 },
      //     ...
      //   ]
      // }
      //
      // We currently don't have a userId at this level, so we follow the
      // same convention used elsewhere in Home (e.g. DynamicHomeTabWidget)
      // and default to user_id = 1.
      const int userId = 1;

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
          throw Exception(
            (result['message'] ?? 'Failed to get welcome text').toString(),
          );
        }

        if (result['data'] is Map &&
            (result['data'] as Map)['pages'] is List) {
          final data = result['data'] as Map;
          final pages = data['pages'] as List;

          // Collect all welcome_text entries from any page that exposes them.
          final List<Map<String, dynamic>> welcomeTextItems = [];

          for (final page in pages) {
            if (page is! Map) continue;

            // Prefer the nested structure under each page.
            final pageWelcome = page['welcome_messages'];
            if (pageWelcome is Map &&
                pageWelcome['welcome_text'] is List) {
              final list = pageWelcome['welcome_text'] as List;
              for (final e in list) {
                if (e is Map && e['name'] != null) {
                  welcomeTextItems.add({
                    'name': e['name'].toString(),
                    'sequence': e['sequence'] ?? e['id'] ?? 0,
                  });
                }
              }
            }
          }

          // Fallback: some backends may put welcome_messages directly under data.
          if (welcomeTextItems.isEmpty &&
              data['welcome_messages'] is Map &&
              (data['welcome_messages'] as Map)['welcome_text'] is List) {
            final list =
                (data['welcome_messages'] as Map)['welcome_text'] as List;
            for (final e in list) {
              if (e is Map && e['name'] != null) {
                welcomeTextItems.add({
                  'name': e['name'].toString(),
                  'sequence': e['sequence'] ?? e['id'] ?? 0,
                });
              }
            }
          }

          if (welcomeTextItems.isEmpty) {
            return const <String>[];
          }

          // Sort by sequence to ensure correct display order and map to names.
          welcomeTextItems.sort(
            (a, b) =>
                (a['sequence'] as int).compareTo(b['sequence'] as int),
          );
          return welcomeTextItems
              .map((item) => item['name'] as String)
              .toList();
        }
      }

      throw Exception('Failed to get welcome text: Unexpected response format.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to get welcome text: ${e.toString()}');
    }
  }
}
