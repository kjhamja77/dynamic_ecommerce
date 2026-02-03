import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';
import 'package:zalando_clone_app/features/filters/data/datasources/filter_remote_data_source.dart';
import 'package:zalando_clone_app/features/filters/domain/entities/filter_criteria.dart';

import 'filter_remote_data_source_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  group('FilterRemoteDataSource', () {
    late FilterRemoteDataSourceImpl dataSource;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      dataSource = FilterRemoteDataSourceImpl(apiClient: mockApiClient);
    });

    group('getCategories', () {
      test('should return categories when API call is successful', () async {
        // Arrange
        final responseData = {
          'data': [
            {
              'id': 1,
              'name': 'Shoes',
              'complete_name': 'All / Shoes',
              'sequence': 1,
              'product_count': 100,
              'hasChildren': true,
              'children': [],
            },
            {
              'id': 2,
              'name': 'Clothing',
              'complete_name': 'All / Clothing',
              'sequence': 2,
              'product_count': 200,
              'hasChildren': false,
              'children': [],
            },
          ]
        };

        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockApiClient.requestRpc(
          '/ecom/get/product/categories',
          method: 'GET',
          params: anyNamed('params'),
        )).thenAnswer((_) async => response);

        // Act
        final result = await dataSource.getCategories(page: 1, limit: 6);

        // Assert
        expect(result.length, 2);
        expect(result.first.id, 1);
        expect(result.first.name, 'Shoes');
        expect(result.first.productCount, 100);
        expect(result.first.hasChildren, true);
        expect(result.last.id, 2);
        expect(result.last.name, 'Clothing');
        expect(result.last.productCount, 200);
        expect(result.last.hasChildren, false);

        verify(mockApiClient.requestRpc(
          '/ecom/get/product/categories',
          method: 'GET',
          params: {
            'page': 1,
            'limit': 6,
          },
        )).called(1);
      });

      test('should return empty list when API returns no data', () async {
        // Arrange
        final responseData = {'data': []};
        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockApiClient.requestRpc(
          '/ecom/get/product/categories',
          method: 'GET',
          params: anyNamed('params'),
        )).thenAnswer((_) async => response);

        // Act
        final result = await dataSource.getCategories();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw ServerFailure when API call fails', () async {
        // Arrange
        final response = Response(
          data: null,
          statusCode: 500,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockApiClient.requestRpc(
          '/ecom/get/product/categories',
          method: 'GET',
          params: anyNamed('params'),
        )).thenAnswer((_) async => response);

        // Act & Assert
        expect(
          () => dataSource.getCategories(),
          throwsA(isA<ServerFailure>()),
        );
      });

      test('should throw ServerFailure when DioException occurs', () async {
        // Arrange
        when(mockApiClient.requestRpc(
          '/ecom/get/product/categories',
          method: 'GET',
          params: anyNamed('params'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/test'),
          error: 'Network error',
        ));

        // Act & Assert
        expect(
          () => dataSource.getCategories(),
          throwsA(isA<ServerFailure>()),
        );
      });
    });

    group('getBrands', () {
      test('should return brands when API call is successful', () async {
        // Arrange
        final responseData = {
          'data': [
            {
              'id': 1,
              'name': 'Nike',
              'image': 'nike.jpg',
              'product_count': 150,
              'is_active': true,
            },
            {
              'id': 2,
              'name': 'Adidas',
              'image': 'adidas.jpg',
              'product_count': 120,
              'is_active': true,
            },
          ]
        };

        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockApiClient.requestRpc(
          '/ecom/get/product/brands',
          method: 'GET',
          params: anyNamed('params'),
        )).thenAnswer((_) async => response);

        // Act
        final result = await dataSource.getBrands(page: 1, limit: 7);

        // Assert
        expect(result.length, 2);
        expect(result.first.id, 1);
        expect(result.first.name, 'Nike');
        expect(result.first.productCount, 150);
        expect(result.last.id, 2);
        expect(result.last.name, 'Adidas');
        expect(result.last.productCount, 120);

        verify(mockApiClient.requestRpc(
          '/ecom/get/product/brands',
          method: 'GET',
          params: {
            'page': 1,
            'limit': 7,
          },
        )).called(1);
      });
    });

    group('getAttributes', () {
      test('should return attributes when API call is successful', () async {
        // Arrange
        final responseData = {
          'data': [
            {
              'id': 1,
              'name': 'Size',
              'type': 'text',
              'values': [
                {
                  'id': 1,
                  'name': 'Small',
                  'value': 'S',
                  'product_count': 50,
                  'is_active': true,
                },
                {
                  'id': 2,
                  'name': 'Medium',
                  'value': 'M',
                  'product_count': 75,
                  'is_active': true,
                },
              ],
              'is_required': true,
              'is_visible': true,
            },
          ]
        };

        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockApiClient.requestRpc(
          '/ecom/get/product/attributes',
          method: 'GET',
          params: anyNamed('params'),
        )).thenAnswer((_) async => response);

        // Act
        final result = await dataSource.getAttributes(page: 1, limit: 2);

        // Assert
        expect(result.length, 1);
        expect(result.first.id, 1);
        expect(result.first.name, 'Size');
        expect(result.first.type, 'text');
        expect(result.first.values.length, 2);
        expect(result.first.values.first.name, 'Small');
        expect(result.first.values.first.value, 'S');
        expect(result.first.isRequired, true);
        expect(result.first.isVisible, true);

        verify(mockApiClient.requestRpc(
          '/ecom/get/product/attributes',
          method: 'GET',
          params: {
            'page': 1,
            'limit': 2,
          },
        )).called(1);
      });
    });

    group('getFilterOptions', () {
      test('should return filter options when API call is successful', () async {
        // Arrange
        final responseData = {
          'categories': [
            {
              'id': 1,
              'name': 'Shoes',
              'complete_name': 'All / Shoes',
              'sequence': 1,
              'product_count': 100,
              'hasChildren': true,
              'children': [],
            }
          ],
          'brands': [
            {
              'id': 1,
              'name': 'Nike',
              'product_count': 150,
              'is_active': true,
            }
          ],
          'attributes': [],
          'price_range': {
            'min_price': 10.0,
            'max_price': 1000.0,
            'currency': 'IQD',
          },
          'available_sizes': ['S', 'M', 'L', 'XL'],
          'available_colors': ['Red', 'Blue', 'Green'],
          'available_materials': ['Cotton', 'Polyester'],
          'available_seasons': ['Summer', 'Winter'],
          'available_genders': ['Men', 'Women'],
        };

        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockApiClient.requestRpc(
          '/ecom/get/product/filter-options',
          method: 'GET',
        )).thenAnswer((_) async => response);

        // Act
        final result = await dataSource.getFilterOptions();

        // Assert
        expect(result.categories.length, 1);
        expect(result.categories.first.name, 'Shoes');
        expect(result.brands.length, 1);
        expect(result.brands.first.name, 'Nike');
        expect(result.priceRange?.minPrice, 10.0);
        expect(result.priceRange?.maxPrice, 1000.0);
        expect(result.priceRange?.currency, 'IQD');
        expect(result.availableSizes, ['S', 'M', 'L', 'XL']);
        expect(result.availableColors, ['Red', 'Blue', 'Green']);
        expect(result.availableMaterials, ['Cotton', 'Polyester']);
        expect(result.availableSeasons, ['Summer', 'Winter']);
        expect(result.availableGenders, ['Men', 'Women']);

        verify(mockApiClient.requestRpc(
          '/ecom/get/product/filter-options',
          method: 'GET',
        )).called(1);
      });
    });

    group('filterProducts', () {
      test('should return filtered products when API call is successful', () async {
        // Arrange
        final criteria = const FilterCriteria(
          minPrice: 10.0,
          maxPrice: 100.0,
          brand: 'Nike',
          sizes: ['S', 'M'],
        );

        final responseData = {
          'products': [
            {
              'id': 1,
              'name': 'Nike Air Max',
              'price': 50.0,
              'brand': 'Nike',
            }
          ],
          'total': 1,
          'page': 1,
          'limit': 20,
        };

        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockApiClient.requestRpc(
          '/ecom/get/product/filter-search',
          method: 'POST',
          params: anyNamed('params'),
        )).thenAnswer((_) async => response);

        // Act
        final result = await dataSource.filterProducts(criteria);

        // Assert
        expect(result['products'], isA<List>());
        expect(result['products'].length, 1);
        expect(result['total'], 1);
        expect(result['page'], 1);
        expect(result['limit'], 20);

        verify(mockApiClient.requestRpc(
          '/ecom/get/product/filter-search',
          method: 'POST',
          params: criteria.toJson(),
        )).called(1);
      });

      test('should return empty result when no products match criteria', () async {
        // Arrange
        final criteria = const FilterCriteria(
          minPrice: 1000.0,
          maxPrice: 2000.0,
        );

        final responseData = {
          'products': [],
          'total': 0,
          'page': 1,
          'limit': 20,
        };

        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockApiClient.requestRpc(
          '/ecom/get/product/filter-search',
          method: 'POST',
          params: anyNamed('params'),
        )).thenAnswer((_) async => response);

        // Act
        final result = await dataSource.filterProducts(criteria);

        // Assert
        expect(result['products'], isEmpty);
        expect(result['total'], 0);
      });

      test('should throw ServerFailure when API call fails', () async {
        // Arrange
        final criteria = const FilterCriteria();
        final response = Response(
          data: null,
          statusCode: 500,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockApiClient.requestRpc(
          '/ecom/get/product/filter-search',
          method: 'POST',
          params: anyNamed('params'),
        )).thenAnswer((_) async => response);

        // Act & Assert
        expect(
          () => dataSource.filterProducts(criteria),
          throwsA(isA<ServerFailure>()),
        );
      });
    });
  });
}
