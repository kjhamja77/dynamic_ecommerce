import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:zalando_clone_app/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';

import 'onboarding_remote_data_source_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  group('OnboardingRemoteDataSource', () {
    late OnboardingRemoteDataSourceImpl dataSource;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      dataSource = OnboardingRemoteDataSourceImpl(apiClient: mockApiClient);
    });

    test('should return onboarding pages when API call is successful', () async {
      // Arrange
      final mockResponse = Response(
        data: {
          'jsonrpc': '2.0',
          'id': null,
          'result': {
            'status': 'success',
            'code': 'ONBOARDING_RETRIEVED',
            'success': 1,
            'status_code': 200,
            'message': 'Successfully retrieved 3 onboarding',
            'data': {
              'total_count': 3,
              'onboarding': [
                {
                  'id': 1,
                  'name': 'Welcome to bazar',
                  'description': 'Discover the latest fashion trends',
                  'image': 'https://example.com/image1.jpg'
                },
                {
                  'id': 2,
                  'name': 'Shop smart',
                  'description': 'Get personalized recommendations',
                  'image': 'https://example.com/image2.jpg'
                },
                {
                  'id': 3,
                  'name': 'Fast delivery',
                  'description': 'Enjoy quick delivery and easy returns',
                  'image': 'https://example.com/image3.jpg'
                }
              ]
            }
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/ecom/get/onboarding'),
      );

      when(mockApiClient.requestRpc(
        '/ecom/get/onboarding',
        method: 'POST',
        params: {},
      )).thenAnswer((_) async => mockResponse);

      when(mockApiClient.parseRpcEnvelope(any)).thenReturn((
        status: 'success',
        message: 'Successfully retrieved 3 onboarding',
        data: {
          'total_count': 3,
          'onboarding': [
            {
              'id': 1,
              'name': 'Welcome to bazar',
              'description': 'Discover the latest fashion trends',
              'image': 'https://example.com/image1.jpg'
            },
            {
              'id': 2,
              'name': 'Shop smart',
              'description': 'Get personalized recommendations',
              'image': 'https://example.com/image2.jpg'
            },
            {
              'id': 3,
              'name': 'Fast delivery',
              'description': 'Enjoy quick delivery and easy returns',
              'image': 'https://example.com/image3.jpg'
            }
          ]
        }
      ));

      // Act
      final result = await dataSource.getOnboardingPages();

      // Assert
      expect(result, hasLength(3));
      expect(result[0].id, equals(1));
      expect(result[0].name, equals('Welcome to bazar'));
      expect(result[0].description, equals('Discover the latest fashion trends'));
      expect(result[0].image, equals('https://example.com/image1.jpg'));
      
      expect(result[1].id, equals(2));
      expect(result[1].name, equals('Shop smart'));
      expect(result[1].description, equals('Get personalized recommendations'));
      expect(result[1].image, equals('https://example.com/image2.jpg'));
      
      expect(result[2].id, equals(3));
      expect(result[2].name, equals('Fast delivery'));
      expect(result[2].description, equals('Enjoy quick delivery and easy returns'));
      expect(result[2].image, equals('https://example.com/image3.jpg'));

      verify(mockApiClient.requestRpc(
        '/ecom/get/onboarding',
        method: 'POST',
        params: {},
      )).called(1);
    });

    test('should handle API response with null description and image', () async {
      // Arrange
      final mockResponse = Response(
        data: {
          'jsonrpc': '2.0',
          'id': null,
          'result': {
            'status': 'success',
            'code': 'ONBOARDING_RETRIEVED',
            'success': 1,
            'status_code': 200,
            'message': 'Successfully retrieved 1 onboarding',
            'data': {
              'total_count': 1,
              'onboarding': [
                {
                  'id': 1,
                  'name': 'Welcome to bazar',
                  'description': false,
                  'image': null
                }
              ]
            }
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/ecom/get/onboarding'),
      );

      when(mockApiClient.requestRpc(
        '/ecom/get/onboarding',
        method: 'POST',
        params: {},
      )).thenAnswer((_) async => mockResponse);

      when(mockApiClient.parseRpcEnvelope(any)).thenReturn((
        status: 'success',
        message: 'Successfully retrieved 1 onboarding',
        data: {
          'total_count': 1,
          'onboarding': [
            {
              'id': 1,
              'name': 'Welcome to bazar',
              'description': false,
              'image': null
            }
          ]
        }
      ));

      // Act
      final result = await dataSource.getOnboardingPages();

      // Assert
      expect(result, hasLength(1));
      expect(result[0].id, equals(1));
      expect(result[0].name, equals('Welcome to bazar'));
      expect(result[0].description, isNull);
      expect(result[0].image, isNull);
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      when(mockApiClient.requestRpc(
        '/ecom/get/onboarding',
        method: 'POST',
        params: {},
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/ecom/get/onboarding'),
        message: 'Network error',
      ));

      // Act & Assert
      expect(
        () => dataSource.getOnboardingPages(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Network error'),
        )),
      );
    });

    test('should throw exception when API returns error status', () async {
      // Arrange
      final mockResponse = Response(
        data: {
          'jsonrpc': '2.0',
          'id': null,
          'result': {
            'status': 'error',
            'code': 'ONBOARDING_ERROR',
            'success': 0,
            'status_code': 400,
            'message': 'Failed to retrieve onboarding',
            'data': null
          }
        },
        statusCode: 400,
        requestOptions: RequestOptions(path: '/ecom/get/onboarding'),
      );

      when(mockApiClient.requestRpc(
        '/ecom/get/onboarding',
        method: 'POST',
        params: {},
      )).thenAnswer((_) async => mockResponse);

      when(mockApiClient.parseRpcEnvelope(any)).thenReturn((
        status: 'error',
        message: 'Failed to retrieve onboarding',
        data: null
      ));

      // Act & Assert
      expect(
        () => dataSource.getOnboardingPages(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to retrieve onboarding'),
        )),
      );
    });
  });
}
