import 'package:equatable/equatable.dart';
import 'search_product_model.dart';

class SearchResults extends Equatable {
  final List<SearchProductModel> products;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const SearchResults({
    required this.products,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    print('SearchResults.fromJson - Input JSON keys: ${json.keys.toList()}');
    
    final List<dynamic> productsJson = json['products'] ?? [];
    print('SearchResults.fromJson - Products JSON length: ${productsJson.length}');
    
    final products = <SearchProductModel>[];
    for (int i = 0; i < productsJson.length; i++) {
      try {
        final product = SearchProductModel.fromJson(productsJson[i]);
        products.add(product);
        print('SearchResults.fromJson - Successfully parsed product $i: ${product.name}');
      } catch (e) {
        print('SearchResults.fromJson - Error parsing product $i: $e');
        print('SearchResults.fromJson - Product JSON: ${productsJson[i]}');
      }
    }

    final totalCount = json['total_count'] ?? 0;
    final currentPage = json['current_page'] ?? 1;
    final totalPages = json['total_pages'] ?? 1;

    print('SearchResults.fromJson - Final result: ${products.length} products, total: $totalCount');

    return SearchResults(
      products: products,
      totalCount: totalCount,
      currentPage: currentPage,
      totalPages: totalPages,
      hasNextPage: json['has_next'] ?? json['has_next_page'] ?? false,
      hasPreviousPage: json['has_previous'] ?? json['has_previous_page'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((product) => product.toJson()).toList(),
      'total_count': totalCount,
      'current_page': currentPage,
      'total_pages': totalPages,
      'has_next_page': hasNextPage,
      'has_previous_page': hasPreviousPage,
    };
  }

  SearchResults copyWith({
    List<SearchProductModel>? products,
    int? totalCount,
    int? currentPage,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return SearchResults(
      products: products ?? this.products,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }

  @override
  List<Object?> get props => [
        products,
        totalCount,
        currentPage,
        totalPages,
        hasNextPage,
        hasPreviousPage,
      ];
}
