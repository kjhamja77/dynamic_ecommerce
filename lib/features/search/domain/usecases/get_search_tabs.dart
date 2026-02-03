import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/search_tab.dart';
import '../repositories/search_repository.dart';

class GetSearchTabs implements UseCase<List<SearchTab>, NoParams> {
  final SearchRepository repository;

  const GetSearchTabs(this.repository);

  @override
  Future<Either<Failure, List<SearchTab>>> call(NoParams params) async {
    try {
      final tabs = await repository.getSearchTabs();
      return Right(tabs);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
