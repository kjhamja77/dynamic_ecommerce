import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

// Get single product by ID
class GetProductByIdEvent extends ProductEvent {
  final int productId;
  final String type; // 'template' or 'variant'
  final int? templateId; // Required for variant type

  const GetProductByIdEvent({
    required this.productId,
    required this.type,
    this.templateId,
  });

  @override
  List<Object?> get props => [productId, type, templateId];
}

// Get product list
class GetProductListEvent extends ProductEvent {
  final int limit;
  final int offset;

  const GetProductListEvent({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [limit, offset];
}

// Load more products (pagination)
class LoadMoreProductsEvent extends ProductEvent {
  const LoadMoreProductsEvent();
}

// Get products by category
class GetProductsByCategoryEvent extends ProductEvent {
  final List<int> categoryIds;
  final int limit;
  final int offset;

  const GetProductsByCategoryEvent({
    required this.categoryIds,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [categoryIds, limit, offset];
}

// Search products
class SearchProductsEvent extends ProductEvent {
  final String query;
  final int limit;
  final int offset;

  const SearchProductsEvent({
    required this.query,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [query, limit, offset];
}

// Clear search results
class ClearSearchEvent extends ProductEvent {
  const ClearSearchEvent();
}

// Refresh product list
class RefreshProductListEvent extends ProductEvent {
  const RefreshProductListEvent();
}

// Get root categories
class GetRootCategoriesEvent extends ProductEvent {
  final int maxDepth;

  const GetRootCategoriesEvent({
    this.maxDepth = 1,
  });

  @override
  List<Object> get props => [maxDepth];
}

// Get categories by parent ID
class GetCategoriesByParentIdEvent extends ProductEvent {
  final int parentId;
  final int maxDepth;

  const GetCategoriesByParentIdEvent({
    required this.parentId,
    this.maxDepth = 1,
  });

  @override
  List<Object> get props => [parentId, maxDepth];
}

// Get all categories
class GetAllCategoriesEvent extends ProductEvent {
  final int maxDepth;
  final int limit;
  final int offset;

  const GetAllCategoriesEvent({
    this.maxDepth = 1,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [maxDepth, limit, offset];
}


