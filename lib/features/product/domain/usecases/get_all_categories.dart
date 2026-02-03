import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_category.dart';
import '../repositories/product_repository.dart';

class GetAllCategoriesUseCase implements UseCase<List<ProductCategory>, GetAllCategoriesParams> {
  final ProductRepository repository;

  GetAllCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductCategory>>> call(GetAllCategoriesParams params) async {
    return await repository.getAllCategories(
      maxDepth: params.maxDepth,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetAllCategoriesParams extends Equatable {
  final int maxDepth;
  final int limit;
  final int offset;

  const GetAllCategoriesParams({
    this.maxDepth = 1,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [maxDepth, limit, offset];
}

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
