import '../../domain/entities/favorite_product.dart';
import '../../../../../core/constants/app_constants.dart';

class FavoriteProductModel extends FavoriteProduct {
  const FavoriteProductModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.price,
    super.imageUrl,
    super.category,
    required super.addedAt,
    super.qtyAvailable,
    super.inStock,
  });

  factory FavoriteProductModel.fromJson(Map<String, dynamic> json) {
    final qtyAvailable = json['qtyAvailable'];
    final qtyAvailableDouble = qtyAvailable is num 
        ? qtyAvailable.toDouble() 
        : (qtyAvailable is String 
            ? double.tryParse(qtyAvailable) 
            : null);
    
    final inStock = (json['inStock'] ?? true) as bool;
    final finalInStock = qtyAvailableDouble != null 
        ? (qtyAvailableDouble > 0 && inStock)
        : inStock;
    
    return FavoriteProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
      qtyAvailable: qtyAvailableDouble,
      inStock: finalInStock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'addedAt': addedAt.toIso8601String(),
      'qtyAvailable': qtyAvailable,
      'inStock': inStock,
    };
  }

  factory FavoriteProductModel.fromEntity(FavoriteProduct entity) {
    return FavoriteProductModel(
      id: entity.id,
      name: entity.name,
      brand: entity.brand,
      price: entity.price,
      imageUrl: entity.imageUrl,
      category: entity.category,
      addedAt: entity.addedAt,
      qtyAvailable: entity.qtyAvailable,
      inStock: entity.inStock,
    );
  }

  factory FavoriteProductModel.fromWishlistJson(Map<String, dynamic> json) {
    // Parse wishlist API response format
    final product = json['product'] as Map<String, dynamic>? ?? <String, dynamic>{};
    
    // Get image URL and construct full URL
    final String? imagePath = product['image'] as String?;
    String? fullImageUrl;
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        fullImageUrl = imagePath;
      } else {
        fullImageUrl = '${AppConstants.baseUrl}${imagePath.startsWith('/') ? imagePath.substring(1) : imagePath}';
      }
    }
    
    // Extract brand name from API response
    String brandName = 'Brand'; // Default fallback
    final brandData = product['brand'] as Map<String, dynamic>?;
    if (brandData != null && brandData['name'] != null) {
      brandName = brandData['name'] as String;
    }
    
    // Extract stock information
    final qtyAvailable = product['qty_available'];
    final qtyAvailableDouble = qtyAvailable is num 
        ? qtyAvailable.toDouble() 
        : (qtyAvailable is String 
            ? double.tryParse(qtyAvailable) 
            : null);
    
    final inStock = (product['in_stock'] ?? true) as bool;
    // If qty_available is provided, use it to determine stock status
    final finalInStock = qtyAvailableDouble != null 
        ? (qtyAvailableDouble > 0 && inStock)
        : inStock;
    
    return FavoriteProductModel(
      id: (product['id'] ?? 0).toString(),
      name: product['name'] as String? ?? 'Unknown Product',
      brand: brandName, // Extract brand from API response
      price: (product['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: fullImageUrl,
      category: 'Featured', // Default category
      addedAt: DateTime.now(), // Wishlist doesn't provide added date
      qtyAvailable: qtyAvailableDouble,
      inStock: finalInStock,
    );
  }
}
