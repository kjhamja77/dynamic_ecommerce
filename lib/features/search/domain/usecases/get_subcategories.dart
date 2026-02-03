import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/search_subcategory.dart';
import '../repositories/search_repository.dart';

class GetSubcategories implements UseCase<List<SearchSubcategory>, String> {
  final SearchRepository repository;

  const GetSubcategories(this.repository);

  @override
  Future<Either<Failure, List<SearchSubcategory>>> call(String categoryId) async {
    try {
      final subcategories = await repository.getSubcategories(categoryId);
      return Right(subcategories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
