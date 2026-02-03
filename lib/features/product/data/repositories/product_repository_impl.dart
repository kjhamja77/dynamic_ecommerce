import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_list_response.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Product>> getProductById({
    required int productId,
    required String type,
    int? templateId,
  }) async {
    try {
      final product = await remoteDataSource.getProductById(
        productId: productId,
        type: type,
        templateId: templateId,
      );
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductListResponse>> getProductList({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await remoteDataSource.getProductList(
        limit: limit,
        offset: offset,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductListResponse>> getProductsByCategory({
    required List<int> categoryIds,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await remoteDataSource.getProductsByCategory(
        categoryIds: categoryIds,
        limit: limit,
        offset: offset,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductListResponse>> searchProducts({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await remoteDataSource.searchProducts(
        query: query,
        limit: limit,
        offset: offset,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> getRootCategories({
    int maxDepth = 1,
  }) async {
    try {
      final categories = await remoteDataSource.getRootCategories(maxDepth: maxDepth);
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> getCategoriesByParentId({
    required int parentId,
    int maxDepth = 1,
  }) async {
    try {
      final categories = await remoteDataSource.getCategoriesByParentId(
        parentId: parentId,
        maxDepth: maxDepth,
      );
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> getAllCategories({
    int maxDepth = 1,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final categories = await remoteDataSource.getAllCategories(
        maxDepth: maxDepth,
        limit: limit,
        offset: offset,
      );
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}


