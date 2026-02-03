import '../../domain/entities/product_attribute_value.dart';

class ProductAttributeValueModel extends ProductAttributeValue {
  const ProductAttributeValueModel({
    required super.id,
    required super.name,
  });

  factory ProductAttributeValueModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeValueModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}


