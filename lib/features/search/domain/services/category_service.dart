import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../product/domain/entities/product_category.dart';

/// Abstract service for category operations
/// This abstracts the dependency on ProductRepository from the search domain
abstract class CategoryService {
  /// Get root categories with specified max depth
  Future<Either<Failure, List<ProductCategory>>> getRootCategories({
    int maxDepth = 1,
  });

  /// Get categories by parent ID with specified max depth
  Future<Either<Failure, List<ProductCategory>>> getCategoriesByParentId({
    required int parentId,
    int maxDepth = 1,
  });

  /// Get all categories with pagination
  Future<Either<Failure, List<ProductCategory>>> getAllCategories({
    int maxDepth = 1,
    int limit = 20,
    int offset = 0,
  });
}
