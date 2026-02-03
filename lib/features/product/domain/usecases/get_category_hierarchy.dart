import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_category.dart';
import '../repositories/product_repository.dart';

class GetCategoryHierarchy implements UseCase<List<ProductCategory>, NoParams> {
  final ProductRepository repository;

  GetCategoryHierarchy(this.repository);

  @override
  Future<Either<Failure, List<ProductCategory>>> call(NoParams params) async {
    return await repository.getRootCategories(maxDepth: 3);
  }
}
