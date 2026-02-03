import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import 'package:zalando_clone_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:zalando_clone_app/features/home/data/models/page_model.dart';

import 'home_remote_data_source_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late HomeRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = HomeRemoteDataSourceImpl(mockApiClient);
  });

  group('getPages', () {
    const tUserId = 1;
    final tResponseData = {
      'jsonrpc': '2.0',
      'id': null,
      'result': {
        'status': 'success',
        'code': 'PAGES_RETRIEVED',
        'status_code': 200,
        'success': 1,
        'message': 'Pages retrieved successfully',
        'data': {
          'pages': [
            {
              'id': 1,
              'name': 'home',
              'description': 'Main home page',
            },
            {
              'id': 2,
              'name': 'catalog',
              'description': 'Product catalog page',
            },
          ],
        },
      },
    };

    test('should return pages when API call is successful', () async {
      // arrange
      final response = Response(
        data: tResponseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/ecom/get/pages'),
      );
      when(mockApiClient.requestRpc(
        '/ecom/get/pages',
        method: 'POST',
        params: {'user_id': tUserId},
      )).thenAnswer((_) async => response);

      // act
      final result = await dataSource.getPages(tUserId);

      // assert
      expect(result, isA<List<PageModel>>());
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].name, 'home');
      expect(result[0].title, 'home'); // PageModel uses name as title
      expect(result[1].id, 2);
      expect(result[1].name, 'catalog');
      expect(result[1].title, 'catalog'); // PageModel uses name as title
    });

    test('should throw exception when API returns error status', () async {
      // arrange
      final errorResponseData = {
        'jsonrpc': '2.0',
        'id': null,
        'result': {
          'status': 'error',
          'code': 'PAGES_NOT_FOUND',
          'status_code': 404,
          'success': 0,
          'message': 'No pages found for user',
          'data': null,
        },
      };
      final response = Response(
        data: errorResponseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/ecom/get/pages'),
      );
      when(mockApiClient.requestRpc(
        '/ecom/get/pages',
        method: 'POST',
        params: {'user_id': tUserId},
      )).thenAnswer((_) async => response);

      // act & assert
      expect(
        () => dataSource.getPages(tUserId),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('No pages found for user'),
        )),
      );
    });

    test('should throw exception when API call fails', () async {
      // arrange
      when(mockApiClient.requestRpc(
        '/ecom/get/pages',
        method: 'POST',
        params: {'user_id': tUserId},
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/ecom/get/pages'),
        error: 'Network error',
      ));

      // act & assert
      expect(
        () => dataSource.getPages(tUserId),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Network error'),
        )),
      );
    });

    test('should handle unexpected response format', () async {
      // arrange
      final unexpectedResponseData = {
        'jsonrpc': '2.0',
        'id': null,
        'result': {
          'status': 'success',
          'data': 'unexpected_format',
        },
      };
      final response = Response(
        data: unexpectedResponseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/ecom/get/pages'),
      );
      when(mockApiClient.requestRpc(
        '/ecom/get/pages',
        method: 'POST',
        params: {'user_id': tUserId},
      )).thenAnswer((_) async => response);

      // act & assert
      expect(
        () => dataSource.getPages(tUserId),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Unexpected response format'),
        )),
      );
    });
  });
}
