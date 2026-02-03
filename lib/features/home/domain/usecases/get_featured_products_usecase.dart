import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/home_repository.dart';

class GetFeaturedProductsUseCase implements UseCase<List<Product>, NoParams> {
  final HomeRepository repository;

  GetFeaturedProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) async {
    return await repository.getFeaturedProducts();
  }
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
