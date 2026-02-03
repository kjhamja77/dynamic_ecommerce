import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/page.dart';
import '../repositories/home_repository.dart';

class GetPagesUseCase implements UseCase<List<Page>, GetPagesParams> {
  final HomeRepository repository;

  GetPagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Page>>> call(GetPagesParams params) async {
    return await repository.getPages(params.userId);
  }
}

class GetPagesParams {
  final int userId;

  GetPagesParams({required this.userId});
}
