import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/exceptions.dart';
import 'datasources/filter_remote_data_source.dart';
import '../domain/entities/filter_options.dart';
import '../domain/entities/filter_category.dart';
import '../domain/entities/filter_brand.dart';
import '../domain/entities/filter_attribute.dart';
import '../domain/entities/filter_criteria.dart';
import '../domain/repositories/filter_repository.dart';
import 'filters_isolate.dart';

class FilterRepositoryImpl implements FilterRepository {
  final FilterRemoteDataSource remoteDataSource;

  // In-memory cache for filter options to avoid reloading the same
  // metadata repeatedly. This cache is scoped to the app process
  // and keyed by the high-level parameters used by callers.
  FilterOptions? _cachedFilterOptions;
  String? _cachedCategory;
  String? _cachedBrand;
  String? _cachedQuery;
  int? _cachedCategoryId;
  DateTime? _cacheTimestamp;
  static const Duration _cacheTtl = Duration(minutes: 5);
  
  FilterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<FilterCategory>>> getCategories({
    int page = 1,
    int limit = 6,
    int? parentId,
  }) async {
    try {
      print('🔄 FilterRepository: Fetching categories (page: $page, limit: $limit, parentId: $parentId)');
      final categories = await remoteDataSource.getCategories(
        page: page,
        limit: limit,
        parentId: parentId,
      );
      print('✅ FilterRepository: Fetched ${categories.length} categories');
      for (final category in categories) {
        print('   - ${category.name} (ID: ${category.id})');
      }
      return Right(categories);
    } on ServerException catch (e) {
      print('❌ FilterRepository: Server error fetching categories: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ FilterRepository: Unexpected error fetching categories: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FilterBrand>>> getBrands({
    int page = 1,
    int limit = 7,
  }) async {
    try {
      print('🔄 FilterRepository: Fetching brands (page: $page, limit: $limit)');
      final brands = await remoteDataSource.getBrands(
        page: page,
        limit: limit,
      );
      print('✅ FilterRepository: Fetched ${brands.length} brands');
      for (final brand in brands) {
        print('   - ${brand.name} (ID: ${brand.id})');
      }
      return Right(brands);
    } on ServerException catch (e) {
      print('❌ FilterRepository: Server error fetching brands: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ FilterRepository: Unexpected error fetching brands: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FilterAttribute>>> getAttributes({
    int page = 1,
    int limit = 50,
    List<int>? categoryIds,
  }) async {
    try {
      print('🔄 FilterRepository: Fetching attributes (page: $page, limit: $limit, categoryIds: $categoryIds)');
      final attributes = await remoteDataSource.getAttributes(
        page: page,
        limit: limit,
        categoryIds: categoryIds,
      );
      print('✅ FilterRepository: Fetched ${attributes.length} attributes');
      for (final attr in attributes) {
        print('   - ${attr.name} (ID: ${attr.id}, Values: ${attr.values.length})');
        for (final value in attr.values) {
          print('     - ${value.name} (ID: ${value.id})');
        }
      }
      return Right(attributes);
    } on ServerException catch (e) {
      print('❌ FilterRepository: Server error fetching attributes: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ FilterRepository: Unexpected error fetching attributes: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, FilterOptions>> getFilterOptions() async {
    try {
      final filterOptions = await remoteDataSource.getFilterOptions();
      return Right(filterOptions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> filterProducts(
    FilterCriteria criteria, {
    Map<int, List<int>>? parentChildMap,
  }) async {
    try {
      final result = await remoteDataSource.filterProducts(
        criteria,
        parentChildMap: parentChildMap,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, FilterOptions>> getAvailableFilters({
    String? category,
    String? brand,
    String? query,
    int? categoryId,
  }) async {
    try {
      print('🔄 FilterRepository: Loading available filters... (categoryId: $categoryId)');

      // Safe, conservative in-memory cache: only reused when the high-level
      // parameters match exactly AND the cache is still fresh. This ensures
      // we do not affect behaviour for different categories/search contexts.
      final now = DateTime.now();
      final isCacheValid = _cachedFilterOptions != null &&
          _cachedCategory == category &&
          _cachedBrand == brand &&
          _cachedQuery == query &&
          _cachedCategoryId == categoryId &&
          _cacheTimestamp != null &&
          now.difference(_cacheTimestamp!) <= _cacheTtl;

      if (isCacheValid) {
        print('✅ FilterRepository: Returning cached FilterOptions (categoryId: $categoryId)');
        return Right(_cachedFilterOptions!);
      }
      
      // Load filter data sequentially to avoid overwhelming the server
      // Pass categoryId to getAttributes if provided (required by API when category is selected)
      // Load sequentially instead of parallel to prevent timeout issues
      final filterOptionsResult = await getFilterOptions();
      final categoriesResult = await getCategories(page: 1, limit: 50);
      final brandsResult = await getBrands(page: 1, limit: 50);
      final attributesResult = await getAttributes(
        page: 1,
        limit: 50,
        categoryIds: categoryId != null ? [categoryId] : null,
      );
      
      // Extract the successful results, fail if any API call fails
      final List<FilterCategory> categories = categoriesResult.fold(
        (l) {
          print('❌ FilterRepository: Categories API failed: ${l.message}');
          throw ServerFailure('Failed to load categories: ${l.message}');
        },
        (r) => r,
      );
      
      final List<FilterBrand> brands = brandsResult.fold(
        (l) {
          print('❌ FilterRepository: Brands API failed: ${l.message}');
          throw ServerFailure('Failed to load brands: ${l.message}');
        },
        (r) => r,
      );
      
      final List<FilterAttribute> attributes = attributesResult.fold(
        (l) {
          print('❌ FilterRepository: Attributes API failed: ${l.message}');
          throw ServerFailure('Failed to load attributes: ${l.message}');
        },
        (r) => r,
      );
      
      print('✅ FilterRepository: Loaded ${categories.length} categories, ${brands.length} brands, ${attributes.length} attributes');
      
      // Get price range and sorting options from filter-options endpoint
      final filterOptionsData = filterOptionsResult.fold(
        (l) {
          print('⚠️ FilterRepository: filter-options API failed: ${l.message}. Falling back to defaults.');
          return null;
        },
        (fo) => fo,
      );
      
      // Offload aggregation (sizes/colors/materials/seasons/genders + wiring
      // into a single FilterOptions instance) to a background isolate so the
      // main isolate stays responsive while filters are prepared.
      final filterOptions = await buildFilterOptionsInBackground(
        baseOptions: filterOptionsData,
        categories: categories,
        brands: brands,
        attributes: attributes,
      );

      // Update cache after a successful load so subsequent openings of
      // the same filter context (same category/brand/query) are instant.
      _cachedFilterOptions = filterOptions;
      _cachedCategory = category;
      _cachedBrand = brand;
      _cachedQuery = query;
      _cachedCategoryId = categoryId;
      _cacheTimestamp = DateTime.now();
      
      print('✅ FilterRepository: Created FilterOptions with ${filterOptions.attributes.length} attributes');
      print('   - Sizes: ${filterOptions.availableSizes.length}');
      print('   - Colors: ${filterOptions.availableColors.length}');
      print('   - Materials: ${filterOptions.availableMaterials.length}');
      print('   - Seasons: ${filterOptions.availableSeasons.length}');
      print('   - Genders: ${filterOptions.availableGenders.length}');
      
      return Right(filterOptions);
    } on ServerException catch (e) {
      print('❌ FilterRepository: Server error loading filters: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ FilterRepository: Unexpected error loading filters: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  void clearAvailableFiltersCache() {
    _cachedFilterOptions = null;
    _cachedCategory = null;
    _cachedBrand = null;
    _cachedQuery = null;
    _cachedCategoryId = null;
    _cacheTimestamp = null;
    print('🧹 FilterRepository: Cleared available-filters cache');
  }
}


