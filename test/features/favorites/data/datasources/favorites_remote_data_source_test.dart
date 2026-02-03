import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import 'package:zalando_clone_app/features/favorites/data/datasources/favorites_remote_data_source_impl.dart';
import 'package:zalando_clone_app/features/favorites/data/models/favorite_product_model.dart';

import 'favorites_remote_data_source_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late FavoritesRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = FavoritesRemoteDataSourceImpl(mockApiClient);
  });

  group('getWishlist', () {
    test('should return list of FavoriteProductModel when API call is successful', () async {
      // arrange
      final mockResponse = Response(
        data: {
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
                }
              ],
              'total_count': 1,
              'limit': 20,
              'offset': 0
            }
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

      when(mockApiClient.requestRpc(
        '/ecom/product/wish-list',
        params: {'action': 'list'},
      )).thenAnswer((_) async => mockResponse);

      // act
      final result = await dataSource.getWishlist();

      // assert
      expect(result, isA<List<FavoriteProductModel>>());
      expect(result.length, 1);
      expect(result.first.id, '17');
      expect(result.first.name, '[E-COM07] Large Cabinet');
      expect(result.first.brand, 'Brand'); // Default brand from model
      expect(result.first.price, 320.0);
      expect(result.first.imageUrl, 'https://bazar-iq.filesdna.com/web/image/product.product/17/image_1920');
      expect(result.first.category, 'Featured'); // Default category from model

      verify(mockApiClient.requestRpc(
        '/ecom/product/wish-list',
        params: {'action': 'list'},
      ));
    });

    test('should return empty list when API returns no wishlist data', () async {
      // arrange
      final mockResponse = Response(
        data: {
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
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

      when(mockApiClient.requestRpc(
        '/ecom/product/wish-list',
        params: {'action': 'list'},
      )).thenAnswer((_) async => mockResponse);

      // act
      final result = await dataSource.getWishlist();

      // assert
      expect(result, isA<List<FavoriteProductModel>>());
      expect(result.length, 0);
    });

    test('should return empty list when API response structure is invalid', () async {
      // arrange
      final mockResponse = Response(
        data: {
          'result': {
            'data': null,
          },
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

      when(mockApiClient.requestRpc(
        '/ecom/product/wish-list',
        params: {'action': 'list'},
      )).thenAnswer((_) async => mockResponse);

      // act
      final result = await dataSource.getWishlist();

      // assert
      expect(result, isA<List<FavoriteProductModel>>());
      expect(result.length, 0);
    });

    test('should throw exception when API call fails', () async {
      // arrange
      when(mockApiClient.requestRpc(
        '/ecom/product/wish-list',
        params: {'action': 'list'},
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/test'),
        message: 'Network error',
      ));

      // act & assert
      expect(
        () => dataSource.getWishlist(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('addToWishlist', () {
    test('should call API with correct parameters when adding to wishlist', () async {
      // arrange
      const productId = 123;
      final mockResponse = Response(
        data: {'result': {'success': true}},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

      when(mockApiClient.requestRpc(
        '/ecom/product/wish-list',
        params: {
          'action': 'add',
          'product_id': productId,
        },
      )).thenAnswer((_) async => mockResponse);

      // act
      await dataSource.addToWishlist(productId);

      // assert
      verify(mockApiClient.requestRpc(
        '/ecom/product/wish-list',
        params: {
          'action': 'add',
          'product_id': productId,
        },
      ));
    });

    test('should throw exception when API call fails', () async {
      // arrange
      const productId = 123;
      when(mockApiClient.requestRpc(
        '/ecom/product/wish-list',
        params: {
          'action': 'add',
          'product_id': productId,
        },
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/test'),
        message: 'Network error',
      ));

      // act & assert
      expect(
        () => dataSource.addToWishlist(productId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('removeFromWishlist', () {
    test('should call API with correct parameters when removing from wishlist', () async {
      // arrange
      const productId = 123;
      final mockResponse = Response(
        data: {'result': {'success': true}},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

      when(mockApiClient.requestRpc(
        '/ecom/product/wish-list',
        params: {
          'action': 'remove',
          'product_id': productId,
        },
      )).thenAnswer((_) async => mockResponse);

      // act
      await dataSource.removeFromWishlist(productId);

      // assert
      verify(mockApiClient.requestRpc(
        '/ecom/product/wish-list',
        params: {
          'action': 'remove',
          'product_id': productId,
        },
      ));
    });

    test('should throw exception when API call fails', () async {
      // arrange
      const productId = 123;
      when(mockApiClient.requestRpc(
        '/ecom/product/wish-list',
        params: {
          'action': 'remove',
          'product_id': productId,
        },
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/test'),
        message: 'Network error',
      ));

      // act & assert
      expect(
        () => dataSource.removeFromWishlist(productId),
        throwsA(isA<Exception>()),
      );
    });
  });
}
