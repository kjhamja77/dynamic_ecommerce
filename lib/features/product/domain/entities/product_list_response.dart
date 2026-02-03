import 'package:equatable/equatable.dart';
import 'product.dart';

class ProductListResponse extends Equatable {
  final List<Product> products;
  final int totalCount;
  final int limit;
  final int offset;

  const ProductListResponse({
    required this.products,
    required this.totalCount,
    required this.limit,
    required this.offset,
  });

  bool get hasMore => (offset + limit) < totalCount;
  int get currentPage => (offset ~/ limit) + 1;
  int get totalPages => (totalCount / limit).ceil();

  @override
  List<Object> get props => [products, totalCount, limit, offset];
}


