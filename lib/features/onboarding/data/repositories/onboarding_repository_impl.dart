

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/onboarding_local_data_source.dart';
import '../datasources/onboarding_remote_data_source.dart';
import '../models/onboarding_page_model.dart';
import '../../domain/entities/onboarding_page.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;
  final OnboardingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OnboardingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted() async {
    try {
      final isCompleted = await localDataSource.isOnboardingCompleted();
      return Right(isCompleted);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeOnboarding() async {
    try {
      await localDataSource.completeOnboarding();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OnboardingPage>>> getOnboardingPages() async {
    try {
      if (await networkInfo.isConnected) {
        // Try to fetch from remote API
        try {
          final pages = await remoteDataSource.getOnboardingPages();
          return Right(pages);
        } catch (e) {
          // If remote fails, fall back to local default pages
          final pages = OnboardingPageModel.getDefaultPages();
          return Right(pages);
        }
      } else {
        // No internet connection, use default pages
        final pages = OnboardingPageModel.getDefaultPages();
        return Right(pages);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
