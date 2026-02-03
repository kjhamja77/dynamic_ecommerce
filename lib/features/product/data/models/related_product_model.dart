import '../../domain/entities/related_product.dart';

class RelatedProductModel extends RelatedProduct {
  const RelatedProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
    required super.image,
    required super.productTagIds,
  });

  factory RelatedProductModel.fromJson(Map<String, dynamic> json) {
    return RelatedProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      productTagIds: (json['product_tag_ids'] as List<dynamic>?)
          ?.map((id) => id as int)
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image': image,
      'product_tag_ids': productTagIds,
    };
  }
}


