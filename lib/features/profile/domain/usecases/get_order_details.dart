import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_order.dart';
import '../repositories/profile_repository.dart';

class GetOrderDetails implements UseCase<UserOrder, String> {
  final ProfileRepository repository;

  GetOrderDetails(this.repository);

  @override
  Future<Either<Failure, UserOrder>> call(String params) async {
    return await repository.getOrderDetails(params);
  }
}
