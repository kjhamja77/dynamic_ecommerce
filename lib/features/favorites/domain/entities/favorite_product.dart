import 'package:equatable/equatable.dart';

class FavoriteProduct extends Equatable {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String? imageUrl;
  final String? category;
  final DateTime addedAt;
  final double? qtyAvailable; // Stock quantity from API
  final bool inStock; // Whether product is in stock

  const FavoriteProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.imageUrl,
    this.category,
    required this.addedAt,
    this.qtyAvailable,
    this.inStock = true, // Default to true for backward compatibility
  });

  @override
  List<Object?> get props => [id, name, brand, price, imageUrl, category, addedAt, qtyAvailable, inStock];

  FavoriteProduct copyWith({
    String? id,
    String? name,
    String? brand,
    double? price,
    String? imageUrl,
    String? category,
    DateTime? addedAt,
    double? qtyAvailable,
    bool? inStock,
  }) {
    return FavoriteProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      addedAt: addedAt ?? this.addedAt,
      qtyAvailable: qtyAvailable ?? this.qtyAvailable,
      inStock: inStock ?? this.inStock,
    );
  }
  
  /// Check if product is available (has stock)
  bool get isAvailable {
    if (qtyAvailable != null) {
      return (qtyAvailable ?? 0) > 0 && inStock;
    }
    return inStock;
  }
}
