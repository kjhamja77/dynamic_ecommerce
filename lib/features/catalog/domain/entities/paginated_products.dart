import '../../../home/domain/entities/product.dart';

class PaginatedProducts {
  final List<Product> items;
  final int page;
  final int pageSize;
  final bool hasMore;
  final int totalCount; // Total number of results across all pages

  const PaginatedProducts({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasMore,
    required this.totalCount,
  });
}


