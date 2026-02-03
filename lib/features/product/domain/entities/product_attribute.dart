import 'package:equatable/equatable.dart';
import 'product_attribute_value.dart';

class ProductAttribute extends Equatable {
  final int id;
  final String name;
  final List<ProductAttributeValue> values;

  const ProductAttribute({
    required this.id,
    required this.name,
    required this.values,
  });

  @override
  List<Object> get props => [id, name, values];
}


