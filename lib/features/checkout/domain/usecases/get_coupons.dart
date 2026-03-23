import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/coupon.dart';
import '../repositories/checkout_repository.dart';

class GetCoupons extends UseCase<List<Coupon>, NoParams> {
  final CheckoutRepository repository;

  GetCoupons(this.repository);

  @override
  Future<Either<Failure, List<Coupon>>> call(NoParams params) {
    return repository.getCoupons();
  }
}

