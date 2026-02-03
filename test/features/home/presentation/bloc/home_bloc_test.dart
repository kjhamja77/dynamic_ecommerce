import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';
import 'package:zalando_clone_app/features/home/domain/entities/page.dart';
import 'package:zalando_clone_app/features/home/domain/entities/product.dart';
import 'package:zalando_clone_app/features/home/domain/usecases/get_featured_products_usecase.dart';
import 'package:zalando_clone_app/features/home/domain/usecases/get_pages_usecase.dart';
import 'package:zalando_clone_app/features/home/domain/usecases/get_page_components_usecase.dart';
import 'package:zalando_clone_app/features/product/domain/usecases/get_root_categories.dart';
import 'package:zalando_clone_app/features/home/presentation/bloc/home_bloc.dart';

import 'home_bloc_test.mocks.dart';

@GenerateMocks([GetFeaturedProductsUseCase, GetPagesUseCase, GetPageComponentsUseCase, GetRootCategoriesUseCase])
void main() {
  late HomeBloc homeBloc;
  late MockGetFeaturedProductsUseCase mockGetFeaturedProductsUseCase;
  late MockGetPagesUseCase mockGetPagesUseCase;
  late MockGetPageComponentsUseCase mockGetPageComponentsUseCase;
  late MockGetRootCategoriesUseCase mockGetRootCategoriesUseCase;

  setUp(() {
    mockGetFeaturedProductsUseCase = MockGetFeaturedProductsUseCase();
    mockGetPagesUseCase = MockGetPagesUseCase();
    mockGetPageComponentsUseCase = MockGetPageComponentsUseCase();
    mockGetRootCategoriesUseCase = MockGetRootCategoriesUseCase();
    homeBloc = HomeBloc(
      getFeaturedProductsUseCase: mockGetFeaturedProductsUseCase,
      getPagesUseCase: mockGetPagesUseCase,
      getPageComponentsUseCase: mockGetPageComponentsUseCase,
      getRootCategoriesUseCase: mockGetRootCategoriesUseCase,
    );
  });

  tearDown(() {
    homeBloc.close();
  });

  group('HomeBloc', () {
    final tProducts = [
      Product(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        images: ['image1.jpg'],
        category: 'Test Category',
        brand: 'Test Brand',
        type: 'variant',
        rating: 4.5,
        reviewCount: 100,
        isAvailable: true,
        sizes: ['S', 'M', 'L'],
        colors: ['Red', 'Blue'],
        createdAt: DateTime.now(),
      ),
    ];

    final tPages = [
      Page(
        id: 1,
        name: 'home',
        title: 'Home',
        description: 'Main home page',
        icon: 'home_icon',
        order: 1,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      Page(
        id: 2,
        name: 'catalog',
        title: 'Catalog',
        description: 'Product catalog page',
        icon: 'catalog_icon',
        order: 2,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ];

    test('initial state should be HomeInitial', () {
      expect(homeBloc.state, equals(HomeInitial()));
    });

    group('LoadFeaturedProducts', () {
      blocTest<HomeBloc, HomeState>(
        'should emit [HomeLoading, HomeLoaded] when successful',
        build: () {
          when(mockGetFeaturedProductsUseCase(any))
              .thenAnswer((_) async => Right(tProducts));
          return homeBloc;
        },
        act: (bloc) => bloc.add(LoadFeaturedProducts()),
        expect: () => [
          HomeLoading(),
          HomeLoaded(
            featuredProducts: tProducts,
            categories: const [],
          ),
          HomeLoaded(
            featuredProducts: tProducts,
            categories: const [
              'Shoes',
              'Clothing',
              'Accessories',
              'Sports',
              'Outdoor',
              'Luxury',
            ],
          ),
        ],
        verify: (_) {
          verify(mockGetFeaturedProductsUseCase(NoParams())).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'should emit [HomeLoading, HomeError] when failed',
        build: () {
          when(mockGetFeaturedProductsUseCase(any))
              .thenAnswer((_) async => Left(ServerFailure('Server error')));
          return homeBloc;
        },
        act: (bloc) => bloc.add(LoadFeaturedProducts()),
        expect: () => [
          HomeLoading(),
          HomeError('Server error'),
        ],
        verify: (_) {
          verify(mockGetFeaturedProductsUseCase(NoParams())).called(1);
        },
      );
    });

    group('LoadPages', () {
      const tUserId = 1;

      blocTest<HomeBloc, HomeState>(
        'should emit [HomeLoading, HomeLoaded] when successful',
        build: () {
          when(mockGetPagesUseCase(any))
              .thenAnswer((_) async => Right(tPages));
          return homeBloc;
        },
        act: (bloc) => bloc.add(LoadPages(tUserId)),
        expect: () => [
          HomeLoading(),
          HomeLoaded(
            featuredProducts: const [],
            categories: const [],
            pages: tPages,
          ),
        ],
        verify: (_) {
          verify(mockGetPagesUseCase(any)).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'should emit [HomeLoading, HomeError] when failed',
        build: () {
          when(mockGetPagesUseCase(any))
              .thenAnswer((_) async => Left(ServerFailure('Server error')));
          return homeBloc;
        },
        act: (bloc) => bloc.add(LoadPages(tUserId)),
        expect: () => [
          HomeLoading(),
          HomeError('Server error'),
        ],
        verify: (_) {
          verify(mockGetPagesUseCase(any)).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'should update existing HomeLoaded state with pages',
        build: () {
          when(mockGetPagesUseCase(any))
              .thenAnswer((_) async => Right(tPages));
          return homeBloc;
        },
        seed: () => HomeLoaded(
          featuredProducts: tProducts,
          categories: const ['Shoes', 'Clothing'],
        ),
        act: (bloc) => bloc.add(LoadPages(tUserId)),
        expect: () => [
          HomeLoaded(
            featuredProducts: tProducts,
            categories: const ['Shoes', 'Clothing'],
            pages: const [],
            isFetchingPages: true,
          ),
          HomeLoaded(
            featuredProducts: tProducts,
            categories: const ['Shoes', 'Clothing'],
            pages: tPages,
            isFetchingPages: false,
          ),
        ],
        verify: (_) {
          verify(mockGetPagesUseCase(any)).called(1);
        },
      );
    });

    group('LoadCategories', () {
      blocTest<HomeBloc, HomeState>(
        'should update categories in existing HomeLoaded state',
        build: () => homeBloc,
        seed: () => HomeLoaded(
          featuredProducts: tProducts,
          categories: const [],
        ),
        act: (bloc) => bloc.add(LoadCategories()),
        expect: () => [
          HomeLoaded(
            featuredProducts: tProducts,
            categories: const [
              'Shoes',
              'Clothing',
              'Accessories',
              'Sports',
              'Outdoor',
              'Luxury',
            ],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'should not emit when state is not HomeLoaded',
        build: () => homeBloc,
        seed: () => HomeInitial(),
        act: (bloc) => bloc.add(LoadCategories()),
        expect: () => [],
      );
    });

    group('SearchProducts', () {
      blocTest<HomeBloc, HomeState>(
        'should filter products based on query',
        build: () => homeBloc,
        seed: () => HomeLoaded(
          featuredProducts: tProducts,
          categories: const ['Shoes'],
        ),
        act: (bloc) => bloc.add(SearchProducts('Test')),
        expect: () => [
          HomeLoaded(
            featuredProducts: tProducts,
            categories: const ['Shoes'],
            searchResults: tProducts,
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'should clear search results when query is empty',
        build: () => homeBloc,
        seed: () => HomeLoaded(
          featuredProducts: tProducts,
          categories: const ['Shoes'],
          searchResults: tProducts,
        ),
        act: (bloc) => bloc.add(SearchProducts('')),
        expect: () => [
          HomeLoaded(
            featuredProducts: tProducts,
            categories: const ['Shoes'],
            searchResults: const [],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'should not emit when state is not HomeLoaded',
        build: () => homeBloc,
        seed: () => HomeInitial(),
        act: (bloc) => bloc.add(SearchProducts('Test')),
        expect: () => [],
      );
    });
  });
}
