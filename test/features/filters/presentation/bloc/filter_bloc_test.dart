import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';
import 'package:zalando_clone_app/features/filters/domain/entities/filter_criteria.dart';
import 'package:zalando_clone_app/features/filters/domain/entities/filter_options.dart';
import 'package:zalando_clone_app/features/filters/domain/entities/filter_category.dart';
import 'package:zalando_clone_app/features/filters/domain/entities/filter_brand.dart';
import 'package:zalando_clone_app/features/filters/domain/entities/filter_attribute.dart';
import 'package:zalando_clone_app/features/filters/domain/repositories/filter_repository.dart';
import 'package:zalando_clone_app/features/filters/presentation/bloc/filter_bloc.dart';

import 'filter_bloc_test.mocks.dart';

@GenerateMocks([FilterRepository])
void main() {
  group('FilterBloc', () {
    late FilterBloc filterBloc;
    late MockFilterRepository mockRepository;

    setUp(() {
      mockRepository = MockFilterRepository();
      filterBloc = FilterBloc(repository: mockRepository);
    });

    tearDown(() {
      filterBloc.close();
    });

    test('initial state should be FilterInitial', () {
      // Assert
      expect(filterBloc.state, isA<FilterInitial>());
    });

    group('LoadFilterOptions', () {
      test('should emit [FilterLoading, FilterOptionsLoaded] when successful', () {
        // Arrange
        const filterOptions = FilterOptions();
        when(mockRepository.getAvailableFilters(
          category: anyNamed('category'),
          brand: anyNamed('brand'),
          query: anyNamed('query'),
        )).thenAnswer((_) async => const Right(filterOptions));

        // Act & Assert
        blocTest<FilterBloc, FilterState>(
          'should emit loading then loaded state',
          build: () => filterBloc,
          act: (bloc) => bloc.add(const LoadFilterOptions()),
          expect: () => [
            isA<FilterLoading>(),
            
            isA<FilterOptionsLoaded>(),
          ],
        );
      });

      test('should emit [FilterLoading, FilterError] when repository fails', () {
        // Arrange
        when(mockRepository.getAvailableFilters(
          category: anyNamed('category'),
          brand: anyNamed('brand'),
          query: anyNamed('query'),
        )).thenAnswer((_) async => const Left(ServerFailure('Server error')));

        // Act & Assert
        blocTest<FilterBloc, FilterState>(
          'should emit loading then error state',
          build: () => filterBloc,
          act: (bloc) => bloc.add(const LoadFilterOptions()),
          expect: () => [
            isA<FilterLoading>(),
            isA<FilterError>(),
          ],
        );
      });

      test('should pass correct parameters to repository', () async {
        // Arrange
        const filterOptions = FilterOptions();
        when(mockRepository.getAvailableFilters(
          category: anyNamed('category'),
          brand: anyNamed('brand'),
          query: anyNamed('query'),
        )).thenAnswer((_) async => const Right(filterOptions));

        // Act
        filterBloc.add(const LoadFilterOptions(
          category: 'Shoes',
          brand: 'Nike',
          query: 'running shoes',
        ));

        // Assert
        await untilCalled(mockRepository.getAvailableFilters(
          category: anyNamed('category'),
          brand: anyNamed('brand'),
          query: anyNamed('query'),
        ));
        verify(mockRepository.getAvailableFilters(
          category: 'Shoes',
          brand: 'Nike',
          query: 'running shoes',
        )).called(1);
      });
    });

    group('LoadCategories', () {
      test('should emit [FilterLoading, CategoriesLoaded] when successful', () {
        // Arrange
        const categories = [
          FilterCategory(
            id: 1,
            name: 'Shoes',
            completeName: 'All / Shoes',
            sequence: 1,
            productCount: 100,
          ),
        ];
        when(mockRepository.getCategories(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
          parentId: anyNamed('parentId'),
        )).thenAnswer((_) async => const Right(categories));

        // Act & Assert
        blocTest<FilterBloc, FilterState>(
          'should emit loading then categories loaded state',
          build: () => filterBloc,
          act: (bloc) => bloc.add(const LoadCategories()),
          expect: () => [
            isA<FilterLoading>(),
            isA<CategoriesLoaded>(),
          ],
        );
      });

      test('should emit [FilterLoading, FilterError] when repository fails', () {
        // Arrange
        when(mockRepository.getCategories(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
          parentId: anyNamed('parentId'),
        )).thenAnswer((_) async => const Left(ServerFailure('Server error')));

        // Act & Assert
        blocTest<FilterBloc, FilterState>(
          'should emit loading then error state',
          build: () => filterBloc,
          act: (bloc) => bloc.add(const LoadCategories()),
          expect: () => [
            isA<FilterLoading>(),
            isA<FilterError>(),
          ],
        );
      });
    });

    group('LoadBrands', () {
      test('should emit [FilterLoading, BrandsLoaded] when successful', () {
        // Arrange
        const brands = [
          FilterBrand(
            id: 1,
            name: 'Nike',
            productCount: 150,
          ),
        ];
        when(mockRepository.getBrands(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => const Right(brands));

        // Act & Assert
        blocTest<FilterBloc, FilterState>(
          'should emit loading then brands loaded state',
          build: () => filterBloc,
          act: (bloc) => bloc.add(const LoadBrands()),
          expect: () => [
            isA<FilterLoading>(),
            isA<BrandsLoaded>(),
          ],
        );
      });
    });

    group('LoadAttributes', () {
      test('should emit [FilterLoading, AttributesLoaded] when successful', () {
        // Arrange
        const attributes = [
          FilterAttribute(
            id: 1,
            name: 'Size',
            type: 'text',
          ),
        ];
        when(mockRepository.getAttributes(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => const Right(attributes));

        // Act & Assert
        blocTest<FilterBloc, FilterState>(
          'should emit loading then attributes loaded state',
          build: () => filterBloc,
          act: (bloc) => bloc.add(const LoadAttributes()),
          expect: () => [
            isA<FilterLoading>(),
            isA<AttributesLoaded>(),
          ],
        );
      });
    });

    group('ApplyFilters', () {
      test('should emit [FilterProductsLoading, FilterProductsLoaded] when successful', () {
        // Arrange
        const criteria = FilterCriteria(
          minPrice: 10.0,
          maxPrice: 100.0,
          brand: 'Nike',
        );
        const results = {
          'products': [
            {
              'id': 1,
              'name': 'Nike Air Max',
              'price': 50.0,
            }
          ],
          'total': 1,
        };
        when(mockRepository.filterProducts(any))
            .thenAnswer((_) async => const Right(results));

        // Act & Assert
        blocTest<FilterBloc, FilterState>(
          'should emit loading then products loaded state',
          build: () => filterBloc,
          act: (bloc) => bloc.add(ApplyFilters(criteria)),
          expect: () => [
            isA<FilterProductsLoading>(),
            isA<FilterProductsLoaded>(),
          ],
        );
      });

      test('should emit [FilterProductsLoading, FilterEmpty] when no results', () {
        // Arrange
        const criteria = FilterCriteria(
          minPrice: 1000.0,
          maxPrice: 2000.0,
        );
        const results = <String, dynamic>{};
        when(mockRepository.filterProducts(any))
            .thenAnswer((_) async => const Right(results));

        // Act & Assert
        blocTest<FilterBloc, FilterState>(
          'should emit loading then empty state',
          build: () => filterBloc,
          act: (bloc) => bloc.add(ApplyFilters(criteria)),
          expect: () => [
            isA<FilterProductsLoading>(),
            isA<FilterEmpty>(),
          ],
        );
      });

      test('should emit [FilterProductsLoading, FilterError] when repository fails', () {
        // Arrange
        const criteria = FilterCriteria();
        when(mockRepository.filterProducts(any))
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));

        // Act & Assert
        blocTest<FilterBloc, FilterState>(
          'should emit loading then error state',
          build: () => filterBloc,
          act: (bloc) => bloc.add(ApplyFilters(criteria)),
          expect: () => [
            isA<FilterProductsLoading>(),
            isA<FilterError>(),
          ],
        );
      });
    });

    group('UpdateFilterCriteria', () {
      test('should update current criteria when FilterOptionsLoaded state exists', () {
        // Arrange
        const initialOptions = FilterOptions();
        const initialCriteria = FilterCriteria();
        const newCriteria = FilterCriteria(
          minPrice: 10.0,
          maxPrice: 100.0,
        );

        when(mockRepository.getAvailableFilters(
          category: anyNamed('category'),
          brand: anyNamed('brand'),
          query: anyNamed('query'),
        )).thenAnswer((_) async => const Right(initialOptions));

        // Act & Assert
        blocTest<FilterBloc, FilterState>(
          'should update criteria in loaded state',
          build: () => filterBloc,
          act: (bloc) {
            bloc.add(const LoadFilterOptions());
            bloc.add(UpdateFilterCriteria(newCriteria));
          },
          expect: () => [
            isA<FilterLoading>(),
            FilterOptionsLoaded(
              options: initialOptions,
              currentCriteria: initialCriteria,
            ),
            FilterOptionsLoaded(
              options: initialOptions,
              currentCriteria: newCriteria,
            ),
          ],
        );
      });
    });

    group('ClearFilters', () {
      test('should reset criteria to default when FilterOptionsLoaded state exists', () {
        // Arrange
        const initialOptions = FilterOptions();
        const initialCriteria = FilterCriteria(
          minPrice: 10.0,
          maxPrice: 100.0,
          brand: 'Nike',
        );
        const defaultCriteria = FilterCriteria();

        when(mockRepository.getAvailableFilters(
          category: anyNamed('category'),
          brand: anyNamed('brand'),
          query: anyNamed('query'),
        )).thenAnswer((_) async => const Right(initialOptions));

        // Act & Assert
        blocTest<FilterBloc, FilterState>(
          'should clear criteria in loaded state',
          build: () => filterBloc,
          act: (bloc) {
            bloc.add(const LoadFilterOptions());
            bloc.add(UpdateFilterCriteria(initialCriteria));
            bloc.add(ClearFilters());
          },
          expect: () => [
            isA<FilterLoading>(),
            FilterOptionsLoaded(
              options: initialOptions,
              currentCriteria: const FilterCriteria(),
            ),
            FilterOptionsLoaded(
              options: initialOptions,
              currentCriteria: initialCriteria,
            ),
            FilterOptionsLoaded(
              options: initialOptions,
              currentCriteria: defaultCriteria,
            ),
          ],
        );
      });
    });

    group('currentCriteria getter', () {
      test('should return current criteria', () {
        // Arrange
        const criteria = FilterCriteria(
          minPrice: 10.0,
          maxPrice: 100.0,
        );

        // Act
        filterBloc.add(UpdateFilterCriteria(criteria));

        // Assert
        expect(filterBloc.currentCriteria, criteria);
      });
    });
  });
}
