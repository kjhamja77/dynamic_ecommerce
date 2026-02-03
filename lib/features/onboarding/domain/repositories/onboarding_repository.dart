import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/onboarding_page.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, bool>> isOnboardingCompleted();
  Future<Either<Failure, void>> completeOnboarding();
  Future<Either<Failure, List<OnboardingPage>>> getOnboardingPages();
}
