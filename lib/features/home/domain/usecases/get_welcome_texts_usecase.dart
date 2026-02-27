import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/home_repository.dart';

class GetWelcomeTextsUseCase {
  final HomeRepository repository;

  GetWelcomeTextsUseCase(this.repository);

  Future<Either<Failure, List<String>>> call({bool forceRefresh = false}) async {
    return await repository.getWelcomeTexts(forceRefresh: forceRefresh);
  }
}

