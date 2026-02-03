import 'package:equatable/equatable.dart';

class ProductAttributeValue extends Equatable {
  final int id;
  final String name;

  const ProductAttributeValue({
    required this.id,
    required this.name,
  });

  @override
  List<Object> get props => [id, name];
}


