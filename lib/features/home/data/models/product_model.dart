import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.originalPrice,
    required super.images,
    required super.category,
    required super.brand,
    required super.type,
    required super.rating,
    required super.reviewCount,
    required super.isAvailable,
    required super.sizes,
    required super.colors,
    required super.createdAt,
    super.materials,
    super.heelHeightCm,
    super.heelType,
    super.dimensions,
    super.closureType,
    super.strapType,
    super.capacity,
    super.soleType,
    super.upperMaterial,
    super.liningMaterial,
    super.careInstructions,
    super.features,
    super.favourite,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['original_price'] != null 
          ? (json['original_price'] as num).toDouble() 
          : null,
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      type: json['type'] ?? 'variant',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isAvailable: json['is_available'] ?? true,
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      materials: json['materials'] != null ? List<String>.from(json['materials']) : null,
      heelHeightCm: json['heel_height_cm'] != null ? (json['heel_height_cm'] as num).toDouble() : null,
      heelType: json['heel_type'],
      dimensions: json['dimensions'] != null ? Map<String, String>.from(json['dimensions']) : null,
      closureType: json['closure_type'],
      strapType: json['strap_type'],
      capacity: json['capacity'],
      soleType: json['sole_type'],
      upperMaterial: json['upper_material'],
      liningMaterial: json['lining_material'],
      careInstructions: json['care_instructions'],
      features: json['features'] != null ? List<String>.from(json['features']) : null,
      favourite: json['favourite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'images': images,
      'category': category,
      'brand': brand,
      'type': type,
      'rating': rating,
      'review_count': reviewCount,
      'is_available': isAvailable,
      'sizes': sizes,
      'colors': colors,
      'created_at': createdAt.toIso8601String(),
      'materials': materials,
      'heel_height_cm': heelHeightCm,
      'heel_type': heelType,
      'dimensions': dimensions,
      'closure_type': closureType,
      'strap_type': strapType,
      'capacity': capacity,
      'sole_type': soleType,
      'upper_material': upperMaterial,
      'lining_material': liningMaterial,
      'care_instructions': careInstructions,
      'features': features,
      'favourite': favourite,
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      originalPrice: product.originalPrice,
      images: product.images,
      category: product.category,
      brand: product.brand,
      type: product.type,
      rating: product.rating,
      reviewCount: product.reviewCount,
      isAvailable: product.isAvailable,
      sizes: product.sizes,
      colors: product.colors,
      createdAt: product.createdAt,
      materials: product.materials,
      heelHeightCm: product.heelHeightCm,
      heelType: product.heelType,
      dimensions: product.dimensions,
      closureType: product.closureType,
      strapType: product.strapType,
      capacity: product.capacity,
      soleType: product.soleType,
      upperMaterial: product.upperMaterial,
      liningMaterial: product.liningMaterial,
      careInstructions: product.careInstructions,
      features: product.features,
      favourite: product.favourite,
    );
  }

  // Maps backend API product shape to our model
  factory ProductModel.fromApiJson(Map<String, dynamic> json) {
    // Extract and filter images based on product type and variant_id
    final images = <String>[];
    final productType = (json['type'] ?? 'variant').toString();
    final productId = (json['id'] ?? json['product_id'] ?? '').toString();
    
    if (json['images'] != null && json['images'] is List) {
      final imagesList = json['images'] as List<dynamic>;
      
      for (final img in imagesList) {
        if (img is Map<String, dynamic>) {
          final imageUrl = img['image']?.toString() ?? '';
          if (imageUrl.isNotEmpty) {
            // For variants: only show images that match the variant_id
            // For templates: show all template images
            if (productType == 'variant') {
              // For variants, only show images that belong to this specific variant
              // Since each variant has its own images array, we show all images in the array
              images.add(imageUrl);
            } else if (productType == 'template') {
              // For templates, show all template images
              images.add(imageUrl);
            }
          }
        }
      }
    }
    
    return ProductModel(
      id: productId,
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] ?? json['unit_price'] ?? 0.0).toDouble(),
      originalPrice: json['original_price'] != null 
          ? (json['original_price'] as num).toDouble() 
          : null,
      images: images,
      category: (json['category'] ?? json['category_name'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      type: productType,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isAvailable: json['is_available'] ?? json['in_stock'] ?? true,
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : [],
      colors: json['colors'] != null ? List<String>.from(json['colors']) : [],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      materials: json['materials'] != null ? List<String>.from(json['materials']) : null,
      heelHeightCm: json['heel_height_cm'] != null ? (json['heel_height_cm'] as num).toDouble() : null,
      heelType: json['heel_type'],
      dimensions: json['dimensions'] != null ? Map<String, String>.from(json['dimensions']) : null,
      closureType: json['closure_type'],
      strapType: json['strap_type'],
      capacity: json['capacity'],
      soleType: json['sole_type'],
      upperMaterial: json['upper_material'],
      liningMaterial: json['lining_material'],
      careInstructions: json['care_instructions'],
      features: json['features'] != null ? List<String>.from(json['features']) : null,
      favourite: json['favourite'] ?? false,
    );
  }
}
