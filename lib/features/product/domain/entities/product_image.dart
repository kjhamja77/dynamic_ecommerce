import 'package:equatable/equatable.dart';

class ProductImage extends Equatable {
  final String type; // 'template' or 'variant'
  final int? variantId; // Only for variant images
  final String url;
  final String alt;

  const ProductImage({
    required this.type,
    this.variantId,
    required this.url,
    required this.alt,
  });

  @override
  List<Object?> get props => [type, variantId, url, alt];
}


