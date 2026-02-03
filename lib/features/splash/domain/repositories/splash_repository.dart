import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class SplashRepository {
  Future<Either<Failure, bool>> isAppInitialized();
  Future<Either<Failure, void>> markAppAsInitialized();
  Future<Either<Failure, bool>> shouldShowLanguageSelection();
  Future<Either<Failure, bool>> isUserAuthenticated();
}
