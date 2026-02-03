import 'package:equatable/equatable.dart';

class FilterCategory extends Equatable {
  final int id;
  final String name;
  final int? parentId;
  final String completeName;
  final int sequence;
  final String? image;
  final int productCount;
  final bool hasChildren;
  final List<FilterCategory> children;

  const FilterCategory({
    required this.id,
    required this.name,
    this.parentId,
    required this.completeName,
    required this.sequence,
    this.image,
    this.productCount = 0,
    this.hasChildren = false,
    this.children = const [],
  });

  factory FilterCategory.fromJson(Map<String, dynamic> json) {
    return FilterCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      parentId: json['parent_id'],
      completeName: json['complete_name'] ?? '',
      sequence: json['sequence'] ?? 0,
      image: json['image'],
      productCount: json['product_count'] ?? 0,
      hasChildren: json['hasChildren'] ?? false,
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => FilterCategory.fromJson(child as Map<String, dynamic>))
          .toList() ?? [],
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
      'product_count': productCount,
      'hasChildren': hasChildren,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        parentId,
        completeName,
        sequence,
        image,
        productCount,
        hasChildren,
        children,
      ];
}
