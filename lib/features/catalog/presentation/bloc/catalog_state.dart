import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/product.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();
  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  final List<Product> products;
  final List<String> categories;
  final List<String> brands;
  final String selectedCategory;
  final String? selectedCategoryId;
  final List<int>? categoryIds; // Store category IDs from filter page for pagination
  final String selectedBrand;
  final String sortBy;
  final String? query;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isFiltering;
  final int totalCount; // Total number of results across all pages
  final double? minPrice;
  final double? maxPrice;
  // Bounds from filter-options API
  final double? priceMinBound;
  final double? priceMaxBound;
  final double? minRating;
  final bool onSale;
  final bool inStock;
  final List<String> sizes;
  final List<String> colors;
  final List<String> selectedColors;
  final List<String> materials;
  final List<String> seasons;
  final List<String> genders;
  final Map<String, List<String>> extraAttributes;

  const CatalogLoaded({
    required this.products,
    required this.categories,
    required this.brands,
    this.selectedCategory = 'All',
    this.selectedCategoryId,
    this.categoryIds,
    this.selectedBrand = 'All',
    this.sortBy = 'newest_first', // Default sort option ID from API
    this.query,
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isFiltering = false,
    this.totalCount = 0,
    this.minPrice,
    this.maxPrice,
    this.priceMinBound,
    this.priceMaxBound,
    this.minRating,
    this.onSale = false,
    this.inStock = false,
    this.sizes = const [],
    this.colors = const [],
    this.selectedColors = const [],
    this.materials = const [],
    this.seasons = const [],
    this.genders = const [],
    this.extraAttributes = const {},
  });

  CatalogLoaded copyWith({
    List<Product>? products,
    List<String>? categories,
    List<String>? brands,
    String? selectedCategory,
    String? selectedCategoryId,
    List<int>? categoryIds,
    String? selectedBrand,
    String? sortBy,
    String? query,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isFiltering,
    int? totalCount,
    double? minPrice,
    double? maxPrice,
    double? priceMinBound,
    double? priceMaxBound,
    double? minRating,
    bool? onSale,
    bool? inStock,
    List<String>? sizes,
    List<String>? colors,
    List<String>? selectedColors,
    List<String>? materials,
    List<String>? seasons,
    List<String>? genders,
    Map<String, List<String>>? extraAttributes,
  }) {
    return CatalogLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      categoryIds: categoryIds ?? this.categoryIds,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      sortBy: sortBy ?? this.sortBy,
      query: query ?? this.query,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFiltering: isFiltering ?? this.isFiltering,
      totalCount: totalCount ?? this.totalCount,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      priceMinBound: priceMinBound ?? this.priceMinBound,
      priceMaxBound: priceMaxBound ?? this.priceMaxBound,
      minRating: minRating ?? this.minRating,
      onSale: onSale ?? this.onSale,
      inStock: inStock ?? this.inStock,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      selectedColors: selectedColors ?? this.selectedColors,
      materials: materials ?? this.materials,
      seasons: seasons ?? this.seasons,
      genders: genders ?? this.genders,
      extraAttributes: extraAttributes ?? this.extraAttributes,
    );
  }

  @override
  List<Object?> get props => [
    products,
    categories,
    brands,
    selectedCategory,
    selectedCategoryId,
    categoryIds,
    selectedBrand,
    sortBy,
    query,
    page,
    hasMore,
    isLoadingMore,
    isFiltering,
    totalCount,
    minPrice,
    maxPrice,
    priceMinBound,
    priceMaxBound,
    minRating,
    onSale,
    inStock,
    sizes,
    colors,
    selectedColors,
    materials,
    seasons,
    genders,
    extraAttributes,
  ];
}

class CatalogError extends CatalogState {
  final String message;
  const CatalogError(this.message);
  @override
  List<Object?> get props => [message];
}


