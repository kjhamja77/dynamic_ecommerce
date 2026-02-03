import '../../domain/entities/product_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/image_cache_utils.dart';

class ProductImageModel extends ProductImage {
  const ProductImageModel({
    required super.type,
    super.variantId,
    required super.url,
    required super.alt,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    // API may return either 'url' or 'image' field - check both
    final rawUrl = (json['url'] ?? json['image'] ?? '').toString();
    
    // Use normalizeImageUrl to fix double slashes and ensure proper URL construction
    final imageUrl = ImageCacheUtils.normalizeImageUrl(rawUrl);
    
    return ProductImageModel(
      type: json['type'] ?? '',
      variantId: json['variant_id'],
      url: imageUrl,
      alt: json['alt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'variant_id': variantId,
      'url': url,
      'alt': alt,
    };
  }
}


