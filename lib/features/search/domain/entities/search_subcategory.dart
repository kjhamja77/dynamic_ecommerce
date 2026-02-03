import 'package:equatable/equatable.dart';

class SearchSubcategory extends Equatable {
  final String id;
  final String title;
  final String categoryId;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;
  final List<SearchSubcategory> children;
  final bool hasChildren;
  final int productCount;

  const SearchSubcategory({
    required this.id,
    required this.title,
    required this.categoryId,
    this.imageUrl,
    required this.sortOrder,
    this.isActive = true,
    this.children = const [],
    this.hasChildren = false,
    this.productCount = 0,
  });

  SearchSubcategory copyWith({
    String? id,
    String? title,
    String? categoryId,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
    List<SearchSubcategory>? children,
    bool? hasChildren,
    int? productCount,
  }) {
    return SearchSubcategory(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      children: children ?? this.children,
      hasChildren: hasChildren ?? this.hasChildren,
      productCount: productCount ?? this.productCount,
    );
  }

  @override
  List<Object?> get props => [id, title, categoryId, imageUrl, sortOrder, isActive, children, hasChildren, productCount];
}
