import '../../../../core/constants/endpoints.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import '../models/search_params_model.dart';
import '../models/search_results_model.dart';

abstract class SearchRemoteDataSource {
  Future<SearchResults> searchProducts(SearchParams params);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiClient apiClient;

  SearchRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<SearchResults> searchProducts(SearchParams params) async {
    try {
      print('SearchRemoteDataSource - Making API request to: ${Endpoints.searchProducts}');
      print('SearchRemoteDataSource - Request params: ${params.toJson()}');
      
      final response = await apiClient.requestRpc(
        Endpoints.searchProducts,
        method: 'POST',
        params: params.toJson(),
      ).timeout(const Duration(seconds: 25), onTimeout: () {
        throw Exception('API request timed out after 25 seconds');
      });

      print('SearchRemoteDataSource - API response received');
      print('SearchRemoteDataSource - Response data: ${response.data}');

      // Handle RPC envelope { jsonrpc, result: { status, message, status_code, data } }
      final body = response.data;
      if (body is Map && body['result'] is Map) {
        final result = body['result'] as Map;
        final status = (result['status'] ?? '').toString().toLowerCase();
        
        print('SearchRemoteDataSource - Response status: $status');
        
        if (status == 'error') {
          print('SearchRemoteDataSource - API returned error: ${result['message']}');
          throw Exception((result['message'] ?? 'Search failed').toString());
        }

        // Extract search results from the response
        final data = result['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
        print('SearchRemoteDataSource - Response data: $data');
        
        // Handle different response structures
        if (data.containsKey('products')) {
          // Direct products array
          print('SearchRemoteDataSource - Found products key, parsing results');
          return SearchResults.fromJson(data);
        } else if (data.containsKey('items')) {
          // Alternative structure with 'items' instead of 'products'
          print('SearchRemoteDataSource - Found items key, converting to products');
          try {
            final modifiedData = Map<String, dynamic>.from(data);
            modifiedData['products'] = data['items']; // Keep the items as products
            print('SearchRemoteDataSource - Modified data keys: ${modifiedData.keys.toList()}');
            print('SearchRemoteDataSource - Products count: ${(data['items'] as List).length}');
            final results = SearchResults.fromJson(modifiedData);
            print('SearchRemoteDataSource - Successfully created SearchResults with ${results.products.length} products');
            return results;
          } catch (e) {
            print('SearchRemoteDataSource - Error parsing items: $e');
            throw Exception('Failed to parse search results: $e');
          }
        } else {
          // Fallback: create empty results
          print('SearchRemoteDataSource - No products or items found, returning empty results');
          return const SearchResults(
            products: [],
            totalCount: 0,
            currentPage: 1,
            totalPages: 1,
            hasNextPage: false,
            hasPreviousPage: false,
          );
        }
      } else {
        print('SearchRemoteDataSource - Invalid response format: $body');
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('SearchRemoteDataSource - Request failed: ${e.toString()}');
      throw Exception('Search request failed: ${e.toString()}');
    }
  }
}
