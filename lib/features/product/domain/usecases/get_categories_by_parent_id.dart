import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_category.dart';
import '../repositories/product_repository.dart';

class GetCategoriesByParentIdUseCase implements UseCase<List<ProductCategory>, GetCategoriesByParentIdParams> {
  final ProductRepository repository;

  GetCategoriesByParentIdUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductCategory>>> call(GetCategoriesByParentIdParams params) async {
    return await repository.getCategoriesByParentId(
      parentId: params.parentId,
      maxDepth: params.maxDepth,
    );
  }
}

class GetCategoriesByParentIdParams extends Equatable {
  final int parentId;
  final int maxDepth;

  const GetCategoriesByParentIdParams({
    required this.parentId,
    this.maxDepth = 1,
  });

  @override
  List<Object> get props => [parentId, maxDepth];
}

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
