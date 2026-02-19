import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final String category;
  final String brand;
  final String type; // 'template' or 'variant'
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final List<String> sizes;
  final List<String> colors;
  final Map<String, List<String>>? colorImages; // Maps color name to list of image URLs
  final DateTime createdAt;
  // Additional attributes for enhanced product details
  final List<String>? materials;
  final double? heelHeightCm;
  final String? heelType;
  final Map<String, String>? dimensions; // For bags: length, width, height
  final String? closureType; // For bags: zipper, magnetic, etc.
  final String? strapType; // For bags: crossbody, shoulder, etc.
  final int? capacity; // For bags: in liters
  final String? soleType; // For shoes: rubber, leather, etc.
  final String? upperMaterial; // For shoes: leather, canvas, mesh, etc.
  final String? liningMaterial; // For shoes and bags
  final String? careInstructions;
  final List<String>? features; // Special features like waterproof, anti-slip, etc.
  final bool favourite; // From API response
  final List<String>? tags; // Product tags/badges from API
  final bool isNew; // Whether product is new (based on creation date or API flag)
  final bool isOnSale; // Whether product is on sale (from API)
  final String? saleBadge; // Custom sale badge text from API

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.category,
    required this.brand,
    required this.type,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.sizes,
    required this.colors,
    this.colorImages,
    required this.createdAt,
    this.materials,
    this.heelHeightCm,
    this.heelType,
    this.dimensions,
    this.closureType,
    this.strapType,
    this.capacity,
    this.soleType,
    this.upperMaterial,
    this.liningMaterial,
    this.careInstructions,
    this.features,
    this.favourite = false,
    this.tags,
    this.isNew = false,
    this.isOnSale = false,
    this.saleBadge,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  double get discountPercentage => hasDiscount 
      ? ((originalPrice! - price) / originalPrice! * 100).roundToDouble()
      : 0.0;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        originalPrice,
        images,
        category,
        brand,
        type,
        rating,
        reviewCount,
        isAvailable,
        sizes,
        colors,
        colorImages,
        createdAt,
        materials,
        heelHeightCm,
        heelType,
        dimensions,
        closureType,
        strapType,
        capacity,
        soleType,
        upperMaterial,
        liningMaterial,
        careInstructions,
        features,
        tags,
        isNew,
        isOnSale,
        saleBadge,
      ];
}
