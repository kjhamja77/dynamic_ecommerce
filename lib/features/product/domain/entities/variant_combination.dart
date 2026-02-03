import 'package:equatable/equatable.dart';
import 'variant_attribute.dart';

class VariantCombination extends Equatable {
  final int variantId;
  final String name;
  final double price;
  final double quantityAvailable;
  final double quantityForecast;
  final bool inStock;
  final String sku;
  final String barcode;
  final List<VariantAttribute> attributes;

  const VariantCombination({
    required this.variantId,
    required this.name,
    required this.price,
    required this.quantityAvailable,
    required this.quantityForecast,
    required this.inStock,
    required this.sku,
    required this.barcode,
    required this.attributes,
  });

  @override
  List<Object> get props => [
        variantId,
        name,
        price,
        quantityAvailable,
        quantityForecast,
        inStock,
        sku,
        barcode,
        attributes,
      ];
}


