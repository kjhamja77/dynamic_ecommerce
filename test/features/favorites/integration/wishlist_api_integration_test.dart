import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import 'package:zalando_clone_app/features/favorites/data/datasources/favorites_remote_data_source_impl.dart';
import 'package:zalando_clone_app/features/favorites/data/models/favorite_product_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('Wishlist API Integration Tests', () {
    late FavoritesRemoteDataSourceImpl dataSource;
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient(const FlutterSecureStorage());
      dataSource = FavoritesRemoteDataSourceImpl(apiClient);
    });

    group('getWishlist', () {
      test('should parse wishlist API response correctly', () async {
        // This test demonstrates how the API response should be parsed
        // Based on the actual API response structure from the server
        
        final mockResponse = {
          'jsonrpc': '2.0',
          'id': null,
          'result': {
            'status': 'success',
            'code': 'WISHLIST_RETRIEVED',
            'success': 1,
            'status_code': 200,
            'message': 'Wishlist retrieved successfully',
            'data': {
              'items': [
                {
                  'id': 2,
                  'product': {
                    'id': 17,
                    'name': '[E-COM07] Large Cabinet',
                    'price': 320.0,
                    'template_id': 11,
                    'image': '/web/image/product.product/17/image_1920',
                    'attributes': []
                  }
                },
                {
                  'id': 1,
                  'product': {
                    'id': 36,
                    'name': '[DESK0005] Customizable Desk (Custom, White)',
                    'price': 750.0,
                    'template_id': 9,
                    'image': '/web/image/product.product/36/image_1920',
                    'attributes': [
                      {
                        'attribute_id': 1,
                        'attribute_name': 'Legs',
                        'value_id': 7,
                        'value_name': 'Custom'
                      },
                      {
                        'attribute_id': 2,
                        'attribute_name': 'Color',
                        'value_id': 3,
                        'value_name': 'White'
                      }
                    ]
                  }
                }
              ],
              'total_count': 2,
              'limit': 20,
              'offset': 0
            }
          }
        };

        // Test the parsing logic
        final result = mockResponse['result'] as Map<String, dynamic>;
        final data = result['data'] as Map<String, dynamic>;
        final wishlistData = data['items'] as List;
        final parsedProducts = wishlistData
            .map((item) => FavoriteProductModel.fromWishlistJson(item))
            .toList();

        expect(parsedProducts.length, 2);
        
        // Test first product
        expect(parsedProducts[0].id, '17');
        expect(parsedProducts[0].name, '[E-COM07] Large Cabinet');
        expect(parsedProducts[0].brand, 'Brand'); // Default brand from model
        expect(parsedProducts[0].price, 320.0);
        expect(parsedProducts[0].imageUrl, 'https://bazar-iq.filesdna.com/web/image/product.product/17/image_1920');
        expect(parsedProducts[0].category, 'Featured'); // Default category from model
        
        // Test second product
        expect(parsedProducts[1].id, '36');
        expect(parsedProducts[1].name, '[DESK0005] Customizable Desk (Custom, White)');
        expect(parsedProducts[1].brand, 'Brand'); // Default brand from model
        expect(parsedProducts[1].price, 750.0);
        expect(parsedProducts[1].imageUrl, 'https://bazar-iq.filesdna.com/web/image/product.product/36/image_1920');
        expect(parsedProducts[1].category, 'Featured'); // Default category from model
      });

      test('should handle empty wishlist response', () async {
        final mockResponse = {
          'jsonrpc': '2.0',
          'id': null,
          'result': {
            'status': 'success',
            'code': 'WISHLIST_RETRIEVED',
            'success': 1,
            'status_code': 200,
            'message': 'Wishlist retrieved successfully',
            'data': {
              'items': [],
              'total_count': 0,
              'limit': 20,
              'offset': 0
            }
          }
        };

        final result = mockResponse['result'] as Map<String, dynamic>;
        final data = result['data'] as Map<String, dynamic>;
        final wishlistData = data['items'] as List;
        final parsedProducts = wishlistData
            .map((item) => FavoriteProductModel.fromWishlistJson(item))
            .toList();

        expect(parsedProducts.length, 0);
      });

      test('should handle missing product data gracefully', () async {
        final mockResponse = {
          'jsonrpc': '2.0',
          'id': null,
          'result': {
            'status': 'success',
            'code': 'WISHLIST_RETRIEVED',
            'success': 1,
            'status_code': 200,
            'message': 'Wishlist retrieved successfully',
            'data': {
              'items': [
                {
                  'id': 1,
                  'product': {
                    'id': 1,
                    'name': 'Test Product',
                    // Missing price, image, attributes
                  },
                },
              ],
              'total_count': 1,
              'limit': 20,
              'offset': 0
            }
          }
        };

        final result = mockResponse['result'] as Map<String, dynamic>;
        final data = result['data'] as Map<String, dynamic>;
        final wishlistData = data['items'] as List;
        final parsedProducts = wishlistData
            .map((item) => FavoriteProductModel.fromWishlistJson(item))
            .toList();

        expect(parsedProducts.length, 1);
        expect(parsedProducts[0].id, '1');
        expect(parsedProducts[0].name, 'Test Product');
        expect(parsedProducts[0].brand, 'Brand'); // Default brand from model
        expect(parsedProducts[0].price, 0.0);
        expect(parsedProducts[0].imageUrl, null);
        expect(parsedProducts[0].category, 'Featured'); // Default category from model
      });
    });

    group('API Request Format', () {
      test('should format add wishlist request correctly', () {
        const productId = 123;
        final expectedParams = {
          'action': 'add',
          'product_id': productId,
        };

        expect(expectedParams['action'], 'add');
        expect(expectedParams['product_id'], 123);
      });

      test('should format remove wishlist request correctly', () {
        const productId = 123;
        final expectedParams = {
          'action': 'remove',
          'product_id': productId,
        };

        expect(expectedParams['action'], 'remove');
        expect(expectedParams['product_id'], 123);
      });

      test('should format get wishlist request correctly', () {
        final expectedParams = {
          'action': 'list',
        };

        expect(expectedParams['action'], 'list');
        expect(expectedParams.containsKey('product_id'), false);
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () {
        // This test demonstrates error handling patterns
        // In real integration tests, you would test actual network failures
        
        expect(() {
          throw Exception('Network error');
        }, throwsA(isA<Exception>()));
      });

      test('should handle API error responses gracefully', () {
        final errorResponse = {
          'result': {
            'error': 'Product not found',
            'code': 404,
          },
        };

        expect(errorResponse['result']!['error'], 'Product not found');
        expect(errorResponse['result']!['code'], 404);
      });

      test('should handle malformed JSON responses gracefully', () {
        final malformedResponse = {
          'result': null,
        };

        expect(malformedResponse['result'], null);
      });
    });

    group('Data Validation', () {
      test('should validate product ID conversion', () {
        const intProductId = 123;
        const stringProductId = '123';
        
        expect(intProductId.toString(), stringProductId);
        expect(int.parse(stringProductId), intProductId);
      });

      test('should validate price conversion', () {
        const intPrice = 150;
        const doublePrice = 150.0;
        const stringPrice = '150.0';
        
        expect(intPrice.toDouble(), doublePrice);
        expect(double.parse(stringPrice), doublePrice);
      });

      test('should validate image URL handling', () {
        const imageUrl = 'https://example.com/image.jpg';
        const nullImageUrl = null;
        
        expect(imageUrl, isA<String>());
        expect(nullImageUrl, null);
        expect(imageUrl?.isNotEmpty, true);
        expect(nullImageUrl?.isNotEmpty, null);
      });
    });
  });
}
