import 'package:equatable/equatable.dart';
import 'product_category.dart';
import 'product_image.dart';
import 'product_attribute.dart';
import 'variant_combination.dart';
import 'related_product.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String description;
  final String shortDescription;
  final double price;
  final String currency;
  final ProductCategory category;
  final String? brand;
  final String type; // 'template' or 'variant'
  final double quantityAvailable;
  final bool inStock;
  final int totalVariants;
  final int availableVariants;
  final List<ProductAttribute> variantAttributes;
  final List<VariantCombination> variantCombinations;
  final List<ProductImage> images;
  final List<RelatedProduct> optionalProductIds;
  final List<RelatedProduct> accessoryProductIds;
  final List<RelatedProduct> alternativeProductIds;
  final String sku;
  final String barcode;
  final String? ribbon;
  final String? mainImage; // For product list
  final bool favourite; // From API response

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.price,
    required this.currency,
    required this.category,
    this.brand,
    required this.type,
    required this.quantityAvailable,
    required this.inStock,
    required this.totalVariants,
    required this.availableVariants,
    required this.variantAttributes,
    required this.variantCombinations,
    required this.images,
    required this.optionalProductIds,
    required this.accessoryProductIds,
    required this.alternativeProductIds,
    required this.sku,
    required this.barcode,
    this.ribbon,
    this.mainImage,
    this.favourite = false,
  });

  // Helper getters
  bool get hasVariants => totalVariants > 1;
  bool get hasAttributes => variantAttributes.isNotEmpty;
  bool get hasImages => images.isNotEmpty;
  bool get hasOptionalProducts => optionalProductIds.isNotEmpty;
  bool get hasAccessoryProducts => accessoryProductIds.isNotEmpty;
  bool get hasAlternativeProducts => alternativeProductIds.isNotEmpty;

  // Get template image URL
  String? get templateImageUrl {
    final templateImage = images.firstWhere(
      (image) => image.type == 'template',
      orElse: () => images.isNotEmpty ? images.first : const ProductImage(type: '', url: '', alt: ''),
    );
    return templateImage.url.isNotEmpty ? templateImage.url : null;
  }

  // Get variant image URL by variant ID
  String? getVariantImageUrl(int variantId) {
    final variantImage = images.firstWhere(
      (image) => image.type == 'variant' && image.variantId == variantId,
      orElse: () => const ProductImage(type: '', url: '', alt: ''),
    );
    return variantImage.url.isNotEmpty ? variantImage.url : null;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        shortDescription,
        price,
        currency,
        category,
        brand,
        type,
        quantityAvailable,
        inStock,
        totalVariants,
        availableVariants,
        variantAttributes,
        variantCombinations,
        images,
        optionalProductIds,
        accessoryProductIds,
        alternativeProductIds,
        sku,
        barcode,
        ribbon,
        mainImage,
        favourite,
      ];
}


