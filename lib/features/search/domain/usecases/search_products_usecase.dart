import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/search_params_model.dart';
import '../../data/models/search_results_model.dart';
import '../repositories/search_repository.dart';

class SearchProductsUseCase implements UseCase<SearchResults, SearchParams> {
  final SearchRepository repository;

  SearchProductsUseCase(this.repository);

  @override
  Future<Either<Failure, SearchResults>> call(SearchParams params) async {
    try {
      final results = await repository.searchProducts(params);
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
