import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/banner.dart';

/// Repository interface for banner operations
abstract class BannerRepository {
  /// Get all active banners for the home screen
  Future<Either<Failure, List<Banner>>> getBanners();
  
  /// Get banners by category or type
  Future<Either<Failure, List<Banner>>> getBannersByType(String type);
  
  /// Get featured banners (for carousel)
  Future<Either<Failure, List<Banner>>> getFeaturedBanners();
}
