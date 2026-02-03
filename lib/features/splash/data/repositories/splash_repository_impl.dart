import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/splash_local_data_source.dart';
import '../../domain/repositories/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SplashLocalDataSource localDataSource;

  SplashRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, bool>> isAppInitialized() async {
    try {
      final isInitialized = await localDataSource.isAppInitialized();
      return Right(isInitialized);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAppAsInitialized() async {
    try {
      await localDataSource.markAppAsInitialized();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> shouldShowLanguageSelection() async {
    try {
      final shouldShow = await localDataSource.shouldShowLanguageSelection();
      return Right(shouldShow);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserAuthenticated() async {
    try {
      final isAuthenticated = await localDataSource.isUserAuthenticated();
      return Right(isAuthenticated);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
