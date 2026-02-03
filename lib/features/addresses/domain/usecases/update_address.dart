import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/address.dart';
import '../repositories/address_repository.dart';

class UpdateAddress implements UseCase<void, Address> {
  final AddressRepository repository;

  UpdateAddress(this.repository);

  @override
  Future<Either<Failure, void>> call(Address params) async {
    try {
      await repository.updateAddress(params);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
