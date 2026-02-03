import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/filter_options.dart';
import '../repositories/filter_repository.dart';

class GetAvailableFilters {
  final FilterRepository repository;
  const GetAvailableFilters(this.repository);

  Future<Either<Failure, FilterOptions>> call({
    String? category, 
    String? brand, 
    String? query,
    int? categoryId,
  }) {
    return repository.getAvailableFilters(
      category: category, 
      brand: brand, 
      query: query,
      categoryId: categoryId,
    );
  }
}


