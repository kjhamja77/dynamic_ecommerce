import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/banner.dart';
import '../../domain/repositories/banner_repository.dart';
import '../models/banner_model.dart';

/// Banner repository implementation with demo data
class BannerRepositoryImpl implements BannerRepository {
  @override
  Future<Either<Failure, List<Banner>>> getBanners() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Return demo banner data
      return Right(_getDemoBanners());
    } catch (e) {
      return Left(ServerFailure('Failed to load banners: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Banner>>> getBannersByType(String type) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Filter banners by type (demo implementation)
      final allBanners = _getDemoBanners();
      final filteredBanners = allBanners.where((banner) => 
        banner.title.toLowerCase().contains(type.toLowerCase()) ||
        banner.description.toLowerCase().contains(type.toLowerCase())
      ).toList();
      
      return Right(filteredBanners);
    } catch (e) {
      return Left(ServerFailure('Failed to load banners by type: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Banner>>> getFeaturedBanners() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return only active featured banners
      final allBanners = _getDemoBanners();
      final featuredBanners = allBanners
          .where((banner) => banner.isActive)
          .take(5) // Limit to 5 featured banners
          .toList();
      
      return Right(featuredBanners);
    } catch (e) {
      return Left(ServerFailure('Failed to load featured banners: ${e.toString()}'));
    }
  }

  /// Demo banner data - can be replaced with real API calls later
  List<Banner> _getDemoBanners() {
    return [
      BannerModel(
        id: 'banner_1',
        title: 'Summer Collection 2025',
        description: 'Discover the latest summer trends with up to 50% off',
        imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=400&fit=crop',
        actionUrl: '/summer-collection',
        actionText: 'Shop Now',
        isActive: true,
        sortOrder: 1,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      BannerModel(
        id: 'banner_2',
        title: 'New Arrivals',
        description: 'Fresh styles just landed. Be the first to explore',
        imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=800&h=400&fit=crop',
        actionUrl: '/new-arrivals',
        actionText: 'Explore',
        isActive: true,
        sortOrder: 2,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      BannerModel(
        id: 'banner_3',
        title: 'Premium Brands',
        description: 'Luxury fashion from the world\'s top designers',
        imageUrl: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800&h=400&fit=crop',
        actionUrl: '/premium-brands',
        actionText: 'Discover',
        isActive: true,
        sortOrder: 3,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      BannerModel(
        id: 'banner_4',
        title: 'Athletic Wear',
        description: 'Performance meets style in our athletic collection',
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop',
        actionUrl: '/athletic-wear',
        actionText: 'Shop Sports',
        isActive: true,
        sortOrder: 4,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      BannerModel(
        id: 'banner_5',
        title: 'Accessories Sale',
        description: 'Complete your look with our accessory collection',
        imageUrl: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=800&h=400&fit=crop',
        actionUrl: '/accessories',
        actionText: null,
        isActive: true,
        sortOrder: 5,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
      BannerModel(
        id: 'banner_6',
        title: 'Sustainable Fashion',
        description: 'Eco-friendly styles that look good and do good',
        imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=400&fit=crop',
        actionUrl: '/sustainable',
        actionText: 'Learn More',
        isActive: true,
        sortOrder: 6,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      ),
    ];
  }
}
