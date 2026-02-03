import '../../domain/entities/product.dart';
import 'product_category_model.dart';
import 'product_image_model.dart';
import 'product_attribute_model.dart';
import 'variant_combination_model.dart';
import 'related_product_model.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.shortDescription,
    required super.price,
    required super.currency,
    required super.category,
    super.brand,
    required super.type,
    required super.quantityAvailable,
    required super.inStock,
    required super.totalVariants,
    required super.availableVariants,
    required super.variantAttributes,
    required super.variantCombinations,
    required super.images,
    required super.optionalProductIds,
    required super.accessoryProductIds,
    required super.alternativeProductIds,
    required super.sku,
    required super.barcode,
    super.ribbon,
    super.mainImage,
    super.favourite,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'IQD',
      category: ProductCategoryModel.fromJson(json['category'] ?? {}),
      brand: json['brand'] is Map ? json['brand']['name'] : json['brand'],
      type: json['type'] ?? 'template',
      quantityAvailable: (json['quantity_available'] ?? 0.0).toDouble(),
      inStock: json['in_stock'] ?? false,
      totalVariants: json['total_variants'] ?? 0,
      availableVariants: json['available_variants'] ?? 0,
      variantAttributes: (json['variant_attributes'] as List<dynamic>?)
          ?.map((attr) => ProductAttributeModel.fromJson(attr))
          .toList() ?? [],
      variantCombinations: (json['variant_combinations'] as List<dynamic>?)
          ?.map((variant) => VariantCombinationModel.fromJson(variant))
          .toList() ?? [],
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => ProductImageModel.fromJson(image))
          .toList() ?? [],
      optionalProductIds: (json['optional_product_ids'] as List<dynamic>?)
          ?.map((product) => RelatedProductModel.fromJson(product))
          .toList() ?? [],
      accessoryProductIds: (json['accessory_product_ids'] as List<dynamic>?)
          ?.map((product) => RelatedProductModel.fromJson(product))
          .toList() ?? [],
      alternativeProductIds: (json['alternative_product_ids'] as List<dynamic>?)
          ?.map((product) => RelatedProductModel.fromJson(product))
          .toList() ?? [],
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      ribbon: json['ribbon'],
      mainImage: json['main_image'],
      favourite: json['favourite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'short_description': shortDescription,
      'price': price,
      'currency': currency,
      'category': (category as ProductCategoryModel).toJson(),
      'brand': brand,
      'type': type,
      'quantity_available': quantityAvailable,
      'in_stock': inStock,
      'total_variants': totalVariants,
      'available_variants': availableVariants,
      'variant_attributes': variantAttributes.map((attr) => (attr as ProductAttributeModel).toJson()).toList(),
      'variant_combinations': variantCombinations.map((variant) => (variant as VariantCombinationModel).toJson()).toList(),
      'images': images.map((image) => (image as ProductImageModel).toJson()).toList(),
      'optional_product_ids': optionalProductIds.map((product) => (product as RelatedProductModel).toJson()).toList(),
      'accessory_product_ids': accessoryProductIds.map((product) => (product as RelatedProductModel).toJson()).toList(),
      'alternative_product_ids': alternativeProductIds.map((product) => (product as RelatedProductModel).toJson()).toList(),
      'sku': sku,
      'barcode': barcode,
      'ribbon': ribbon,
      'main_image': mainImage,
      'favourite': favourite,
    };
  }
}


