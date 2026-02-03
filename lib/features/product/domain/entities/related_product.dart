import 'package:equatable/equatable.dart';

class RelatedProduct extends Equatable {
  final int id;
  final String name;
  final double price;
  final String description;
  final String image;
  final List<int> productTagIds;

  const RelatedProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.productTagIds,
  });

  @override
  List<Object> get props => [id, name, price, description, image, productTagIds];
}


