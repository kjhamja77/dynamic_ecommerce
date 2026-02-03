import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import 'package:zalando_clone_app/features/addresses/data/datasources/address_remote_data_source_impl.dart';

import 'address_country_state_test.mocks.dart';

@GenerateMocks([ApiClient, Dio, Response])
void main() {
  group('AddressRemoteDataSourceImpl - Country and State APIs', () {
    late AddressRemoteDataSourceImpl dataSource;
    late MockApiClient mockApiClient;
    late MockDio mockDio;
    late MockResponse mockResponse;

    setUp(() {
      mockApiClient = MockApiClient();
      mockDio = MockDio();
      mockResponse = MockResponse();
      dataSource = AddressRemoteDataSourceImpl(mockApiClient);
      
      when(mockApiClient.dio).thenReturn(mockDio);
      when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
        (status: 'success', message: 'Success', data: null),
      );
    });

    group('getCountryList', () {
      test('should return countries list when API call succeeds', () async {
        // Arrange
        final mockCountriesData = {
          'countries': [
            {'id': 1, 'name': 'United States', 'code': 'US'},
            {'id': 2, 'name': 'United Arab Emirates', 'code': 'AE'},
            {'id': 3, 'name': 'Afghanistan', 'code': 'AF'},
          ]
        };

        when(mockDio.post('/ecom/get/country-list', data: anyNamed('data'))).thenAnswer(
          (_) async => mockResponse,
        );
        when(mockResponse.data).thenReturn({
          'jsonrpc': '2.0',
          'id': null,
          'result': {
            'status': 'success',
            'code': 'COUNTRY_LIST_RETRIEVED',
            'success': 1,
            'status_code': 200,
            'message': 'Successfully retrieved 3 countries',
            'data': mockCountriesData,
          }
        });
        when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
          (status: 'success', message: 'Successfully retrieved 3 countries', data: mockCountriesData),
        );

        // Act
        final result = await dataSource.getCountryList();

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(3));
        expect(result[0]['name'], equals('United States'));
        expect(result[0]['code'], equals('US'));
        expect(result[1]['name'], equals('United Arab Emirates'));
        expect(result[1]['code'], equals('AE'));
        
        verify(mockDio.post('/ecom/get/country-list', data: {'params': {}})).called(1);
        verify(mockApiClient.parseRpcEnvelope(any)).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(mockDio.post('/ecom/get/country-list', data: anyNamed('data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/ecom/get/country-list'),
            response: Response(
              requestOptions: RequestOptions(path: '/ecom/get/country-list'),
              statusCode: 500,
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getCountryList(),
          throwsA(isA<DioException>()),
        );
      });

      test('should return empty list when no countries in response', () async {
        // Arrange
        when(mockDio.post('/ecom/get/country-list', data: anyNamed('data'))).thenAnswer(
          (_) async => mockResponse,
        );
        when(mockResponse.data).thenReturn({
          'jsonrpc': '2.0',
          'id': null,
          'result': {
            'status': 'success',
            'message': 'Success',
            'data': <String, dynamic>{}, // Empty data
          }
        });
        when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
          (status: 'success', message: 'Success', data: <String, dynamic>{}),
        );

        // Act
        final result = await dataSource.getCountryList();

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(0));
      });

      test('should send correct request format with empty params', () async {
        // Arrange
        when(mockDio.post('/ecom/get/country-list', data: anyNamed('data'))).thenAnswer(
          (_) async => mockResponse,
        );
        when(mockResponse.data).thenReturn({
          'jsonrpc': '2.0',
          'id': null,
          'result': {
            'status': 'success',
            'message': 'Success',
            'data': {'countries': []},
          }
        });
        when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
          (status: 'success', message: 'Success', data: {'countries': []}),
        );

        // Act
        await dataSource.getCountryList();

        // Assert
        final capturedData = verify(mockDio.post('/ecom/get/country-list', data: captureAnyNamed('data'))).captured.first;
        expect(capturedData, equals({
          'params': {}
        }));
      });
    });

    group('getStateList', () {
      test('should return states list when API call succeeds', () async {
        // Arrange
        const countryId = 2;
        final mockStatesData = {
          'states': [
            {'id': 1, 'name': 'Dubai', 'code': 'DU'},
            {'id': 2, 'name': 'Abu Dhabi', 'code': 'AD'},
            {'id': 3, 'name': 'Sharjah', 'code': 'SH'},
          ]
        };

        when(mockDio.post('/ecom/get/state-list', data: anyNamed('data'))).thenAnswer(
          (_) async => mockResponse,
        );
        when(mockResponse.data).thenReturn({
          'jsonrpc': '2.0',
          'id': null,
          'result': {
            'status': 'success',
            'code': 'STATE_LIST_RETRIEVED',
            'success': 1,
            'status_code': 200,
            'message': 'Successfully retrieved 3 states',
            'data': mockStatesData,
          }
        });
        when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
          (status: 'success', message: 'Successfully retrieved 3 states', data: mockStatesData),
        );

        // Act
        final result = await dataSource.getStateList(countryId);

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(3));
        expect(result[0]['name'], equals('Dubai'));
        expect(result[0]['code'], equals('DU'));
        expect(result[1]['name'], equals('Abu Dhabi'));
        expect(result[1]['code'], equals('AD'));
        
        verify(mockDio.post('/ecom/get/state-list', data: {
          'params': {'country_id': countryId}
        })).called(1);
        verify(mockApiClient.parseRpcEnvelope(any)).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        const countryId = 2;
        when(mockDio.post('/ecom/get/state-list', data: anyNamed('data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/ecom/get/state-list'),
            response: Response(
              requestOptions: RequestOptions(path: '/ecom/get/state-list'),
              statusCode: 500,
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getStateList(countryId),
          throwsA(isA<DioException>()),
        );
      });

      test('should return empty list when no states in response', () async {
        // Arrange
        const countryId = 2;
        when(mockDio.post('/ecom/get/state-list', data: anyNamed('data'))).thenAnswer(
          (_) async => mockResponse,
        );
        when(mockResponse.data).thenReturn({
          'jsonrpc': '2.0',
          'id': null,
          'result': {
            'status': 'success',
            'message': 'Success',
            'data': <String, dynamic>{}, // Empty data
          }
        });
        when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
          (status: 'success', message: 'Success', data: <String, dynamic>{}),
        );

        // Act
        final result = await dataSource.getStateList(countryId);

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(0));
      });

      test('should send correct request format with country_id parameter', () async {
        // Arrange
        const countryId = 2;
        when(mockDio.post('/ecom/get/state-list', data: anyNamed('data'))).thenAnswer(
          (_) async => mockResponse,
        );
        when(mockResponse.data).thenReturn({
          'jsonrpc': '2.0',
          'id': null,
          'result': {
            'status': 'success',
            'message': 'Success',
            'data': {'states': []},
          }
        });
        when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
          (status: 'success', message: 'Success', data: {'states': []}),
        );

        // Act
        await dataSource.getStateList(countryId);

        // Assert
        final capturedData = verify(mockDio.post('/ecom/get/state-list', data: captureAnyNamed('data'))).captured.first;
        expect(capturedData, equals({
          'params': {'country_id': countryId}
        }));
      });
    });
  });
}
