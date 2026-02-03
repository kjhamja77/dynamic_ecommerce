import '../../domain/entities/product_list_response.dart';
import 'product_model.dart';

class ProductListResponseModel extends ProductListResponse {
  const ProductListResponseModel({
    required super.products,
    required super.totalCount,
    required super.limit,
    required super.offset,
  });

  factory ProductListResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductListResponseModel(
      products: (json['products'] as List<dynamic>?)
          ?.map((product) => ProductModel.fromJson(product))
          .toList() ?? [],
      totalCount: json['total_count'] ?? 0,
      limit: json['limit'] ?? 0,
      offset: json['offset'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((product) => (product as ProductModel).toJson()).toList(),
      'total_count': totalCount,
      'limit': limit,
      'offset': offset,
    };
  }
}


