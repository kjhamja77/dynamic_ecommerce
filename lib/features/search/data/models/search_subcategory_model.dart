import '../../domain/entities/search_subcategory.dart';

class SearchSubcategoryModel extends SearchSubcategory {
  const SearchSubcategoryModel({
    required super.id,
    required super.title,
    required super.categoryId,
    super.imageUrl,
    required super.sortOrder,
    super.isActive,
    super.children,
    super.hasChildren,
    super.productCount,
  });

  factory SearchSubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SearchSubcategoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      categoryId: json['categoryId'] as String,
      imageUrl: json['imageUrl'] as String?,
      sortOrder: json['sortOrder'] as int,
      isActive: json['isActive'] as bool? ?? true,
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => SearchSubcategoryModel.fromJson(child as Map<String, dynamic>))
          .toList() ?? const [],
      hasChildren: json['hasChildren'] as bool? ?? false,
      productCount: json['productCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'children': children.map((child) => (child as SearchSubcategoryModel).toJson()).toList(),
      'hasChildren': hasChildren,
      'productCount': productCount,
    };
  }
}
