import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_list_response.dart';
import '../repositories/product_repository.dart';

class GetProductListParams {
  final int limit;
  final int offset;

  GetProductListParams({
    this.limit = 20,
    this.offset = 0,
  });
}

class GetProductList implements UseCase<ProductListResponse, GetProductListParams> {
  final ProductRepository repository;

  GetProductList(this.repository);

  @override
  Future<Either<Failure, ProductListResponse>> call(GetProductListParams params) async {
    return await repository.getProductList(
      limit: params.limit,
      offset: params.offset,
    );
  }
}


