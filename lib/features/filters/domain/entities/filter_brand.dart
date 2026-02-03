import 'package:equatable/equatable.dart';

class FilterBrand extends Equatable {
  final int id;
  final String name;
  final String? image;
  final int productCount;
  final bool isActive;

  const FilterBrand({
    required this.id,
    required this.name,
    this.image,
    this.productCount = 0,
    this.isActive = true,
  });

  factory FilterBrand.fromJson(Map<String, dynamic> json) {
    return FilterBrand(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
      productCount: json['product_count'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'product_count': productCount,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [id, name, image, productCount, isActive];
}
