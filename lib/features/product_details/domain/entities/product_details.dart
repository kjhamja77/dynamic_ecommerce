import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class ProductDetails extends Equatable {
  final String id;
  final String brand;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int rating;
  final int reviewCount;
  final List<String> images;
  final List<ColorOption> colorOptions;
  final List<SizeOption> sizeOptions;
  final List<VariantAttributeOption> variantAttributeOptions; // New field for multiple variant attributes
  final String selectedColor;
  final String selectedSize;
  final bool isFavorite;
  final bool hasDiscount;
  final int? discountPercentage;
  final List<String> features;
  final String material;
  final List<String> materialsList; // Detailed materials breakdown
  final List<String> materialOptions; // Selectable material options
  final String? selectedMaterial; // Currently selected material option
  final String careInstructions;
  final String? websiteUrl; // Product page path like /shop/... or full URL
  final double? heelHeightCm; // If footwear has heels
  final String? heelType; // e.g., Stiletto, Block, Wedge
  final List<double> heelHeightOptions; // Selectable heel height options
  final double? selectedHeelHeightCm; // Currently selected heel height
  final bool isPlusMember;
  final int pointsEarned;
  // Related products
  final List<RelatedProduct> optionalProducts;
  final List<RelatedProduct> accessoryProducts;
  final List<RelatedProduct> alternativeProducts;
  final List<VariantCombination> variantCombinations;
  final String primaryVariantLabel; // e.g., Legs, Size, Material (non-color attribute shown as choices)
  // Overall stock flag for the currently selected variant (computed)
  final bool inStock;
  /// Quantity available for the currently selected variant (from BLoC); used for badge (low stock when 1–5).
  final int? selectedVariantQuantityAvailable;
  final List<ProductTag> tags; // Product tags/categories
  // Map of variant_id -> list of image URLs for that variant
  final Map<String, List<String>> variantImagesMap;

  const ProductDetails({
    required this.id,
    required this.brand,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.colorOptions,
    required this.sizeOptions,
    this.variantAttributeOptions = const [],
    required this.selectedColor,
    required this.selectedSize,
    required this.isFavorite,
    required this.hasDiscount,
    this.discountPercentage,
    required this.features,
    required this.material,
    this.materialsList = const [],
    this.materialOptions = const [],
    this.selectedMaterial,
    required this.careInstructions,
    this.websiteUrl,
    this.heelHeightCm,
    this.heelType,
    this.heelHeightOptions = const [],
    this.selectedHeelHeightCm,
    required this.isPlusMember,
    required this.pointsEarned,
    this.optionalProducts = const [],
    this.accessoryProducts = const [],
    this.alternativeProducts = const [],
    this.variantCombinations = const [],
    this.primaryVariantLabel = 'Size',
    this.inStock = true,
    this.selectedVariantQuantityAvailable,
    this.tags = const [],
    this.variantImagesMap = const {},
  });

  @override
  List<Object?> get props => [
        id,
        brand,
        name,
        description,
        price,
        originalPrice,
        rating,
        reviewCount,
        images,
        colorOptions,
        sizeOptions,
        variantAttributeOptions,
        selectedColor,
        selectedSize,
        isFavorite,
        hasDiscount,
        discountPercentage,
        features,
        material,
        materialsList,
        materialOptions,
        selectedMaterial,
        careInstructions,
        websiteUrl,
        heelHeightCm,
        heelType,
        heelHeightOptions,
        selectedHeelHeightCm,
        isPlusMember,
        pointsEarned,
      optionalProducts,
      accessoryProducts,
      alternativeProducts,
      variantCombinations,
      primaryVariantLabel,
      inStock,
      selectedVariantQuantityAvailable,
      tags,
      variantImagesMap,
      ];

  /// Get all variants that have a specific attribute value
  List<VariantCombination> getVariantsWithAttribute(String attributeName, String valueName) {
    return variantCombinations.where((variant) => 
      variant.hasAttributeValue(attributeName, valueName)
    ).toList();
  }

  /// Get all unique values for a specific attribute across all variants
  List<String> getUniqueAttributeValues(String attributeName) {
    final values = <String>{};
    for (final variant in variantCombinations) {
      final value = variant.getAttributeValue(attributeName);
      if (value != null && value.isNotEmpty) {
        values.add(value);
      }
    }
    return values.toList();
  }

  /// Get images for a specific variant_id
  List<String> getImagesForVariant(String variantId) {
    return variantImagesMap[variantId] ?? [];
  }

  /// Variant id used for images: first variant that matches selected color only.
  /// Images update only on color change; size/material/height do not change images.
  String? get variantIdForImagesByColor {
    if (selectedColor.isEmpty) return null;
    final norm = selectedColor.toLowerCase().trim();
    for (final v in variantCombinations) {
      final colorVal = v.getAttributeValue('COLOR NAME') ??
          v.getAttributeValue('COLOR') ??
          v.getAttributeValue('اللون');
      if (colorVal != null &&
          colorVal.toLowerCase().trim() == norm &&
          v.variantId.isNotEmpty) {
        return v.variantId;
      }
    }
    return null;
  }

  /// Get filtered images based on selected attributes
  List<String> getFilteredImages({String? color, String? size, String? material}) {
    List<VariantCombination> filteredVariants = variantCombinations;

    // Apply filters
    if (color != null) {
      filteredVariants = filteredVariants.where((variant) => 
        variant.hasAttributeValue('اللون', color) || 
        variant.hasAttributeValue('color', color)
      ).toList();
    }

    if (size != null) {
      filteredVariants = filteredVariants.where((variant) => 
        variant.hasAttributeValue(primaryVariantLabel, size) ||
        variant.hasAttributeValue('size', size)
      ).toList();
    }

    if (material != null) {
      filteredVariants = filteredVariants.where((variant) => 
        variant.hasAttributeValue('material', material)
      ).toList();
    }

    // Extract images from filtered variants
    final filteredImages = <String>[];
    for (final variant in filteredVariants) {
      final variantImagePath = '/web/image/product.product/${variant.variantId}/image_1920';
      final fullImageUrl = '${AppConstants.baseUrl}${variantImagePath.startsWith('/') ? variantImagePath.substring(1) : variantImagePath}';
      if (!filteredImages.contains(fullImageUrl)) {
        filteredImages.add(fullImageUrl);
      }
    }

    return filteredImages;
  }

  /// Create a copy of this ProductDetails with updated fields
  ProductDetails copyWith({
    String? id,
    String? brand,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    int? rating,
    int? reviewCount,
    List<String>? images,
    List<ColorOption>? colorOptions,
    List<SizeOption>? sizeOptions,
    String? selectedColor,
    String? selectedSize,
    bool? isFavorite,
    bool? hasDiscount,
    int? discountPercentage,
    List<String>? features,
    String? material,
    List<String>? materialsList,
    List<String>? materialOptions,
    String? selectedMaterial,
    String? careInstructions,
    String? websiteUrl,
    String? heelType,
    List<double>? heelHeightOptions,
    double? heelHeightCm,
    double? selectedHeelHeightCm,
    bool? isPlusMember,
    int? pointsEarned,
    List<RelatedProduct>? optionalProducts,
    List<RelatedProduct>? accessoryProducts,
    List<RelatedProduct>? alternativeProducts,
    List<VariantCombination>? variantCombinations,
    String? primaryVariantLabel,
    List<VariantAttributeOption>? variantAttributeOptions,
    bool? inStock,
    int? selectedVariantQuantityAvailable,
    List<ProductTag>? tags,
    Map<String, List<String>>? variantImagesMap,
  }) {
    return ProductDetails(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      images: images ?? this.images,
      colorOptions: colorOptions ?? this.colorOptions,
      sizeOptions: sizeOptions ?? this.sizeOptions,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      isFavorite: isFavorite ?? this.isFavorite,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      features: features ?? this.features,
      material: material ?? this.material,
      materialsList: materialsList ?? this.materialsList,
      materialOptions: materialOptions ?? this.materialOptions,
      selectedMaterial: selectedMaterial ?? this.selectedMaterial,
      careInstructions: careInstructions ?? this.careInstructions,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      heelType: heelType ?? this.heelType,
      heelHeightOptions: heelHeightOptions ?? this.heelHeightOptions,
      heelHeightCm: heelHeightCm ?? this.heelHeightCm,
      selectedHeelHeightCm: selectedHeelHeightCm ?? this.selectedHeelHeightCm,
      isPlusMember: isPlusMember ?? this.isPlusMember,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      optionalProducts: optionalProducts ?? this.optionalProducts,
      accessoryProducts: accessoryProducts ?? this.accessoryProducts,
      alternativeProducts: alternativeProducts ?? this.alternativeProducts,
      variantCombinations: variantCombinations ?? this.variantCombinations,
      primaryVariantLabel: primaryVariantLabel ?? this.primaryVariantLabel,
      variantAttributeOptions: variantAttributeOptions ?? this.variantAttributeOptions,
      inStock: inStock ?? this.inStock,
      selectedVariantQuantityAvailable: selectedVariantQuantityAvailable ?? this.selectedVariantQuantityAvailable,
      tags: tags ?? this.tags,
      variantImagesMap: variantImagesMap ?? this.variantImagesMap,
    );
  }

  /// Builds map of API attribute_name -> value_name from current selection (strings).
  /// Keys: COLOR, SIZE, MATERIALS, HEIGHT. Used to match variant by value_name (e.g. BLACK, 36, Synthetic Leather, 4.5).
  Map<String, String> getSelectedAttributesByValueName() {
    final map = <String, String>{};
    if (selectedColor.isNotEmpty) map['COLOR'] = selectedColor.trim();
    if (selectedSize.isNotEmpty) map['SIZE'] = selectedSize.trim();
    if (selectedMaterial != null && selectedMaterial!.isNotEmpty) {
      map['MATERIALS'] = selectedMaterial!.trim();
    }
    if (selectedHeelHeightCm != null) {
      map['HEIGHT'] = selectedHeelHeightCm!.toStringAsFixed(1);
    }
    // Fill from variantAttributeOptions for any attribute not yet set
    for (final opt in variantAttributeOptions) {
      if (opt.selectedValue.isEmpty) continue;
      final attrLower = opt.attributeName.toLowerCase();
      if (attrLower.contains('color') || attrLower == 'colour' || attrLower == 'اللون') {
        if (!map.containsKey('COLOR')) map['COLOR'] = opt.selectedValue.trim();
      } else if (attrLower == 'size' || (primaryVariantLabel.isNotEmpty && attrLower == primaryVariantLabel.toLowerCase())) {
        if (!map.containsKey('SIZE')) map['SIZE'] = opt.selectedValue.trim();
      } else if (attrLower.contains('material')) {
        if (!map.containsKey('MATERIALS')) map['MATERIALS'] = opt.selectedValue.trim();
      } else if (attrLower == 'height' || attrLower.contains('heel')) {
        if (!map.containsKey('HEIGHT')) map['HEIGHT'] = opt.selectedValue.trim();
      }
    }
    return map;
  }

  /// Builds map of attribute_id (from variant_attributes) -> value_name from current selection.
  /// Used to filter variants by attribute_id + value_name (variant_combinations.attributes).
  Map<String, String> getSelectedAttributesByAttributeIdAndValueName() {
    final map = <String, String>{};
    for (final opt in variantAttributeOptions) {
      if (opt.attributeId == null || opt.attributeId!.trim().isEmpty) continue;
      if (opt.selectedValue.isEmpty) continue;
      map[opt.attributeId!.trim()] = opt.selectedValue.trim();
    }
    return map;
  }

  /// Finds the single variant combination that matches current selection.
  /// Prefer matching by attribute_id + value_name (from variant_attributes and variant_combinations);
  /// fallback to attribute_name + value_name.
  VariantCombination? findVariantMatchingSelectionByValueName() {
    // 1) Prefer filter by attribute_id + value_name when we have attribute ids
    final byAttrId = getSelectedAttributesByAttributeIdAndValueName();
    if (byAttrId.isNotEmpty) {
      final matching = variantCombinations
          .where((c) => c.matchesAttributesByAttributeIdAndValueName(byAttrId))
          .toList();
      if (matching.isNotEmpty) {
        if (matching.length == 1) return matching.first;
        matching.sort((a, b) => (b.quantityAvailable ?? 0).compareTo(a.quantityAvailable ?? 0));
        return matching.first;
      }
    }
    // 2) Fallback: match by attribute_name + value_name
    final selected = getSelectedAttributesByValueName();
    if (selected.isEmpty) return null;
    final matching = variantCombinations
        .where((c) => c.matchesAttributesByValueName(selected))
        .toList();
    if (matching.isEmpty) return null;
    if (matching.length == 1) return matching.first;
    matching.sort((a, b) => (b.quantityAvailable ?? 0).compareTo(a.quantityAvailable ?? 0));
    return matching.first;
  }
}

