import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_order.dart';
import '../repositories/profile_repository.dart';

class GetUserOrders implements UseCase<List<UserOrder>, NoParams> {
  final ProfileRepository repository;

  GetUserOrders(this.repository);

  @override
  Future<Either<Failure, List<UserOrder>>> call(NoParams params) async {
    return await repository.getUserOrders();
  }
}
