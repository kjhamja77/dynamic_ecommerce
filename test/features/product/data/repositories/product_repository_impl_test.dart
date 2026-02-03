import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';
import 'package:zalando_clone_app/features/product/data/models/product_category_model.dart';
import 'package:zalando_clone_app/features/product/data/models/product_model.dart';
import 'package:zalando_clone_app/features/product/data/models/product_list_response_model.dart';
import 'package:zalando_clone_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:zalando_clone_app/features/product/data/datasources/product_remote_data_source.dart';

import 'product_repository_impl_test.mocks.dart';

@GenerateMocks([ProductRemoteDataSource])
void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('ProductRepositoryImpl', () {
    group('getProductById', () {
      test('should return Product when call to remote data source is successful', () async {
        // Arrange
        const productId = 12;
        const type = 'template';
        const templateId = 9;
        
        final productModel = ProductModel(
          id: productId,
          name: 'Storage Box',
          description: 'A storage box',
          shortDescription: 'Office storage',
          price: 15.8,
          currency: 'IQD',
          category: const ProductCategoryModel(
            id: 8, 
            name: 'Office Furniture',
            completeName: 'Office Furniture',
            sequence: 1,
          ),
          type: type,
          quantityAvailable: 18.0,
          inStock: true,
          totalVariants: 1,
          availableVariants: 1,
          variantAttributes: const [],
          variantCombinations: const [],
          images: const [],
          optionalProductIds: const [],
          accessoryProductIds: const [],
          alternativeProductIds: const [],
          sku: 'E-COM08',
          barcode: '123456789',
        );

        when(mockRemoteDataSource.getProductById(
          productId: productId,
          type: type,
          templateId: templateId,
        )).thenAnswer((_) async => productModel);

        // Act
        final result = await repository.getProductById(
          productId: productId,
          type: type,
          templateId: templateId,
        );

        // Assert
        expect(result, equals(Right(productModel)));
        verify(mockRemoteDataSource.getProductById(
          productId: productId,
          type: type,
          templateId: templateId,
        ));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return ServerFailure when call to remote data source is unsuccessful', () async {
        // Arrange
        const productId = 12;
        const type = 'template';
        const templateId = 9;
        const errorMessage = 'Network error';

        when(mockRemoteDataSource.getProductById(
          productId: productId,
          type: type,
          templateId: templateId,
        )).thenThrow(Exception(errorMessage));

        // Act
        final result = await repository.getProductById(
          productId: productId,
          type: type,
          templateId: templateId,
        );

        // Assert
        expect(result, equals(Left(ServerFailure('Exception: $errorMessage'))));
        verify(mockRemoteDataSource.getProductById(
          productId: productId,
          type: type,
          templateId: templateId,
        ));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });
    });

    group('getProductList', () {
      test('should return ProductListResponse when call to remote data source is successful', () async {
        // Arrange
        const limit = 20;
        const offset = 0;
        
        final productListResponse = ProductListResponseModel(
          products: [
            ProductModel(
              id: 12,
              name: 'Storage Box',
              description: 'A storage box',
              shortDescription: 'Office storage',
              price: 15.8,
              currency: 'IQD',
              category: const ProductCategoryModel(
            id: 8, 
            name: 'Office Furniture',
            completeName: 'Office Furniture',
            sequence: 1,
          ),
              type: 'template',
              quantityAvailable: 18.0,
              inStock: true,
              totalVariants: 1,
              availableVariants: 1,
              variantAttributes: const [],
              variantCombinations: const [],
              images: const [],
              optionalProductIds: const [],
              accessoryProductIds: const [],
              alternativeProductIds: const [],
              sku: 'E-COM08',
              barcode: '123456789',
            ),
          ],
          totalCount: 1,
          limit: limit,
          offset: offset,
        );

        when(mockRemoteDataSource.getProductList(
          limit: limit,
          offset: offset,
        )).thenAnswer((_) async => productListResponse);

        // Act
        final result = await repository.getProductList(
          limit: limit,
          offset: offset,
        );

        // Assert
        expect(result, equals(Right(productListResponse)));
        verify(mockRemoteDataSource.getProductList(
          limit: limit,
          offset: offset,
        ));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return ServerFailure when call to remote data source is unsuccessful', () async {
        // Arrange
        const limit = 20;
        const offset = 0;
        const errorMessage = 'Network error';

        when(mockRemoteDataSource.getProductList(
          limit: limit,
          offset: offset,
        )).thenThrow(Exception(errorMessage));

        // Act
        final result = await repository.getProductList(
          limit: limit,
          offset: offset,
        );

        // Assert
        expect(result, equals(Left(ServerFailure('Exception: $errorMessage'))));
        verify(mockRemoteDataSource.getProductList(
          limit: limit,
          offset: offset,
        ));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });
    });

    group('getProductsByCategory', () {
      test('should return ProductListResponse when call to remote data source is successful', () async {
        // Arrange
        const categoryIds = [8, 9];
        const limit = 20;
        const offset = 0;
        
        final productListResponse = ProductListResponseModel(
          products: [],
          totalCount: 0,
          limit: limit,
          offset: offset,
        );

        when(mockRemoteDataSource.getProductsByCategory(
          categoryIds: categoryIds,
          limit: limit,
          offset: offset,
        )).thenAnswer((_) async => productListResponse);

        // Act
        final result = await repository.getProductsByCategory(
          categoryIds: categoryIds,
          limit: limit,
          offset: offset,
        );

        // Assert
        expect(result, equals(Right(productListResponse)));
        verify(mockRemoteDataSource.getProductsByCategory(
          categoryIds: categoryIds,
          limit: limit,
          offset: offset,
        ));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return ServerFailure when call to remote data source is unsuccessful', () async {
        // Arrange
        const categoryIds = [8, 9];
        const limit = 20;
        const offset = 0;
        const errorMessage = 'Network error';

        when(mockRemoteDataSource.getProductsByCategory(
          categoryIds: categoryIds,
          limit: limit,
          offset: offset,
        )).thenThrow(Exception(errorMessage));

        // Act
        final result = await repository.getProductsByCategory(
          categoryIds: categoryIds,
          limit: limit,
          offset: offset,
        );

        // Assert
        expect(result, equals(Left(ServerFailure('Exception: $errorMessage'))));
        verify(mockRemoteDataSource.getProductsByCategory(
          categoryIds: categoryIds,
          limit: limit,
          offset: offset,
        ));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });
    });

    group('searchProducts', () {
      test('should return ProductListResponse when call to remote data source is successful', () async {
        // Arrange
        const query = 'storage box';
        const limit = 20;
        const offset = 0;
        
        final productListResponse = ProductListResponseModel(
          products: [],
          totalCount: 0,
          limit: limit,
          offset: offset,
        );

        when(mockRemoteDataSource.searchProducts(
          query: query,
          limit: limit,
          offset: offset,
        )).thenAnswer((_) async => productListResponse);

        // Act
        final result = await repository.searchProducts(
          query: query,
          limit: limit,
          offset: offset,
        );

        // Assert
        expect(result, equals(Right(productListResponse)));
        verify(mockRemoteDataSource.searchProducts(
          query: query,
          limit: limit,
          offset: offset,
        ));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return ServerFailure when call to remote data source is unsuccessful', () async {
        // Arrange
        const query = 'storage box';
        const limit = 20;
        const offset = 0;
        const errorMessage = 'Network error';

        when(mockRemoteDataSource.searchProducts(
          query: query,
          limit: limit,
          offset: offset,
        )).thenThrow(Exception(errorMessage));

        // Act
        final result = await repository.searchProducts(
          query: query,
          limit: limit,
          offset: offset,
        );

        // Assert
        expect(result, equals(Left(ServerFailure('Exception: $errorMessage'))));
        verify(mockRemoteDataSource.searchProducts(
          query: query,
          limit: limit,
          offset: offset,
        ));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });
    });
  });
}


