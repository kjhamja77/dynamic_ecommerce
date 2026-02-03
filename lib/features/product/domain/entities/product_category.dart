import 'package:equatable/equatable.dart';

class ProductCategory extends Equatable {
  final int id;
  final String name;
  final int? parentId;
  final String completeName;
  final int sequence;
  final String? image;
  final List<ProductCategory> children;
  final int productCount;
  final bool hasChildren;

  const ProductCategory({
    required this.id,
    required this.name,
    this.parentId,
    required this.completeName,
    required this.sequence,
    this.image,
    this.children = const [],
    this.productCount = 0,
    this.hasChildren = false,
  });

  @override
  List<Object?> get props => [id, name, parentId, completeName, sequence, image, children, productCount, hasChildren];
}


