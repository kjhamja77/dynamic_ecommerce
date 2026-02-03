import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';
import 'package:zalando_clone_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:zalando_clone_app/features/home/data/models/page_model.dart';
import 'package:zalando_clone_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:zalando_clone_app/features/home/domain/entities/page.dart';
import 'package:zalando_clone_app/features/product/domain/repositories/product_repository.dart';

import 'home_repository_impl_test.mocks.dart';

@GenerateMocks([HomeRemoteDataSource, ProductRepository])
void main() {
  late HomeRepositoryImpl repository;
  late MockHomeRemoteDataSource mockRemoteDataSource;
  late MockProductRepository mockProductRepository;

  setUp(() {
    mockRemoteDataSource = MockHomeRemoteDataSource();
    mockProductRepository = MockProductRepository();
    repository = HomeRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      productRepository: mockProductRepository,
    );
  });

  group('getPages', () {
    const tUserId = 1;
  final tPageModels = [
    PageModel(
      id: 1,
      name: 'home',
      title: 'Home',
      description: 'Main home page',
      icon: 'home_icon',
      order: 1,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    PageModel(
      id: 2,
      name: 'catalog',
      title: 'Catalog',
      description: 'Product catalog page',
      icon: 'catalog_icon',
      order: 2,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

    test('should return pages when remote data source succeeds', () async {
      // arrange
      when(mockRemoteDataSource.getPages(tUserId))
          .thenAnswer((_) async => tPageModels);

      // act
      final result = await repository.getPages(tUserId);

      // assert
      expect(result, Right(tPageModels));
      verify(mockRemoteDataSource.getPages(tUserId));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should return failure when remote data source fails', () async {
      // arrange
      when(mockRemoteDataSource.getPages(tUserId))
          .thenThrow(Exception('Server error'));

      // act
      final result = await repository.getPages(tUserId);

      // assert
      expect(result, Left(ServerFailure('Exception: Server error')));
      verify(mockRemoteDataSource.getPages(tUserId));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });
}
