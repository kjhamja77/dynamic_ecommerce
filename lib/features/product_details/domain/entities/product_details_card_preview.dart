import 'package:equatable/equatable.dart';

/// Lightweight data from a product card (list/catalog) passed to product details
/// so the details page can show it immediately while loading full data from the API.
class ProductDetailsCardPreview extends Equatable {
  final String? imageUrl;
  final String brand;
  final String productTitle;
  final double price;

  const ProductDetailsCardPreview({
    this.imageUrl,
    required this.brand,
    required this.productTitle,
    required this.price,
  });

  /// From route arguments map (e.g. Navigator.pushNamed arguments['cardPreview']).
  static ProductDetailsCardPreview? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final brand = map['brand'] as String?;
    final productTitle = map['productTitle'] as String?;
    final price = map['price'];
    if (brand == null || productTitle == null || price == null) return null;
    final priceValue = price is int ? price.toDouble() : (price as num).toDouble();
    return ProductDetailsCardPreview(
      imageUrl: map['imageUrl'] as String?,
      brand: brand,
      productTitle: productTitle,
      price: priceValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'brand': brand,
      'productTitle': productTitle,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [imageUrl, brand, productTitle, price];
}
