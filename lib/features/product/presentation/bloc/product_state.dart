import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

// Initial state
class ProductInitial extends ProductState {
  const ProductInitial();
}

// Loading state
class ProductLoading extends ProductState {
  const ProductLoading();
}

// Single product loaded
class ProductLoaded extends ProductState {
  final Product product;

  const ProductLoaded({required this.product});

  @override
  List<Object> get props => [product];
}

// Product list loaded
class ProductListLoaded extends ProductState {
  final List<Product> products;
  final int totalCount;
  final int limit;
  final int offset;
  final bool hasMore;
  final bool isLoadingMore;

  const ProductListLoaded({
    required this.products,
    required this.totalCount,
    required this.limit,
    required this.offset,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  ProductListLoaded copyWith({
    List<Product>? products,
    int? totalCount,
    int? limit,
    int? offset,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProductListLoaded(
      products: products ?? this.products,
      totalCount: totalCount ?? this.totalCount,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [products, totalCount, limit, offset, hasMore, isLoadingMore];
}

// Search results loaded
class ProductSearchLoaded extends ProductState {
  final List<Product> searchResults;
  final String query;
  final int totalCount;
  final int limit;
  final int offset;
  final bool hasMore;
  final bool isLoadingMore;

  const ProductSearchLoaded({
    required this.searchResults,
    required this.query,
    required this.totalCount,
    required this.limit,
    required this.offset,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  ProductSearchLoaded copyWith({
    List<Product>? searchResults,
    String? query,
    int? totalCount,
    int? limit,
    int? offset,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProductSearchLoaded(
      searchResults: searchResults ?? this.searchResults,
      query: query ?? this.query,
      totalCount: totalCount ?? this.totalCount,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [searchResults, query, totalCount, limit, offset, hasMore, isLoadingMore];
}

// Category products loaded
class CategoryProductsLoaded extends ProductState {
  final List<Product> products;
  final List<int> categoryIds;
  final int totalCount;
  final int limit;
  final int offset;
  final bool hasMore;
  final bool isLoadingMore;

  const CategoryProductsLoaded({
    required this.products,
    required this.categoryIds,
    required this.totalCount,
    required this.limit,
    required this.offset,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  CategoryProductsLoaded copyWith({
    List<Product>? products,
    List<int>? categoryIds,
    int? totalCount,
    int? limit,
    int? offset,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return CategoryProductsLoaded(
      products: products ?? this.products,
      categoryIds: categoryIds ?? this.categoryIds,
      totalCount: totalCount ?? this.totalCount,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [products, categoryIds, totalCount, limit, offset, hasMore, isLoadingMore];
}

// Error state
class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object> get props => [message];
}

// Empty state (no products found)
class ProductEmpty extends ProductState {
  final String message;

  const ProductEmpty({required this.message});

  @override
  List<Object> get props => [message];
}

// Categories loaded
class CategoriesLoaded extends ProductState {
  final List<ProductCategory> categories;

  const CategoriesLoaded({required this.categories});

  @override
  List<Object> get props => [categories];
}

// Categories empty
class CategoriesEmpty extends ProductState {
  final String message;

  const CategoriesEmpty({required this.message});

  @override
  List<Object> get props => [message];
}


