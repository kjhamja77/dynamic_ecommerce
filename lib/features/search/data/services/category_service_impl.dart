import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../product/domain/entities/product_category.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../domain/services/category_service.dart';

/// Implementation of CategoryService that delegates to ProductRepository
class CategoryServiceImpl implements CategoryService {
  final ProductRepository _productRepository;

  CategoryServiceImpl({required ProductRepository productRepository})
      : _productRepository = productRepository;

  @override
  Future<Either<Failure, List<ProductCategory>>> getRootCategories({
    int maxDepth = 1,
  }) async {
    return await _productRepository.getRootCategories(maxDepth: maxDepth);
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> getCategoriesByParentId({
    required int parentId,
    int maxDepth = 1,
  }) async {
    return await _productRepository.getCategoriesByParentId(
      parentId: parentId,
      maxDepth: maxDepth,
    );
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> getAllCategories({
    int maxDepth = 1,
    int limit = 20,
    int offset = 0,
  }) async {
    return await _productRepository.getAllCategories(
      maxDepth: maxDepth,
      limit: limit,
      offset: offset,
    );
  }
}
