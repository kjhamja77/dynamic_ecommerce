import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_list_response.dart';
import '../repositories/product_repository.dart';

class SearchProductsParams {
  final String query;
  final int limit;
  final int offset;

  SearchProductsParams({
    required this.query,
    this.limit = 20,
    this.offset = 0,
  });
}

class SearchProducts implements UseCase<ProductListResponse, SearchProductsParams> {
  final ProductRepository repository;

  SearchProducts(this.repository);

  @override
  Future<Either<Failure, ProductListResponse>> call(SearchProductsParams params) async {
    return await repository.searchProducts(
      query: params.query,
      limit: params.limit,
      offset: params.offset,
    );
  }
}


