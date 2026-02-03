import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/subcategory_details.dart';
import '../repositories/search_repository.dart';

class GetSubcategoryDetails implements UseCase<SubcategoryDetails, String> {
  final SearchRepository repository;

  const GetSubcategoryDetails(this.repository);

  @override
  Future<Either<Failure, SubcategoryDetails>> call(String subcategoryId) async {
    try {
      final subcategoryDetails = await repository.getSubcategoryDetails(subcategoryId);
      return Right(subcategoryDetails);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
