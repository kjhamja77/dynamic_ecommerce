import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/usecases/get_product_by_id.dart';
import '../../domain/usecases/get_product_list.dart';
import '../../domain/usecases/get_products_by_category.dart';
import '../../domain/usecases/search_products.dart';
import '../../domain/usecases/get_root_categories.dart';
import '../../domain/usecases/get_categories_by_parent_id.dart';
import '../../domain/usecases/get_all_categories.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductById getProductById;
  final GetProductList getProductList;
  final GetProductsByCategory getProductsByCategory;
  final SearchProducts searchProducts;
  final GetRootCategoriesUseCase getRootCategories;
  final GetCategoriesByParentIdUseCase getCategoriesByParentId;
  final GetAllCategoriesUseCase getAllCategories;

  ProductBloc({
    required this.getProductById,
    required this.getProductList,
    required this.getProductsByCategory,
    required this.searchProducts,
    required this.getRootCategories,
    required this.getCategoriesByParentId,
    required this.getAllCategories,
  }) : super(const ProductInitial()) {
    on<GetProductByIdEvent>(_onGetProductById);
    on<GetProductListEvent>(_onGetProductList);
    on<LoadMoreProductsEvent>(_onLoadMoreProducts);
    on<GetProductsByCategoryEvent>(_onGetProductsByCategory);
    on<SearchProductsEvent>(_onSearchProducts);
    on<ClearSearchEvent>(_onClearSearch);
    on<RefreshProductListEvent>(_onRefreshProductList);
    on<GetRootCategoriesEvent>(_onGetRootCategories);
    on<GetCategoriesByParentIdEvent>(_onGetCategoriesByParentId);
    on<GetAllCategoriesEvent>(_onGetAllCategories);
  }

  Future<void> _onGetProductById(
    GetProductByIdEvent event,
    Emitter<ProductState> emit,
  ) async {
    debugPrint('🔍 ProductBloc: Getting product by ID ${event.productId} (${event.type})');
    emit(const ProductLoading());

    final result = await getProductById(GetProductByIdParams(
      productId: event.productId,
      type: event.type,
      templateId: event.templateId,
    ));

    result.fold(
      (failure) {
        debugPrint('❌ ProductBloc: Failed to get product - ${failure.message}');
        emit(ProductError(message: failure.message));
      },
      (product) {
        debugPrint('✅ ProductBloc: Product loaded - ${product.name}');
        emit(ProductLoaded(product: product));
      },
    );
  }

  Future<void> _onGetProductList(
    GetProductListEvent event,
    Emitter<ProductState> emit,
  ) async {
    debugPrint('📋 ProductBloc: Getting product list (limit: ${event.limit}, offset: ${event.offset})');
    emit(const ProductLoading());

    final result = await getProductList(GetProductListParams(
      limit: event.limit,
      offset: event.offset,
    ));

    result.fold(
      (failure) {
        debugPrint('❌ ProductBloc: Failed to get product list - ${failure.message}');
        emit(ProductError(message: failure.message));
      },
      (response) {
        debugPrint('✅ ProductBloc: Product list loaded - ${response.products.length} products');
        if (response.products.isEmpty) {
          emit(const ProductEmpty(message: 'No products found'));
        } else {
          emit(ProductListLoaded(
            products: response.products,
            totalCount: response.totalCount,
            limit: response.limit,
            offset: response.offset,
            hasMore: response.hasMore,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductListLoaded || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    debugPrint('📋 ProductBloc: Loading more products...');
    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getProductList(GetProductListParams(
      limit: currentState.limit,
      offset: currentState.offset + currentState.limit,
    ));

    result.fold(
      (failure) {
        debugPrint('❌ ProductBloc: Failed to load more products - ${failure.message}');
        emit(currentState.copyWith(isLoadingMore: false));
        emit(ProductError(message: failure.message));
      },
      (response) {
        debugPrint('✅ ProductBloc: More products loaded - ${response.products.length} new products');
        final updatedProducts = [...currentState.products, ...response.products];
        emit(ProductListLoaded(
          products: updatedProducts,
          totalCount: response.totalCount,
          limit: response.limit,
          offset: response.offset,
          hasMore: response.hasMore,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onGetProductsByCategory(
    GetProductsByCategoryEvent event,
    Emitter<ProductState> emit,
  ) async {
    debugPrint('🏷️ ProductBloc: Getting products by category ${event.categoryIds}');
    emit(const ProductLoading());

    final result = await getProductsByCategory(GetProductsByCategoryParams(
      categoryIds: event.categoryIds,
      limit: event.limit,
      offset: event.offset,
    ));

    result.fold(
      (failure) {
        debugPrint('❌ ProductBloc: Failed to get products by category - ${failure.message}');
        emit(ProductError(message: failure.message));
      },
      (response) {
        debugPrint('✅ ProductBloc: Category products loaded - ${response.products.length} products');
        if (response.products.isEmpty) {
          emit(const ProductEmpty(message: 'No products found in this category'));
        } else {
          emit(CategoryProductsLoaded(
            products: response.products,
            categoryIds: event.categoryIds,
            totalCount: response.totalCount,
            limit: response.limit,
            offset: response.offset,
            hasMore: response.hasMore,
          ));
        }
      },
    );
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    debugPrint('🔍 ProductBloc: Searching products for "${event.query}"');
    emit(const ProductLoading());

    final result = await searchProducts(SearchProductsParams(
      query: event.query,
      limit: event.limit,
      offset: event.offset,
    ));

    result.fold(
      (failure) {
        debugPrint('❌ ProductBloc: Failed to search products - ${failure.message}');
        emit(ProductError(message: failure.message));
      },
      (response) {
        debugPrint('✅ ProductBloc: Search results loaded - ${response.products.length} products');
        if (response.products.isEmpty) {
          emit(ProductEmpty(message: 'No products found for "${event.query}"'));
        } else {
          emit(ProductSearchLoaded(
            searchResults: response.products,
            query: event.query,
            totalCount: response.totalCount,
            limit: response.limit,
            offset: response.offset,
            hasMore: response.hasMore,
          ));
        }
      },
    );
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<ProductState> emit,
  ) async {
    debugPrint('🧹 ProductBloc: Clearing search results');
    emit(const ProductInitial());
  }

  Future<void> _onRefreshProductList(
    RefreshProductListEvent event,
    Emitter<ProductState> emit,
  ) async {
    debugPrint('🔄 ProductBloc: Refreshing product list');
    add(const GetProductListEvent());
  }

  Future<void> _onGetRootCategories(
    GetRootCategoriesEvent event,
    Emitter<ProductState> emit,
  ) async {
    debugPrint('📂 ProductBloc: Getting root categories');
    emit(const ProductLoading());

    final result = await getRootCategories(GetRootCategoriesParams(
      maxDepth: event.maxDepth,
    ));

    result.fold(
      (failure) {
        debugPrint('❌ ProductBloc: Failed to get root categories - ${failure.message}');
        emit(ProductError(message: failure.message));
      },
      (categories) {
        debugPrint('✅ ProductBloc: Root categories loaded - ${categories.length} categories');
        if (categories.isEmpty) {
          emit(const CategoriesEmpty(message: 'No categories found'));
        } else {
          emit(CategoriesLoaded(categories: categories));
        }
      },
    );
  }

  Future<void> _onGetCategoriesByParentId(
    GetCategoriesByParentIdEvent event,
    Emitter<ProductState> emit,
  ) async {
    debugPrint('📂 ProductBloc: Getting categories by parent ID ${event.parentId}');
    emit(const ProductLoading());

    final result = await getCategoriesByParentId(GetCategoriesByParentIdParams(
      parentId: event.parentId,
      maxDepth: event.maxDepth,
    ));

    result.fold(
      (failure) {
        debugPrint('❌ ProductBloc: Failed to get categories by parent ID - ${failure.message}');
        emit(ProductError(message: failure.message));
      },
      (categories) {
        debugPrint('✅ ProductBloc: Categories by parent ID loaded - ${categories.length} categories');
        if (categories.isEmpty) {
          emit(const CategoriesEmpty(message: 'No subcategories found'));
        } else {
          emit(CategoriesLoaded(categories: categories));
        }
      },
    );
  }

  Future<void> _onGetAllCategories(
    GetAllCategoriesEvent event,
    Emitter<ProductState> emit,
  ) async {
    debugPrint('📂 ProductBloc: Getting all categories');
    emit(const ProductLoading());

    final result = await getAllCategories(GetAllCategoriesParams(
      maxDepth: event.maxDepth,
      limit: event.limit,
      offset: event.offset,
    ));

    result.fold(
      (failure) {
        debugPrint('❌ ProductBloc: Failed to get all categories - ${failure.message}');
        emit(ProductError(message: failure.message));
      },
      (categories) {
        debugPrint('✅ ProductBloc: All categories loaded - ${categories.length} categories');
        if (categories.isEmpty) {
          emit(const CategoriesEmpty(message: 'No categories found'));
        } else {
          emit(CategoriesLoaded(categories: categories));
        }
      },
    );
  }
}


