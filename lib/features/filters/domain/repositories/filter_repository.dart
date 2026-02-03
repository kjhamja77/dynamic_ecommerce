import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/filter_options.dart';
import '../entities/filter_category.dart';
import '../entities/filter_brand.dart';
import '../entities/filter_attribute.dart';
import '../entities/filter_criteria.dart';

abstract class FilterRepository {
  Future<Either<Failure, List<FilterCategory>>> getCategories({
    int page = 1,
    int limit = 6,
    int? parentId,
  });
  
  Future<Either<Failure, List<FilterBrand>>> getBrands({
    int page = 1,
    int limit = 7,
  });
  
  Future<Either<Failure, List<FilterAttribute>>> getAttributes({
    int page = 1,
    int limit = 2,
    List<int>? categoryIds,
  });
  
  Future<Either<Failure, FilterOptions>> getFilterOptions();
  
  Future<Either<Failure, Map<String, dynamic>>> filterProducts(
    FilterCriteria criteria, {
    Map<int, List<int>>? parentChildMap,
  });
  
  Future<Either<Failure, FilterOptions>> getAvailableFilters({
    String? category,
    String? brand,
    String? query,
    int? categoryId,
  });
}


