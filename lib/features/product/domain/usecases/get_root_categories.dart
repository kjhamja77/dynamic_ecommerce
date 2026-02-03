import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_category.dart';
import '../repositories/product_repository.dart';

class GetRootCategoriesUseCase implements UseCase<List<ProductCategory>, GetRootCategoriesParams> {
  final ProductRepository repository;

  GetRootCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductCategory>>> call(GetRootCategoriesParams params) async {
    return await repository.getRootCategories(maxDepth: params.maxDepth);
  }
}

class GetRootCategoriesParams extends Equatable {
  final int maxDepth;

  const GetRootCategoriesParams({
    this.maxDepth = 1,
  });

  @override
  List<Object> get props => [maxDepth];
}

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
