import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';
import 'package:zalando_clone_app/features/product/data/models/product_category_model.dart';
import 'package:zalando_clone_app/features/product/data/models/product_model.dart';
import 'package:zalando_clone_app/features/product/data/models/product_list_response_model.dart';
import 'package:zalando_clone_app/features/product/domain/usecases/get_product_by_id.dart';
import 'package:zalando_clone_app/features/product/domain/usecases/get_product_list.dart';
import 'package:zalando_clone_app/features/product/domain/usecases/get_products_by_category.dart';
import 'package:zalando_clone_app/features/product/domain/usecases/search_products.dart';
import 'package:zalando_clone_app/features/product/domain/usecases/get_root_categories.dart';
import 'package:zalando_clone_app/features/product/domain/usecases/get_categories_by_parent_id.dart';
import 'package:zalando_clone_app/features/product/domain/usecases/get_all_categories.dart';
import 'package:zalando_clone_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:zalando_clone_app/features/product/presentation/bloc/product_event.dart';
import 'package:zalando_clone_app/features/product/presentation/bloc/product_state.dart';

import 'product_bloc_test.mocks.dart';

@GenerateMocks([
  GetProductById,
  GetProductList,
  GetProductsByCategory,
  SearchProducts,
  GetRootCategoriesUseCase,
  GetCategoriesByParentIdUseCase,
  GetAllCategoriesUseCase,
])
void main() {
  late ProductBloc productBloc;
  late MockGetProductById mockGetProductById;
  late MockGetProductList mockGetProductList;
  late MockGetProductsByCategory mockGetProductsByCategory;
  late MockSearchProducts mockSearchProducts;
  late MockGetRootCategoriesUseCase mockGetRootCategories;
  late MockGetCategoriesByParentIdUseCase mockGetCategoriesByParentId;
  late MockGetAllCategoriesUseCase mockGetAllCategories;

  setUp(() {
    mockGetProductById = MockGetProductById();
    mockGetProductList = MockGetProductList();
    mockGetProductsByCategory = MockGetProductsByCategory();
    mockSearchProducts = MockSearchProducts();
    mockGetRootCategories = MockGetRootCategoriesUseCase();
    mockGetCategoriesByParentId = MockGetCategoriesByParentIdUseCase();
    mockGetAllCategories = MockGetAllCategoriesUseCase();

    productBloc = ProductBloc(
      getProductById: mockGetProductById,
      getProductList: mockGetProductList,
      getProductsByCategory: mockGetProductsByCategory,
      searchProducts: mockSearchProducts,
      getRootCategories: mockGetRootCategories,
      getCategoriesByParentId: mockGetCategoriesByParentId,
      getAllCategories: mockGetAllCategories,
    );
  });

  tearDown(() {
    productBloc.close();
  });

  test('initial state should be ProductInitial', () {
    expect(productBloc.state, equals(const ProductInitial()));
  });

  group('GetProductByIdEvent', () {
    const productId = 12;
    const type = 'template';
    const templateId = 9;

    final product = ProductModel(
      id: productId,
      name: 'Storage Box',
      description: 'A storage box',
      shortDescription: 'Office storage',
      price: 15.8,
      currency: 'IQD',
      category: const ProductCategoryModel(
        id: 8, 
        name: 'Office Furniture',
        completeName: 'Office Furniture',
        sequence: 1,
      ),
      type: type,
      quantityAvailable: 18.0,
      inStock: true,
      totalVariants: 1,
      availableVariants: 1,
      variantAttributes: const [],
      variantCombinations: const [],
      images: const [],
      optionalProductIds: const [],
      accessoryProductIds: const [],
      alternativeProductIds: const [],
      sku: 'E-COM08',
      barcode: '123456789',
    );

    blocTest<ProductBloc, ProductState>(
      'should emit [ProductLoading, ProductLoaded] when getProductById is successful',
      build: () {
        when(mockGetProductById(any)).thenAnswer((_) async => Right(product));
        return productBloc;
      },
      act: (bloc) => bloc.add(const GetProductByIdEvent(
        productId: productId,
        type: type,
        templateId: templateId,
      )),
      expect: () => [
        const ProductLoading(),
        ProductLoaded(product: product),
      ],
      verify: (_) {
        verify(mockGetProductById(any)).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'should emit [ProductLoading, ProductError] when getProductById fails',
      build: () {
        when(mockGetProductById(any)).thenAnswer((_) async => Left(ServerFailure('Network error')));
        return productBloc;
      },
      act: (bloc) => bloc.add(const GetProductByIdEvent(
        productId: productId,
        type: type,
        templateId: templateId,
      )),
      expect: () => [
        const ProductLoading(),
        const ProductError(message: 'Network error'),
      ],
      verify: (_) {
        verify(mockGetProductById(any)).called(1);
      },
    );
  });

  group('GetProductListEvent', () {
    const limit = 20;
    const offset = 0;

    final productListResponse = ProductListResponseModel(
      products: [
        ProductModel(
          id: 12,
          name: 'Storage Box',
          description: 'A storage box',
          shortDescription: 'Office storage',
          price: 15.8,
          currency: 'IQD',
          category: const ProductCategoryModel(
        id: 8, 
        name: 'Office Furniture',
        completeName: 'Office Furniture',
        sequence: 1,
      ),
          type: 'template',
          quantityAvailable: 18.0,
          inStock: true,
          totalVariants: 1,
          availableVariants: 1,
          variantAttributes: const [],
          variantCombinations: const [],
          images: const [],
          optionalProductIds: const [],
          accessoryProductIds: const [],
          alternativeProductIds: const [],
          sku: 'E-COM08',
          barcode: '123456789',
        ),
      ],
      totalCount: 1,
      limit: limit,
      offset: offset,
    );

    blocTest<ProductBloc, ProductState>(
      'should emit [ProductLoading, ProductListLoaded] when getProductList is successful',
      build: () {
        when(mockGetProductList(any)).thenAnswer((_) async => Right(productListResponse));
        return productBloc;
      },
      act: (bloc) => bloc.add(const GetProductListEvent(
        limit: limit,
        offset: offset,
      )),
      expect: () => [
        const ProductLoading(),
        ProductListLoaded(
          products: productListResponse.products,
          totalCount: productListResponse.totalCount,
          limit: productListResponse.limit,
          offset: productListResponse.offset,
          hasMore: productListResponse.hasMore,
        ),
      ],
      verify: (_) {
        verify(mockGetProductList(any)).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'should emit [ProductLoading, ProductEmpty] when getProductList returns empty list',
      build: () {
        final emptyResponse = ProductListResponseModel(
          products: [],
          totalCount: 0,
          limit: limit,
          offset: offset,
        );
        when(mockGetProductList(any)).thenAnswer((_) async => Right(emptyResponse));
        return productBloc;
      },
      act: (bloc) => bloc.add(const GetProductListEvent(
        limit: limit,
        offset: offset,
      )),
      expect: () => [
        const ProductLoading(),
        const ProductEmpty(message: 'No products found'),
      ],
      verify: (_) {
        verify(mockGetProductList(any)).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'should emit [ProductLoading, ProductError] when getProductList fails',
      build: () {
        when(mockGetProductList(any)).thenAnswer((_) async => Left(ServerFailure('Network error')));
        return productBloc;
      },
      act: (bloc) => bloc.add(const GetProductListEvent(
        limit: limit,
        offset: offset,
      )),
      expect: () => [
        const ProductLoading(),
        const ProductError(message: 'Network error'),
      ],
      verify: (_) {
        verify(mockGetProductList(any)).called(1);
      },
    );
  });

  group('LoadMoreProductsEvent', () {
    blocTest<ProductBloc, ProductState>(
      'should not load more products when state is not ProductListLoaded',
      build: () => productBloc,
      act: (bloc) => bloc.add(const LoadMoreProductsEvent()),
      expect: () => [],
    );

    blocTest<ProductBloc, ProductState>(
      'should not load more products when hasMore is false',
      build: () {
        final response = ProductListResponseModel(
          products: [
            ProductModel(
              id: 12,
              name: 'Storage Box',
              description: 'A storage box',
              shortDescription: 'Office storage',
              price: 15.8,
              currency: 'IQD',
              category: const ProductCategoryModel(
        id: 8, 
        name: 'Office Furniture',
        completeName: 'Office Furniture',
        sequence: 1,
      ),
              type: 'template',
              quantityAvailable: 18.0,
              inStock: true,
              totalVariants: 1,
              availableVariants: 1,
              variantAttributes: const [],
              variantCombinations: const [],
              images: const [],
              optionalProductIds: const [],
              accessoryProductIds: const [],
              alternativeProductIds: const [],
              sku: 'E-COM08',
              barcode: '123456789',
            ),
          ],
          totalCount: 1,
          limit: 20,
          offset: 0,
        );
        when(mockGetProductList(any)).thenAnswer((_) async => Right(response));
        return productBloc;
      },
      act: (bloc) {
        bloc.add(const GetProductListEvent());
        bloc.add(const LoadMoreProductsEvent());
      },
      expect: () => [
        const ProductLoading(),
        ProductListLoaded(
          products: [
            ProductModel(
              id: 12,
              name: 'Storage Box',
              description: 'A storage box',
              shortDescription: 'Office storage',
              price: 15.8,
              currency: 'IQD',
              category: const ProductCategoryModel(
        id: 8, 
        name: 'Office Furniture',
        completeName: 'Office Furniture',
        sequence: 1,
      ),
              type: 'template',
              quantityAvailable: 18.0,
              inStock: true,
              totalVariants: 1,
              availableVariants: 1,
              variantAttributes: const [],
              variantCombinations: const [],
              images: const [],
              optionalProductIds: const [],
              accessoryProductIds: const [],
              alternativeProductIds: const [],
              sku: 'E-COM08',
              barcode: '123456789',
            ),
          ],
          totalCount: 1,
          limit: 20,
          offset: 0,
          hasMore: false,
        ),
      ],
    );
  });

  group('SearchProductsEvent', () {
    const query = 'storage box';
    const limit = 20;
    const offset = 0;

    final searchResponse = ProductListResponseModel(
      products: [
        ProductModel(
          id: 12,
          name: 'Storage Box',
          description: 'A storage box',
          shortDescription: 'Office storage',
          price: 15.8,
          currency: 'IQD',
          category: const ProductCategoryModel(
        id: 8, 
        name: 'Office Furniture',
        completeName: 'Office Furniture',
        sequence: 1,
      ),
          type: 'template',
          quantityAvailable: 18.0,
          inStock: true,
          totalVariants: 1,
          availableVariants: 1,
          variantAttributes: const [],
          variantCombinations: const [],
          images: const [],
          optionalProductIds: const [],
          accessoryProductIds: const [],
          alternativeProductIds: const [],
          sku: 'E-COM08',
          barcode: '123456789',
        ),
      ],
      totalCount: 1,
      limit: limit,
      offset: offset,
    );

    blocTest<ProductBloc, ProductState>(
      'should emit [ProductLoading, ProductSearchLoaded] when searchProducts is successful',
      build: () {
        when(mockSearchProducts(any)).thenAnswer((_) async => Right(searchResponse));
        return productBloc;
      },
      act: (bloc) => bloc.add(const SearchProductsEvent(
        query: query,
        limit: limit,
        offset: offset,
      )),
      expect: () => [
        const ProductLoading(),
        ProductSearchLoaded(
          searchResults: searchResponse.products,
          query: query,
          totalCount: searchResponse.totalCount,
          limit: searchResponse.limit,
          offset: searchResponse.offset,
          hasMore: searchResponse.hasMore,
        ),
      ],
      verify: (_) {
        verify(mockSearchProducts(any)).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'should emit [ProductLoading, ProductEmpty] when searchProducts returns empty results',
      build: () {
        final emptyResponse = ProductListResponseModel(
          products: [],
          totalCount: 0,
          limit: limit,
          offset: offset,
        );
        when(mockSearchProducts(any)).thenAnswer((_) async => Right(emptyResponse));
        return productBloc;
      },
      act: (bloc) => bloc.add(const SearchProductsEvent(
        query: query,
        limit: limit,
        offset: offset,
      )),
      expect: () => [
        const ProductLoading(),
        const ProductEmpty(message: 'No products found for "$query"'),
      ],
      verify: (_) {
        verify(mockSearchProducts(any)).called(1);
      },
    );
  });

  group('ClearSearchEvent', () {
    blocTest<ProductBloc, ProductState>(
      'should emit ProductInitial when clearing search',
      build: () => productBloc,
      act: (bloc) => bloc.add(const ClearSearchEvent()),
      expect: () => [const ProductInitial()],
    );
  });

  group('RefreshProductListEvent', () {
    blocTest<ProductBloc, ProductState>(
      'should trigger GetProductListEvent when refreshing',
      build: () {
        final productListResponse = ProductListResponseModel(
          products: [],
          totalCount: 0,
          limit: 20,
          offset: 0,
        );
        when(mockGetProductList(any)).thenAnswer((_) async => Right(productListResponse));
        return productBloc;
      },
      act: (bloc) => bloc.add(const RefreshProductListEvent()),
      expect: () => [
        const ProductLoading(),
        const ProductEmpty(message: 'No products found'),
      ],
      verify: (_) {
        verify(mockGetProductList(any)).called(1);
      },
    );
  });
}


