import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/product_details_repository.dart';

class SelectSizeParams extends Equatable {
  final String productId;
  final String sizeId;

  const SelectSizeParams({
    required this.productId,
    required this.sizeId,
  });

  @override
  List<Object?> get props => [productId, sizeId];
}

class SelectSize implements UseCase<void, SelectSizeParams> {
  final ProductDetailsRepository repository;

  const SelectSize(this.repository);

  @override
  Future<Either<Failure, void>> call(SelectSizeParams params) async {
    return await repository.selectSize(params.productId, params.sizeId);
  }
}
