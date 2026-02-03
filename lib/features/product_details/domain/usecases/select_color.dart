import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/product_details_repository.dart';

class SelectColorParams extends Equatable {
  final String productId;
  final String colorId;

  const SelectColorParams({
    required this.productId,
    required this.colorId,
  });

  @override
  List<Object?> get props => [productId, colorId];
}

class SelectColor implements UseCase<void, SelectColorParams> {
  final ProductDetailsRepository repository;

  const SelectColor(this.repository);

  @override
  Future<Either<Failure, void>> call(SelectColorParams params) async {
    return await repository.selectColor(params.productId, params.colorId);
  }
}
