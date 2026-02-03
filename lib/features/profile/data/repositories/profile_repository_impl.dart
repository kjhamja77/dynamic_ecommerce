import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_order.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProfile = await remoteDataSource.getUserProfile();
        await localDataSource.cacheUserProfile(remoteProfile);
        return Right(remoteProfile);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final localProfile = await localDataSource.getUserProfile();
        if (localProfile != null) {
          return Right(localProfile);
        } else {
          return Left(CacheFailure('No cached profile data'));
        }
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile) async {
    if (await networkInfo.isConnected) {
      try {
        final profileModel = UserProfileModel.fromEntity(profile);
        final updatedProfile = await remoteDataSource.updateUserProfile(profileModel);
        await localDataSource.cacheUserProfile(updatedProfile);
        return Right(updatedProfile);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<UserOrder>>> getUserOrders() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrders = await remoteDataSource.getUserOrders();
        await localDataSource.cacheUserOrders(remoteOrders);
        return Right(remoteOrders);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final localOrders = await localDataSource.getUserOrders();
        return Right(localOrders);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, UserOrder>> getOrderDetails(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        final order = await remoteDataSource.getOrderDetails(orderId);
        return Right(order);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearUserProfile();
      await localDataSource.clearUserOrders();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      await localDataSource.clearUserProfile();
      await localDataSource.clearUserOrders();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
