import 'package:dartz/dartz.dart';
import '../../domain/entities/favorite_product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import '../datasources/favorites_remote_data_source.dart';
import '../models/favorite_product_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;
  final FavoritesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final AuthRepository authRepository;

  FavoritesRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.authRepository,
  });

  @override
  Future<Either<Failure, List<FavoriteProduct>>> getFavorites() async {
    // Guests cannot have wishlist - backend may return data for guest token; return empty
    final userResult = await authRepository.getCurrentUser();
    final isGuest = userResult.fold(
      (_) => false,
      (user) => user?.isGuest ?? false,
    );
    if (isGuest) {
      return const Right([]);
    }

    if (await networkInfo.isConnected) {
      try {
        // Try to get from API first
        final remoteFavorites = await remoteDataSource.getWishlist();
        
        // Cache the remote data locally
        await localDataSource.clearFavorites();
        for (final favorite in remoteFavorites) {
          await localDataSource.addToFavorites(favorite);
        }
        
        return Right(remoteFavorites);
      } catch (e) {
        // Fallback to local data if API fails
        try {
          final localFavorites = await localDataSource.getFavorites();
          return Right(localFavorites);
        } catch (localError) {
          return Left(ServerFailure('Failed to load favorites: ${e.toString()}'));
        }
      }
    } else {
      // Offline - use local data
      try {
        final favorites = await localDataSource.getFavorites();
        return Right(favorites);
      } catch (e) {
        return Left(CacheFailure('Failed to load favorites: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(FavoriteProduct product) async {
    try {
      final productModel = FavoriteProductModel.fromEntity(product);
      
      // Always add to local storage first for immediate UI feedback
      await localDataSource.addToFavorites(productModel);
      
      if (await networkInfo.isConnected) {
        try {
          // Try to sync with API
          await remoteDataSource.addToWishlist(int.parse(product.id));
        } catch (e) {
          // API failed but local storage succeeded - this is acceptable
          // The item will be synced later when network is available
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add to favorites: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String productId) async {
    try {
      // Always remove from local storage first for immediate UI feedback
      await localDataSource.removeFromFavorites(productId);
      
      if (await networkInfo.isConnected) {
        try {
          // Try to sync with API
          await remoteDataSource.removeFromWishlist(int.parse(productId));
        } catch (e) {
          // API failed but local storage succeeded - this is acceptable
          // The removal will be synced later when network is available
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to remove from favorites: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String productId) async {
    try {
      final isFav = await localDataSource.isFavorite(productId);
      return Right(isFav);
    } catch (e) {
      return Left(CacheFailure('Failed to check favorite status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearFavorites() async {
    try {
      // Clear local storage first
      await localDataSource.clearFavorites();
      
      if (await networkInfo.isConnected) {
        try {
          // Get current wishlist and remove each item via API
          final wishlist = await remoteDataSource.getWishlist();
          for (final item in wishlist) {
            await remoteDataSource.removeFromWishlist(int.parse(item.id));
          }
        } catch (e) {
          // API failed but local storage cleared - this is acceptable
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear favorites: ${e.toString()}'));
    }
  }
}