class ProductTag extends Equatable {
  final String id;
  final String name;

  const ProductTag({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

/// Image helpers for variant-based products
///
/// These functions centralize the logic of picking images for a given
/// `variantId` using the `variantImagesMap` that is already parsed on
/// `ProductDetails`. They are safe to call from BLoC/UI whenever a
/// variant is selected (color, size, material, or any other attribute)
/// and will always fall back to the current `images` list when no
/// specific mapping exists for that variant.
extension ProductDetailsImagesX on ProductDetails {
  /// Return all images for a specific variant.
  /// Falls back to the existing product images when there is no mapping.
  List<String> imagesForVariant(String variantId) {
    if (variantId.isEmpty) return images;

    final variantImages = variantImagesMap[variantId] ?? const <String>[];

    // Debug: inspect what we actually have for this variant
    // (helps understand "single image vs three images" issues).
    // Note: keep prints lightweight in production if needed.
    // ignore: avoid_print
    print(
      '🧪 ProductDetailsImagesX.imagesForVariant → variantId=$variantId, '
      'mappedCount=${variantImages.length}, mappedImages=$variantImages',
    );

    if (variantImages.isNotEmpty) return List<String>.from(variantImages);

    // Fallback: keep current images (already set by API parsing)
    return List<String>.from(images);
  }

  /// Convenience: return a new ProductDetails with images updated
  /// to match the given variant.
  ProductDetails withImagesForVariant(String variantId) {
    return copyWith(
      images: List<String>.from(imagesForVariant(variantId)),
    );
  }
}

class ColorOption extends Equatable {
  final String id;
  final String name; // English name for data/logic matching
  final String? displayName; // Localized display name (Arabic when language is Arabic)
  final String code;
  final List<String> images;
  final bool isSelected;
  final bool isAvailable;

  const ColorOption({
    required this.id,
    required this.name,
    this.displayName,
    required this.code,
    required this.images,
    required this.isSelected,
    this.isAvailable = true, // Default to available if not specified
  });

  /// Get the display name (localized) or fallback to English name
  String get displayNameOrName => displayName ?? name;

  @override
  List<Object?> get props => [id, name, displayName, code, images, isSelected, isAvailable];
}

class SizeOption extends Equatable {
  final String id;
  final String name;
  final bool isAvailable;
  final bool isRecommended;
  final bool isSelected;

  const SizeOption({
    required this.id,
    required this.name,
    required this.isAvailable,
    required this.isRecommended,
    required this.isSelected,
  });

  @override
  List<Object?> get props => [id, name, isAvailable, isRecommended, isSelected];
}

class RelatedProduct extends Equatable {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String type; // 'template' or 'variant'

  const RelatedProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, price, imageUrl, type];
}

class VariantCombination extends Equatable {
  final String variantId;
  final bool inStock;
  final List<VariantAttribute> attributes;
  final double? quantityAvailable;

  const VariantCombination({
    required this.variantId,
    required this.inStock,
    required this.attributes,
    this.quantityAvailable,
  });

  @override
  List<Object?> get props => [variantId, inStock, attributes, quantityAvailable];

  /// Get the value of a specific attribute
  String? getAttributeValue(String attributeName) {
    try {
      return attributes.firstWhere((attr) =>
          attr.attributeName.toLowerCase() == attributeName.toLowerCase())
          .valueName;
    } catch (e) {
      return null;
    }
  }

  /// Get the value_id of a specific attribute (for matching when value_name differs e.g. Arabic vs English).
  String? getAttributeValueId(String attributeName) {
    try {
      final attr = attributes.firstWhere((attr) =>
          attr.attributeName.toLowerCase() == attributeName.toLowerCase());
      return attr.valueId;
    } catch (e) {
      return null;
    }
  }

  /// Check if this variant has a specific attribute value (by name or by value_id).
  bool hasAttributeValue(String attributeName, String valueName) {
    return getAttributeValue(attributeName)?.toLowerCase() == valueName.toLowerCase();
  }

  /// True if this variant has this attribute with the given value (match by valueName or valueId).
  bool hasAttributeValueOrId(String attributeName, String valueName, String? valueId) {
    final v = getAttributeValue(attributeName);
    final id = getAttributeValueId(attributeName);
    if (valueName.isNotEmpty && v != null &&
        v.toLowerCase().trim() == valueName.toLowerCase().trim()) return true;
    if (valueId != null && valueId.isNotEmpty && id != null &&
        id.trim() == valueId.trim()) return true;
    return false;
  }

  /// Returns true if this variant's attributes match the given map of
  /// [attributeName] -> [valueId] (API attribute_name and value_id).
  /// Used to filter the exact variant combination for stock badge.
  bool matchesAttributesById(Map<String, String> attributeNameToValueId) {
    if (attributeNameToValueId.isEmpty) return false;
    for (final entry in attributeNameToValueId.entries) {
      final apiName = entry.key;
      final valueId = entry.value;
      if (valueId.isEmpty) continue;
      final attr = attributes.where((a) =>
          a.attributeName.toLowerCase().trim() == apiName.toLowerCase().trim()).toList();
      if (attr.isEmpty) return false;
      final match = attr.any((a) => a.valueId != null && a.valueId!.trim() == valueId.trim());
      if (!match) return false;
    }
    return true;
  }

  /// Returns true if this variant's attributes match the given map of
  /// [attributeName] -> [value_name] (string). Compares variant's attribute value_name
  /// with the selected value string (e.g. "BLACK", "36", "Synthetic Leather", "4.5").
  /// Keys are logical names (COLOR, SIZE, MATERIALS, HEIGHT); variant may use "COLOR NAME", "SIZE", etc.
  bool matchesAttributesByValueName(Map<String, String> attributeNameToValueName) {
    if (attributeNameToValueName.isEmpty) return false;
    String norm(String s) => s.toLowerCase().trim();
    bool attrNameMatches(String variantAttrName, String logicalKey) {
      final v = norm(variantAttrName);
      final k = norm(logicalKey);
      if (v == k) return true;
      if (k == 'color') return v == 'color' || v == 'color name' || v == 'colour' || v == 'اللون';
      if (k == 'size') return v == 'size' || v.contains('size');
      if (k == 'materials') return v == 'materials' || v == 'material name' || v == 'material';
      if (k == 'height') return v == 'height' || v.contains('heel');
      return false;
    }
    for (final entry in attributeNameToValueName.entries) {
      final logicalKey = entry.key;
      final selectedValue = entry.value;
      if (selectedValue.isEmpty) continue;
      final attrs = attributes.where((a) => attrNameMatches(a.attributeName, logicalKey)).toList();
      if (attrs.isEmpty) return false;
      final match = attrs.any((a) => norm(a.valueName) == norm(selectedValue));
      if (!match) return false;
    }
    return true;
  }

  /// Returns true if this variant's attributes match the given map of
  /// [attribute_id] -> [value_name]. Validates using variant_combinations
  /// attributes (attribute_id and value_name). Used when we have attribute ids
  /// from variant_attributes to filter the exact variant.
  bool matchesAttributesByAttributeIdAndValueName(Map<String, String> attributeIdToValueName) {
    if (attributeIdToValueName.isEmpty) return false;
    String norm(String s) => s.toLowerCase().trim();
    for (final entry in attributeIdToValueName.entries) {
      final attrId = entry.key.trim();
      final selectedValue = entry.value;
      if (attrId.isEmpty || selectedValue.isEmpty) continue;
      final attrs = attributes.where((a) =>
          (a.attributeId ?? '').trim() == attrId).toList();
      if (attrs.isEmpty) return false;
      final match = attrs.any((a) => norm(a.valueName) == norm(selectedValue));
      if (!match) return false;
    }
    return true;
  }
}

class VariantAttribute extends Equatable {
  final String attributeName;
  final String valueName; //size 42
  // Optional numeric identifiers coming from the API (attribute_id, value_id)
  final String? attributeId;
  final String? valueId; //

  const VariantAttribute({
    required this.attributeName,
    required this.valueName,
    this.attributeId,
    this.valueId,
  });

  @override
  List<Object?> get props => [attributeName, valueName, attributeId, valueId];
}

class VariantAttributeOption extends Equatable {
  final String attributeName;
  final List<VariantAttributeValue> values;
  final String selectedValue;
  /// API attribute name as returned in variant_combinations (e.g. MATERIALS, HEIGHT).
  /// Used for combo lookup so any attribute works without hardcoding names.
  final String? apiAttributeName;
  /// Attribute id from variant_attributes (e.g. 8=COLOR, 7=SIZE, 9=MATERIALS, 10=HEIGHT).
  /// Used to filter variants by attribute_id + value_name.
  final String? attributeId;

  const VariantAttributeOption({
    required this.attributeName,
    required this.values,
    required this.selectedValue,
    this.apiAttributeName,
    this.attributeId,
  });

  @override
  List<Object?> get props => [attributeName, values, selectedValue, apiAttributeName, attributeId];
}

class VariantAttributeValue extends Equatable {
  final String id;
  final String name;
  final bool isAvailable;
  final bool isSelected;

  const VariantAttributeValue({
    required this.id,
    required this.name,
    required this.isAvailable,
    required this.isSelected,
  });

  @override
  List<Object?> get props => [id, name, isAvailable, isSelected];
}
