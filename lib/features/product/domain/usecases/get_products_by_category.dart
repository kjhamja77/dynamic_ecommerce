import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_list_response.dart';
import '../repositories/product_repository.dart';

class GetProductsByCategoryParams {
  final List<int> categoryIds;
  final int limit;
  final int offset;

  GetProductsByCategoryParams({
    required this.categoryIds,
    this.limit = 20,
    this.offset = 0,
  });
}

class GetProductsByCategory implements UseCase<ProductListResponse, GetProductsByCategoryParams> {
  final ProductRepository repository;

  GetProductsByCategory(this.repository);

  @override
  Future<Either<Failure, ProductListResponse>> call(GetProductsByCategoryParams params) async {
    return await repository.getProductsByCategory(
      categoryIds: params.categoryIds,
      limit: params.limit,
      offset: params.offset,
    );
  }
}


