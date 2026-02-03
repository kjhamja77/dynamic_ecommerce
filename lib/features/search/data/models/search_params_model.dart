import 'package:equatable/equatable.dart';

class SearchParams extends Equatable {
  final int page;
  final int limit;
  final String? searchTerm;
  final List<int>? categoryIds;
  final double? minPrice;
  final double? maxPrice;
  final List<int>? brandIds;
  final List<int>? attributeValues;
  final String? stockFilter;
  final String? sortBy;
  final String? sortOrder;

  const SearchParams({
    this.page = 1,
    this.limit = 20,
    this.searchTerm,
    this.categoryIds,
    this.minPrice,
    this.maxPrice,
    this.brandIds,
    this.attributeValues,
    this.stockFilter,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };

    // Only include non-null values
    if (searchTerm != null && searchTerm!.isNotEmpty) {
      params['search_term'] = searchTerm;
    }
    if (categoryIds != null && categoryIds!.isNotEmpty) {
      params['category_ids'] = categoryIds;
    }
    if (minPrice != null) {
      params['min_price'] = minPrice;
    }
    if (maxPrice != null) {
      params['max_price'] = maxPrice;
    }
    if (brandIds != null && brandIds!.isNotEmpty) {
      params['brand_ids'] = brandIds;
    }
    if (attributeValues != null && attributeValues!.isNotEmpty) {
      params['attribute_values'] = attributeValues;
    }
    if (stockFilter != null && stockFilter!.isNotEmpty) {
      params['stock_filter'] = stockFilter;
    }
    if (sortBy != null && sortBy!.isNotEmpty) {
      params['sort_by'] = sortBy;
    }
    if (sortOrder != null && sortOrder!.isNotEmpty) {
      params['sort_order'] = sortOrder;
    }

    return params;
  }

  SearchParams copyWith({
    int? page,
    int? limit,
    String? searchTerm,
    List<int>? categoryIds,
    double? minPrice,
    double? maxPrice,
    List<int>? brandIds,
    List<int>? attributeValues,
    String? stockFilter,
    String? sortBy,
    String? sortOrder,
  }) {
    return SearchParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      searchTerm: searchTerm ?? this.searchTerm,
      categoryIds: categoryIds ?? this.categoryIds,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      brandIds: brandIds ?? this.brandIds,
      attributeValues: attributeValues ?? this.attributeValues,
      stockFilter: stockFilter ?? this.stockFilter,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        page,
        limit,
        searchTerm,
        categoryIds,
        minPrice,
        maxPrice,
        brandIds,
        attributeValues,
        stockFilter,
        sortBy,
        sortOrder,
      ];
}
