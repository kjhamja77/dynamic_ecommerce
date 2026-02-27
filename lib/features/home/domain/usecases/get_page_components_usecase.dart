import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/component.dart';
import '../repositories/home_repository.dart';

class GetPageComponentsUseCase implements UseCase<PageComponents, GetPageComponentsParams> {
  final HomeRepository repository;

  GetPageComponentsUseCase(this.repository);

  @override
  Future<Either<Failure, PageComponents>> call(GetPageComponentsParams params) async {
    return await repository.getPageComponents(
      params.componentId,
      params.page,
      params.pageSize,
      forceRefresh: params.forceRefresh,
    );
  }
}

class GetPageComponentsParams {
  final int componentId;
  final int page;
  final int pageSize;
  final bool forceRefresh;

  GetPageComponentsParams({
    required this.componentId,
    required this.page,
    required this.pageSize,
    this.forceRefresh = false,
  });
}
