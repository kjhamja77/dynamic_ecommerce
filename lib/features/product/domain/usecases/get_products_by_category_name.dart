import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_list_response.dart';
import '../entities/product_category.dart';
import '../repositories/product_repository.dart';

class GetProductsByCategoryNameParams extends Equatable {
  final String categoryName;
  final int limit;
  final int offset;

  const GetProductsByCategoryNameParams({
    required this.categoryName,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [categoryName, limit, offset];
}

class GetProductsByCategoryName implements UseCase<ProductListResponse, GetProductsByCategoryNameParams> {
  final ProductRepository repository;

  GetProductsByCategoryName(this.repository);

  @override
  Future<Either<Failure, ProductListResponse>> call(GetProductsByCategoryNameParams params) async {
    try {
      // First get all categories to find the one matching the name
      final categoriesResult = await repository.getRootCategories(maxDepth: 3);
      
      return await categoriesResult.fold(
        (failure) async => Left(failure),
        (categories) async {
          // Find category by name (including nested categories)
          ProductCategory? targetCategory;
          for (final cat in categories) {
            if (cat.name.toLowerCase() == params.categoryName.toLowerCase()) {
              targetCategory = cat;
              break;
            }
            // Check children recursively
            targetCategory = _findCategoryByName(cat.children, params.categoryName);
            if (targetCategory != null) break;
          }

          if (targetCategory != null) {
            // Use the found category ID to get products
            final result = await repository.getProductsByCategory(
              categoryIds: [targetCategory.id],
              limit: params.limit,
              offset: params.offset,
            );
            return result;
          } else {
            // Category not found, return empty result
            return Right(ProductListResponse(
              products: [],
              totalCount: 0,
              limit: params.limit,
              offset: params.offset,
            ));
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  ProductCategory? _findCategoryByName(List<ProductCategory> categories, String name) {
    for (final category in categories) {
      if (category.name.toLowerCase() == name.toLowerCase()) {
        return category;
      }
      // Recursively check children
      final found = _findCategoryByName(category.children, name);
      if (found != null) return found;
    }
    return null;
  }
}
