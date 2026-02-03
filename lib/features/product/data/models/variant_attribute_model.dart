import '../../domain/entities/variant_attribute.dart';

class VariantAttributeModel extends VariantAttribute {
  const VariantAttributeModel({
    required super.attributeId,
    required super.attributeName,
    required super.valueId,
    required super.valueName,
  });

  factory VariantAttributeModel.fromJson(Map<String, dynamic> json) {
    return VariantAttributeModel(
      attributeId: json['attribute_id'] ?? 0,
      attributeName: json['attribute_name'] ?? '',
      valueId: json['value_id'] ?? 0,
      valueName: json['value_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attribute_id': attributeId,
      'attribute_name': attributeName,
      'value_id': valueId,
      'value_name': valueName,
    };
  }
}


