import '../../domain/entities/variant_combination.dart';
import 'variant_attribute_model.dart';

class VariantCombinationModel extends VariantCombination {
  const VariantCombinationModel({
    required super.variantId,
    required super.name,
    required super.price,
    required super.quantityAvailable,
    required super.quantityForecast,
    required super.inStock,
    required super.sku,
    required super.barcode,
    required super.attributes,
  });

  factory VariantCombinationModel.fromJson(Map<String, dynamic> json) {
    return VariantCombinationModel(
      variantId: json['variant_id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantityAvailable: (json['quantity_available'] ?? 0.0).toDouble(),
      quantityForecast: (json['quantity_forecast'] ?? 0.0).toDouble(),
      inStock: json['in_stock'] ?? false,
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((attr) => VariantAttributeModel.fromJson(attr))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variant_id': variantId,
      'name': name,
      'price': price,
      'quantity_available': quantityAvailable,
      'quantity_forecast': quantityForecast,
      'in_stock': inStock,
      'sku': sku,
      'barcode': barcode,
      'attributes': attributes.map((attr) => (attr as VariantAttributeModel).toJson()).toList(),
    };
  }
}


