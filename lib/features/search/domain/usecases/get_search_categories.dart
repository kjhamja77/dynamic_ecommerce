import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/search_category.dart';
import '../repositories/search_repository.dart';

class GetSearchCategories implements UseCase<List<SearchCategory>, NoParams> {
  final SearchRepository repository;

  const GetSearchCategories(this.repository);

  @override
  Future<Either<Failure, List<SearchCategory>>> call(NoParams params) async {
    try {
      final categories = await repository.getSearchCategories();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
