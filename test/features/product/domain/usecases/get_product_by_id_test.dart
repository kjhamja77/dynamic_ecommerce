import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';
import 'package:zalando_clone_app/features/product/data/models/product_category_model.dart';
import 'package:zalando_clone_app/features/product/data/models/product_model.dart';
import 'package:zalando_clone_app/features/product/domain/repositories/product_repository.dart';
import 'package:zalando_clone_app/features/product/domain/usecases/get_product_by_id.dart';

import 'get_product_by_id_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  late GetProductById usecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = GetProductById(mockRepository);
  });

  group('GetProductById', () {
    test('should get product by id from repository', () async {
      // Arrange
      const productId = 12;
      const type = 'template';
      const templateId = 9;
      
      final product = ProductModel(
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

      when(mockRepository.getProductById(
        productId: productId,
        type: type,
        templateId: templateId,
      )).thenAnswer((_) async => Right(product));

      // Act
      final result = await usecase(GetProductByIdParams(
        productId: productId,
        type: type,
        templateId: templateId,
      ));

      // Assert
      expect(result, equals(Right(product)));
      verify(mockRepository.getProductById(
        productId: productId,
        type: type,
        templateId: templateId,
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository call fails', () async {
      // Arrange
      const productId = 12;
      const type = 'template';
      const templateId = 9;
      const failure = ServerFailure('Network error');

      when(mockRepository.getProductById(
        productId: productId,
        type: type,
        templateId: templateId,
      )).thenAnswer((_) async => Left(failure));

      // Act
      final result = await usecase(GetProductByIdParams(
        productId: productId,
        type: type,
        templateId: templateId,
      ));

      // Assert
      expect(result, equals(Left(failure)));
      verify(mockRepository.getProductById(
        productId: productId,
        type: type,
        templateId: templateId,
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle variant type without templateId', () async {
      // Arrange
      const productId = 18;
      const type = 'variant';
      
      final product = ProductModel(
        id: productId,
        name: 'Storage Box Variant',
        description: 'A storage box variant',
        shortDescription: 'Office storage variant',
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
        sku: 'E-COM08-VAR',
        barcode: '123456789',
      );

      when(mockRepository.getProductById(
        productId: productId,
        type: type,
        templateId: null,
      )).thenAnswer((_) async => Right(product));

      // Act
      final result = await usecase(GetProductByIdParams(
        productId: productId,
        type: type,
        templateId: null,
      ));

      // Assert
      expect(result, equals(Right(product)));
      verify(mockRepository.getProductById(
        productId: productId,
        type: type,
        templateId: null,
      ));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}


