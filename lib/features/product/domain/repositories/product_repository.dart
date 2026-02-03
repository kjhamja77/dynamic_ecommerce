import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../entities/product_list_response.dart';
import '../entities/product_category.dart';

abstract class ProductRepository {
  // Get single product by ID (template or variant)
  Future<Either<Failure, Product>> getProductById({
    required int productId,
    required String type, // 'template' or 'variant'
    int? templateId, // Required for variant type
  });

  // Get product list with pagination
  Future<Either<Failure, ProductListResponse>> getProductList({
    int limit = 20,
    int offset = 0,
  });

  // Get products by category
  Future<Either<Failure, ProductListResponse>> getProductsByCategory({
    required List<int> categoryIds,
    int limit = 20,
    int offset = 0,
  });

  // Search products
  Future<Either<Failure, ProductListResponse>> searchProducts({
    required String query,
    int limit = 20,
    int offset = 0,
  });

  // Get root categories
  Future<Either<Failure, List<ProductCategory>>> getRootCategories({
    int maxDepth = 1,
  });

  // Get categories by parent ID
  Future<Either<Failure, List<ProductCategory>>> getCategoriesByParentId({
    required int parentId,
    int maxDepth = 1,
  });

  // Get all categories with pagination
  Future<Either<Failure, List<ProductCategory>>> getAllCategories({
    int maxDepth = 1,
    int limit = 20,
    int offset = 0,
  });
}


