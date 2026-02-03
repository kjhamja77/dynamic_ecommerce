import '../../domain/entities/product_category.dart';

class ProductCategoryModel extends ProductCategory {
  const ProductCategoryModel({
    required super.id,
    required super.name,
    super.parentId,
    required super.completeName,
    required super.sequence,
    super.image,
    super.children,
    super.productCount,
    super.hasChildren,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      parentId: json['parent_id'],
      completeName: json['complete_name'] ?? '',
      sequence: json['sequence'] ?? 0,
      image: json['image'],
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => ProductCategoryModel.fromJson(child as Map<String, dynamic>))
          .toList() ?? [],
      productCount: json['product_count'] ?? 0,
      hasChildren: json['hasChildren'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'complete_name': completeName,
      'sequence': sequence,
      'image': image,
      'children': children.map((child) => (child as ProductCategoryModel).toJson()).toList(),
      'product_count': productCount,
      'hasChildren': hasChildren,
    };
  }
}


