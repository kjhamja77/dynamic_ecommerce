import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductByIdParams {
  final int productId;
  final String type; // 'template' or 'variant'
  final int? templateId; // Required for variant type

  GetProductByIdParams({
    required this.productId,
    required this.type,
    this.templateId,
  });
}

class GetProductById implements UseCase<Product, GetProductByIdParams> {
  final ProductRepository repository;

  GetProductById(this.repository);

  @override
  Future<Either<Failure, Product>> call(GetProductByIdParams params) async {
    return await repository.getProductById(
      productId: params.productId,
      type: params.type,
      templateId: params.templateId,
    );
  }
}


