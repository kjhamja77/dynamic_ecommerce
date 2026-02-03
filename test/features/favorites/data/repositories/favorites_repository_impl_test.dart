import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';
import 'package:zalando_clone_app/core/network/network_info.dart';
import 'package:zalando_clone_app/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:zalando_clone_app/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:zalando_clone_app/features/favorites/data/models/favorite_product_model.dart';
import 'package:zalando_clone_app/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:zalando_clone_app/features/favorites/domain/entities/favorite_product.dart';

import 'favorites_repository_impl_test.mocks.dart';

@GenerateMocks([
  FavoritesLocalDataSource,
  FavoritesRemoteDataSource,
  NetworkInfo,
])
void main() {
  late FavoritesRepositoryImpl repository;
  late MockFavoritesLocalDataSource mockLocalDataSource;
  late MockFavoritesRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockLocalDataSource = MockFavoritesLocalDataSource();
    mockRemoteDataSource = MockFavoritesRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = FavoritesRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getFavorites', () {
    final tFavoriteModels = [
      FavoriteProductModel(
        id: '1',
        name: 'Test Product 1',
        brand: 'Test Brand',
        price: 99.99,
        imageUrl: 'https://example.com/image1.jpg',
        category: 'Electronics',
        addedAt: DateTime(2024, 1, 1),
      ),
      FavoriteProductModel(
        id: '2',
        name: 'Test Product 2',
        brand: 'Test Brand',
        price: 149.99,
        imageUrl: 'https://example.com/image2.jpg',
        category: 'Clothing',
        addedAt: DateTime(2024, 1, 2),
      ),
    ];

    test('should return remote data when online and API call succeeds', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getWishlist()).thenAnswer((_) async => tFavoriteModels);
      when(mockLocalDataSource.clearFavorites()).thenAnswer((_) async {});
      when(mockLocalDataSource.addToFavorites(any)).thenAnswer((_) async {});

      // act
      final result = await repository.getFavorites();

      // assert
      expect(result, Right(tFavoriteModels));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getWishlist());
      verify(mockLocalDataSource.clearFavorites());
      verify(mockLocalDataSource.addToFavorites(tFavoriteModels[0]));
      verify(mockLocalDataSource.addToFavorites(tFavoriteModels[1]));
    });

    test('should return local data when online but API call fails', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getWishlist()).thenThrow(Exception('API Error'));
      when(mockLocalDataSource.getFavorites()).thenAnswer((_) async => tFavoriteModels);

      // act
      final result = await repository.getFavorites();

      // assert
      expect(result, Right(tFavoriteModels));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getWishlist());
      verify(mockLocalDataSource.getFavorites());
    });

    test('should return local data when offline', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.getFavorites()).thenAnswer((_) async => tFavoriteModels);

      // act
      final result = await repository.getFavorites();

      // assert
      expect(result, Right(tFavoriteModels));
      verify(mockNetworkInfo.isConnected);
      verify(mockLocalDataSource.getFavorites());
      verifyNever(mockRemoteDataSource.getWishlist());
    });

    test('should return ServerFailure when both API and local data fail', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getWishlist()).thenThrow(Exception('API Error'));
      when(mockLocalDataSource.getFavorites()).thenThrow(Exception('Local Error'));

      // act
      final result = await repository.getFavorites();

      // assert
      expect(result, Left(ServerFailure('Failed to load favorites: Exception: API Error')));
    });

    test('should return CacheFailure when offline and local data fails', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.getFavorites()).thenThrow(Exception('Local Error'));

      // act
      final result = await repository.getFavorites();

      // assert
      expect(result, Left(CacheFailure('Failed to load favorites: Exception: Local Error')));
    });
  });

  group('addToFavorites', () {
    final tFavorite = FavoriteProduct(
      id: '1',
      name: 'Test Product',
      brand: 'Test Brand',
      price: 99.99,
      imageUrl: 'https://example.com/image.jpg',
      category: 'Electronics',
      addedAt: DateTime(2024, 1, 1),
    );

    test('should add to local storage and sync with API when online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockLocalDataSource.addToFavorites(any)).thenAnswer((_) async {});
      when(mockRemoteDataSource.addToWishlist(1)).thenAnswer((_) async {});

      // act
      final result = await repository.addToFavorites(tFavorite);

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.addToFavorites(any));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.addToWishlist(1));
    });

    test('should add to local storage only when offline', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.addToFavorites(any)).thenAnswer((_) async {});

      // act
      final result = await repository.addToFavorites(tFavorite);

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.addToFavorites(any));
      verify(mockNetworkInfo.isConnected);
      verifyNever(mockRemoteDataSource.addToWishlist(any));
    });

    test('should succeed even if API call fails after local storage succeeds', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockLocalDataSource.addToFavorites(any)).thenAnswer((_) async {});
      when(mockRemoteDataSource.addToWishlist(1)).thenThrow(Exception('API Error'));

      // act
      final result = await repository.addToFavorites(tFavorite);

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.addToFavorites(any));
      verify(mockRemoteDataSource.addToWishlist(1));
    });

    test('should return CacheFailure when local storage fails', () async {
      // arrange
      when(mockLocalDataSource.addToFavorites(any)).thenThrow(Exception('Local Error'));

      // act
      final result = await repository.addToFavorites(tFavorite);

      // assert
      expect(result, Left(CacheFailure('Failed to add to favorites: Exception: Local Error')));
    });
  });

  group('removeFromFavorites', () {
    const tProductId = '1';

    test('should remove from local storage and sync with API when online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockLocalDataSource.removeFromFavorites(tProductId)).thenAnswer((_) async {});
      when(mockRemoteDataSource.removeFromWishlist(1)).thenAnswer((_) async {});

      // act
      final result = await repository.removeFromFavorites(tProductId);

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.removeFromFavorites(tProductId));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.removeFromWishlist(1));
    });

    test('should remove from local storage only when offline', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.removeFromFavorites(tProductId)).thenAnswer((_) async {});

      // act
      final result = await repository.removeFromFavorites(tProductId);

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.removeFromFavorites(tProductId));
      verify(mockNetworkInfo.isConnected);
      verifyNever(mockRemoteDataSource.removeFromWishlist(any));
    });

    test('should succeed even if API call fails after local storage succeeds', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockLocalDataSource.removeFromFavorites(tProductId)).thenAnswer((_) async {});
      when(mockRemoteDataSource.removeFromWishlist(1)).thenThrow(Exception('API Error'));

      // act
      final result = await repository.removeFromFavorites(tProductId);

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.removeFromFavorites(tProductId));
      verify(mockRemoteDataSource.removeFromWishlist(1));
    });

    test('should return CacheFailure when local storage fails', () async {
      // arrange
      when(mockLocalDataSource.removeFromFavorites(tProductId)).thenThrow(Exception('Local Error'));

      // act
      final result = await repository.removeFromFavorites(tProductId);

      // assert
      expect(result, Left(CacheFailure('Failed to remove from favorites: Exception: Local Error')));
    });
  });

  group('isFavorite', () {
    const tProductId = '1';

    test('should return favorite status from local storage', () async {
      // arrange
      when(mockLocalDataSource.isFavorite(tProductId)).thenAnswer((_) async => true);

      // act
      final result = await repository.isFavorite(tProductId);

      // assert
      expect(result, const Right(true));
      verify(mockLocalDataSource.isFavorite(tProductId));
    });

    test('should return CacheFailure when local storage fails', () async {
      // arrange
      when(mockLocalDataSource.isFavorite(tProductId)).thenThrow(Exception('Local Error'));

      // act
      final result = await repository.isFavorite(tProductId);

      // assert
      expect(result, Left(CacheFailure('Failed to check favorite status: Exception: Local Error')));
    });
  });

  group('clearFavorites', () {
    final tFavoriteModels = [
      FavoriteProductModel(
        id: '1',
        name: 'Test Product 1',
        brand: 'Test Brand',
        price: 99.99,
        imageUrl: 'https://example.com/image1.jpg',
        category: 'Electronics',
        addedAt: DateTime(2024, 1, 1),
      ),
    ];

    test('should clear local storage and sync with API when online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockLocalDataSource.clearFavorites()).thenAnswer((_) async {});
      when(mockRemoteDataSource.getWishlist()).thenAnswer((_) async => tFavoriteModels);
      when(mockRemoteDataSource.removeFromWishlist(1)).thenAnswer((_) async {});

      // act
      final result = await repository.clearFavorites();

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.clearFavorites());
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getWishlist());
      verify(mockRemoteDataSource.removeFromWishlist(1));
    });

    test('should clear local storage only when offline', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.clearFavorites()).thenAnswer((_) async {});

      // act
      final result = await repository.clearFavorites();

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.clearFavorites());
      verify(mockNetworkInfo.isConnected);
      verifyNever(mockRemoteDataSource.getWishlist());
    });

    test('should succeed even if API calls fail after local storage succeeds', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockLocalDataSource.clearFavorites()).thenAnswer((_) async {});
      when(mockRemoteDataSource.getWishlist()).thenThrow(Exception('API Error'));

      // act
      final result = await repository.clearFavorites();

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.clearFavorites());
      verify(mockRemoteDataSource.getWishlist());
    });

    test('should return CacheFailure when local storage fails', () async {
      // arrange
      when(mockLocalDataSource.clearFavorites()).thenThrow(Exception('Local Error'));

      // act
      final result = await repository.clearFavorites();

      // assert
      expect(result, Left(CacheFailure('Failed to clear favorites: Exception: Local Error')));
    });
  });
}
