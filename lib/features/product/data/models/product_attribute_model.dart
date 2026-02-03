import '../../domain/entities/product_attribute.dart';
import 'product_attribute_value_model.dart';

class ProductAttributeModel extends ProductAttribute {
  const ProductAttributeModel({
    required super.id,
    required super.name,
    required super.values,
  });

  factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      values: (json['values'] as List<dynamic>?)
          ?.map((value) => ProductAttributeValueModel.fromJson(value))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'values': values.map((value) => (value as ProductAttributeValueModel).toJson()).toList(),
    };
  }
}


