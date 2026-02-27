import 'package:flutter/foundation.dart';

import '../../home/domain/entities/product.dart' as HomeProduct;
import '../../../core/utils/image_cache_utils.dart';

/// Offloads heavy catalog product parsing to a background isolate so that
/// the main isolate can remain responsive while filter-search responses are
/// being converted into domain entities.
Future<List<HomeProduct.Product>> parseCatalogProductsInBackground(
  List<dynamic> apiItems,
) {
  final items = apiItems.cast<Map<String, dynamic>>();
  return compute<List<Map<String, dynamic>>, List<HomeProduct.Product>>(
    _parseCatalogProducts,
    items,
  );
}

List<HomeProduct.Product> _parseCatalogProducts(
  List<Map<String, dynamic>> items,
) {
  return items.map(_convertFromApiResponseIsolate).toList();
}

/// Local helper for building full image URLs in the isolate.
String _constructImageUrlIsolate(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) return '';
  return ImageCacheUtils.normalizeImageUrl(imagePath);
}

/// Copy of the catalog API → HomeProduct.Product mapping logic, adapted to
/// run inside an isolate (no repository instance / cache access required).
HomeProduct.Product _convertFromApiResponseIsolate(Map<String, dynamic> item) {
  final images = <String>[];
  final productType = item['type'] as String? ?? 'variant';
  final productId = item['id']?.toString() ?? '';

  print('🔍 [Isolate] Catalog API Response for: ${item['name']}');
  print('  - type: $productType');
  print('  - id: $productId');
  print('  - images: ${item['images']}');
  print('  - main_image: ${item['main_image']}');
  print('  - image_1920: ${item['image_1920']}');

  // Build variant_id to color mapping from variant_combinations
  final Map<String, String> variantIdToColor = {};
  final Map<String, String> canonicalVariantIdByColor = {};
  final variantCombinations = item['variant_combinations'] as List<dynamic>? ?? [];

  for (final v in variantCombinations) {
    if (v is Map<String, dynamic>) {
      final variantId = (v['variant_id'] ?? '').toString();
      String? colorName;
      final attrs = (v['attributes'] as List<dynamic>? ?? const []);
      for (final a in attrs) {
        if (a is Map<String, dynamic>) {
          final attrName = (a['attribute_name'] ?? '').toString().toLowerCase();
          if (attrName == 'color' ||
              attrName == 'colour' ||
              attrName == 'اللون' ||
              attrName == 'color name') {
            colorName = (a['value_name'] ?? '').toString();
            break;
          }
        }
      }
      if (variantId.isNotEmpty && colorName != null && colorName.isNotEmpty) {
        variantIdToColor[variantId] = colorName;
        canonicalVariantIdByColor.putIfAbsent(colorName, () => variantId);
      }
    }
  }

  final Map<String, List<String>> colorToImages = {};
  String? templateImage;
  final List<String> variantImages = [];
  final List<String> templateImages = [];

  if (item['images'] != null && (item['images'] as List).isNotEmpty) {
    final imagesList = item['images'] as List<dynamic>;

    bool hasTypeField = false;
    if (imagesList.isNotEmpty && imagesList.first is Map<String, dynamic>) {
      hasTypeField = (imagesList.first as Map<String, dynamic>).containsKey('type');
    }

    if (hasTypeField) {
      for (final img in imagesList) {
        if (img is! Map<String, dynamic>) continue;

        final imagePath = (img['url'] as String?) ?? (img['image'] as String?);
        if (imagePath == null || imagePath.isEmpty) continue;

        final imageUrl = _constructImageUrlIsolate(imagePath);
        if (imageUrl.isEmpty) continue;

        final imageType = (img['type'] ?? '').toString().toLowerCase();
        final variantId = (img['variant_id'] ?? '').toString();

        final bool isVariantScopedImage =
            imageType == 'variant' ||
            imageType == 'variant_gallery' ||
            (imageType == 'template_gallery' && variantId.isNotEmpty);

        final bool isTemplateScopedImage =
            imageType == 'template' ||
            (imageType == 'template_gallery' && variantId.isEmpty) ||
            imageType.isEmpty;

        if (isTemplateScopedImage && templateImage == null) {
          templateImage = imageUrl;
        }

        if (isVariantScopedImage) {
          if (!variantImages.contains(imageUrl)) {
            variantImages.add(imageUrl);
            print(
              '  - [Isolate] Added VARIANT-scoped image (type: $imageType, variant_id: $variantId): $imageUrl',
            );
          }
        } else if (isTemplateScopedImage) {
          if (!templateImages.contains(imageUrl)) {
            templateImages.add(imageUrl);
            print(
              '  - [Isolate] Added TEMPLATE-scoped image (type: $imageType, variant_id: $variantId): $imageUrl',
            );
          }
        }

        if (isVariantScopedImage && variantId.isNotEmpty) {
          final color = variantIdToColor[variantId];
          if (color != null && canonicalVariantIdByColor[color] == variantId) {
            colorToImages.putIfAbsent(color, () => <String>[]);
            if (!colorToImages[color]!.contains(imageUrl)) {
              colorToImages[color]!.add(imageUrl);
              print(
                '  - [Isolate] Added color image for "$color" (variant_id: $variantId): $imageUrl',
              );
            }
          }
        }
      }
    } else {
      for (final img in imagesList) {
        if (img is! Map<String, dynamic>) continue;

        final imagePath = (img['image'] as String?);
        if (imagePath == null || imagePath.isEmpty) continue;

        final imageUrl = _constructImageUrlIsolate(imagePath);
        if (imageUrl.isEmpty) continue;

        if (!templateImages.contains(imageUrl)) {
          templateImages.add(imageUrl);
          print('  - [Isolate] Added TEMPLATE-scoped product image: $imageUrl');
        }

        if (templateImage == null) {
          templateImage = imageUrl;
        }
      }
    }

    images
      ..addAll(variantImages)
      ..addAll(templateImages);

    print(
      '  - [Isolate] Using merged images array: ${images.length} images (variant=${variantImages.length}, template=${templateImages.length})',
    );
  } else if (item['main_image'] != null && item['main_image'].toString().isNotEmpty) {
    final mainImageUrl = _constructImageUrlIsolate(item['main_image'] as String);
    if (mainImageUrl.isNotEmpty) {
      images.add(mainImageUrl);
    }
    print('  - [Isolate] Using main_image: $mainImageUrl');
  } else if (item['image_1920'] != null && item['image_1920'].toString().isNotEmpty) {
    final imageUrl = _constructImageUrlIsolate(item['image_1920'] as String);
    if (imageUrl.isNotEmpty) {
      images.add(imageUrl);
    }
    print('  - [Isolate] Using image_1920: $imageUrl');
  } else {
    print('  - [Isolate] No images found, using placeholder');
    images.add('https://via.placeholder.com/300x300?text=No+Image');
  }

  if (productType == 'variant' && images.isEmpty) {
    final productTemplate = item['product_template'] as Map<String, dynamic>?;
    String? templateImageUrl;

    if (productTemplate != null) {
      final templateImagePath =
          productTemplate['image_1920']?.toString() ?? '';
      if (templateImagePath.isNotEmpty) {
        templateImageUrl = _constructImageUrlIsolate(templateImagePath);
      } else if (productTemplate['id'] != null) {
        final templateId = productTemplate['id'].toString();
        templateImageUrl = _constructImageUrlIsolate(
          '/web/image/product.template/$templateId/image_1920',
        );
      }
    }

    if (templateImageUrl != null && templateImageUrl.isNotEmpty) {
      images.add(templateImageUrl);
      print(
        '  - [Isolate] Added fallback TEMPLATE image: $templateImageUrl',
      );
    }
  }

  String category = 'Unknown';
  if (item['categories'] != null && (item['categories'] as List).isNotEmpty) {
    category = (item['categories'] as List).first['name'] as String;
  }

  final sizes = <String>[];
  final colors = <String>[];

  if (item['product_attributes'] != null) {
    final attributes = item['product_attributes'] as List<dynamic>;
    for (final attr in attributes) {
      final attrName = attr['name'] as String;
      final values = attr['values'] as List<dynamic>;

      if (attrName.toLowerCase() == 'size') {
        sizes.addAll(values.map((v) => v['name'] as String));
      } else if (attrName.toLowerCase() == 'color') {
        colors.addAll(values.map((v) => v['name'] as String));

        for (final value in values) {
          if (value is Map<String, dynamic>) {
            final colorName = value['name'] as String?;
            final colorImagePath = value['image'] as String?;

            if (colorName != null &&
                colorName.isNotEmpty &&
                colorImagePath != null &&
                colorImagePath.isNotEmpty) {
              final colorImageUrl = _constructImageUrlIsolate(colorImagePath);
              if (colorImageUrl.isNotEmpty) {
                colorToImages.putIfAbsent(colorName, () => <String>[]);
                if (!colorToImages[colorName]!.contains(colorImageUrl)) {
                  colorToImages[colorName]!.add(colorImageUrl);
                  print(
                    '  - [Isolate] Added color image from product_attributes for "$colorName": $colorImageUrl',
                  );
                }
              }
            }
          }
        }
      }
    }
  }

  if (item['attributes'] != null) {
    final currentAttributes = item['attributes'] as List<dynamic>;
    for (final attr in currentAttributes) {
      final attrName = attr['attribute_name'] as String;
      final valueName = attr['value_name'] as String;

      if (attrName.toLowerCase() == 'size' && !sizes.contains(valueName)) {
        sizes.add(valueName);
      } else if (attrName.toLowerCase() == 'color' && !colors.contains(valueName)) {
        colors.add(valueName);
      }
    }
  }

  print(
    '📦 [Isolate] Creating Product: ID=$productId, Name=${item['name']}, Images=${images.length}',
  );

  if (images.isEmpty) {
    final productTemplate = item['product_template'] as Map<String, dynamic>?;
    final templateId = productTemplate?['id']?.toString();
    final fallbackPath = templateId != null
        ? '/web/image/product.template/$templateId/image_1920'
        : '/web/image/product.template/${item['id']}/image_1920';
    final fallbackImageUrl = _constructImageUrlIsolate(fallbackPath);
    images.add(fallbackImageUrl);
    print('  - [Isolate] Added fallback image: $fallbackImageUrl');
  }

  final tags = <String>[];
  final isOnSale = item['is_on_sale'] as bool? ?? false;
  final saleBadge = item['sale_badge'] as String?;
  final isNew = item['is_new'] as bool? ?? false;

  if (item['tags'] != null && (item['tags'] as List).isNotEmpty) {
    tags.addAll((item['tags'] as List).map((tag) => tag['name'] as String));
  }

  final createdAt = DateTime.parse(item['create_date'] as String);
  final isNewByDate = DateTime.now().difference(createdAt).inDays <= 30;
  final finalIsNew = isNew || isNewByDate;

  final price = (item['price'] as num).toDouble();
  final originalPrice = item['original_price'] as num?;
  final hasDiscount = originalPrice != null && originalPrice > price;
  final finalOriginalPrice = hasDiscount ? originalPrice.toDouble() : null;

  String finalName;
  try {
    final attrs = (item['attributes'] as List<dynamic>?) ?? const [];
    final attrValues = <String>[];
    for (final a in attrs) {
      final valueName =
          (a as Map<String, dynamic>)['value_name']?.toString().trim();
      if (valueName != null && valueName.isNotEmpty) {
        attrValues.add(valueName);
      }
    }
    final productTemplate = item['product_template'] as Map<String, dynamic>?;
    final hasVariantsFlag =
        (productTemplate != null && (productTemplate['has_variants'] == true)) ||
            ((item['type']?.toString() ?? '').toLowerCase() == 'variant');
    if (hasVariantsFlag && attrValues.isNotEmpty) {
      finalName = '${item['name']} (${attrValues.join(', ')})';
    } else {
      finalName = item['name'] as String;
    }
  } catch (_) {
    finalName = item['name'] as String;
  }

  print('═══════════════════════════════════════════════════════');
  print('🔧 [Isolate] _convertFromApiResponse: Creating Product from API response');
  print('  📦 Product ID: $productId');
  print('  📛 Product Name: $finalName');
  print('  🏷️  API productType: $productType');
  print('═══════════════════════════════════════════════════════');

  final product = HomeProduct.Product(
    id: productId,
    name: finalName,
    description: item['description'] as String? ?? '',
    price: price,
    originalPrice: finalOriginalPrice,
    images: images,
    category: category,
    brand: item['brand'] as String? ?? 'Unknown',
    type: productType,
    rating: 4.5,
    reviewCount: 100,
    isAvailable: (item['qty_available'] as num).toDouble() > 0,
    sizes: sizes.isNotEmpty ? sizes : ['S', 'M', 'L'],
    colors: colors,
    colorImages: colorToImages.isNotEmpty ? colorToImages : null,
    createdAt: createdAt,
    favourite: false,
    tags: tags,
    isNew: finalIsNew,
    isOnSale: isOnSale || hasDiscount,
    saleBadge: saleBadge,
  );

  print(
    '✅ [Isolate] Product created: ID=${product.id}, Images=${product.images.length}, FirstImage=${product.images.isNotEmpty ? product.images.first : 'none'}',
  );
  return product;
}

