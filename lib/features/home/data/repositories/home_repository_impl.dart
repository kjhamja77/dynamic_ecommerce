import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/page.dart';
import '../../domain/entities/component.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/product_model.dart';
import '../datasources/home_remote_data_source.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/domain/entities/product_category.dart';
import '../../../../core/constants/app_constants.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final ProductRepository productRepository;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.productRepository,
  });

  /// Constructs full image URL from relative path
  String _constructImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    if (imagePath.startsWith('http')) {
      return imagePath;
    } else {
      return '${AppConstants.baseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}';
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getFeaturedProducts() async {
    try {
      // Use real Product API to get featured products
      final result = await productRepository.getProductList(limit: 20, offset: 0);
      
      return result.fold(
        (failure) => Left(failure),
        (productListResponse) {
          // Convert ProductModel to Product entity
          final products = productListResponse.products.map((productModel) {
            // Debug logging
            print('🔍 Product: ${productModel.name}');
            print('  - images.length: ${productModel.images.length}');
            print('  - mainImage: ${productModel.mainImage}');
            
            return ProductModel(
              id: productModel.id.toString(),
              name: productModel.name,
              description: productModel.description,
              price: productModel.price,
              originalPrice: productModel.price * 1.2, // Mock original price
              images: () {
                if (productModel.images.isNotEmpty) {
                  final imageUrls = productModel.images.map((img) => _constructImageUrl(img.url)).toList();
                  print('  - Using images array: $imageUrls');
                  return imageUrls;
                } else if (productModel.mainImage != null) {
                  final mainImageUrl = _constructImageUrl(productModel.mainImage!);
                  print('  - Using mainImage: $mainImageUrl');
                  return [mainImageUrl];
                } else {
                  print('  - No images found');
                  return <String>[];
                }
              }(),
              category: productModel.category.name,
              brand: productModel.brand ?? 'Unknown Brand',
              type: productModel.type,
              rating: 4.5, // Mock rating
              reviewCount: 100, // Mock review count
              isAvailable: productModel.inStock,
              sizes: ['S', 'M', 'L'], // Mock sizes
              colors: ['Black', 'White'], // Mock colors
              createdAt: DateTime.now(),
              favourite: productModel.favourite,
            );
          }).toList();
          
          return Right(products);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategory(String category) async {
    try {
      // Use real Product API to get products by category
      final result = await productRepository.getProductsByCategory(
        categoryIds: [1], // Mock category ID
        limit: 20,
        offset: 0,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (productListResponse) {
          // Convert ProductModel to Product entity
          final products = productListResponse.products.map((productModel) {
            return ProductModel(
              id: productModel.id.toString(),
              name: productModel.name,
              description: productModel.description,
              price: productModel.price,
              originalPrice: productModel.price * 1.2,
              images: productModel.images.isNotEmpty 
                  ? productModel.images.map((img) => _constructImageUrl(img.url)).toList()
                  : (productModel.mainImage != null 
                      ? [_constructImageUrl(productModel.mainImage!)]
                      : []),
              category: productModel.category.name,
              brand: productModel.brand ?? 'Unknown Brand',
              type: productModel.type,
              rating: 4.5,
              reviewCount: 100,
              isAvailable: productModel.inStock,
              sizes: ['S', 'M', 'L'],
              colors: ['Black', 'White'],
              createdAt: DateTime.now(),
            );
          }).toList();
          
          return Right(products);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      // Use real category API to get root categories
      final result = await productRepository.getRootCategories(maxDepth: 1);
      
      return result.fold(
        (failure) => Left(failure),
        (categories) {
          // Convert ProductCategory entities to simple string names
          final categoryNames = categories.map((category) => category.name).toList();
          return Right(categoryNames);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> getRootCategories() async {
    try {
      // Use real category API to get root categories with full details
      final result = await productRepository.getRootCategories(maxDepth: 1);
      return result;
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      if (query.isEmpty) {
        return const Right([]);
      }

      // Use real Product API to search products
      final result = await productRepository.searchProducts(
        query: query,
        limit: 20,
        offset: 0,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (productListResponse) {
          // Convert ProductModel to Product entity
          final products = productListResponse.products.map((productModel) {
            return ProductModel(
              id: productModel.id.toString(),
              name: productModel.name,
              description: productModel.description,
              price: productModel.price,
              originalPrice: productModel.price * 1.2,
              images: productModel.images.isNotEmpty 
                  ? productModel.images.map((img) => _constructImageUrl(img.url)).toList()
                  : (productModel.mainImage != null 
                      ? [_constructImageUrl(productModel.mainImage!)]
                      : []),
              category: productModel.category.name,
              brand: productModel.brand ?? 'Unknown Brand',
              type: productModel.type,
              rating: 4.5,
              reviewCount: 100,
              isAvailable: productModel.inStock,
              sizes: ['S', 'M', 'L'],
              colors: ['Black', 'White'],
              createdAt: DateTime.now(),
            );
          }).toList();
          
          return Right(products);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByBrand(String brand) async {
    try {
      // Use search functionality to find products by brand
      final result = await searchProducts(brand);
      return result.fold(
        (failure) => Left(failure),
        (products) => Right(
          products.where((product) => 
            product.brand.toLowerCase() == brand.toLowerCase()
          ).toList(),
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Page>>> getPages(int userId) async {
    try {
      final pages = await remoteDataSource.getPages(userId);
      return Right(pages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PageComponents>> getPageComponents(int componentId, int page, int pageSize) async {
    try {
      final pageComponents = await remoteDataSource.getPageComponents(componentId, page, pageSize);
      return Right(pageComponents);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getWelcomeTexts() async {
    try {
      final list = await remoteDataSource.getWelcomeTexts();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}