import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';

class ProductDetails extends Equatable {
  final String id;
  final String brand;
  /// Optional brand id from backend response.
  final int? brandId;
  /// Optional full URL for the brand image.
  final String? brandImageUrl;
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
  // Map of value_id -> list of available combination value_ids
  // Used for smart enable/disable logic: when a value is selected,
  // only values in its combination list remain enabled
  final Map<String, List<String>> attributeValueCombinations;

  const ProductDetails({
    required this.id,
    required this.brand,
    this.brandId,
    this.brandImageUrl,
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
    this.attributeValueCombinations = const {},
  });

  @override
  List<Object?> get props => [
        id,
        brand,
        brandId,
        brandImageUrl,
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
      attributeValueCombinations,
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
    int? brandId,
    String? brandImageUrl,
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
    Map<String, List<String>>? attributeValueCombinations,
  }) {
    return ProductDetails(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      brandId: brandId ?? this.brandId,
      brandImageUrl: brandImageUrl ?? this.brandImageUrl,
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
      attributeValueCombinations: attributeValueCombinations ?? this.attributeValueCombinations,
    );
  }

  /// Builds map of API attribute_name -> value_name from current selection (strings).
  /// Keys: COLOR, SIZE, MATERIALS, HEIGHT, WIDTH, MEASUREMENT, etc.
  /// Used to match variant by value_name (e.g. BLACK, 36, Synthetic Leather, 4.5).
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
      final value = opt.selectedValue.trim();
      if (attrLower.contains('color') || attrLower == 'colour' || attrLower == 'اللون') {
        if (!map.containsKey('COLOR')) map['COLOR'] = value;
      } else if (attrLower == 'size' || (primaryVariantLabel.isNotEmpty && attrLower == primaryVariantLabel.toLowerCase())) {
        if (!map.containsKey('SIZE')) map['SIZE'] = value;
      } else if (attrLower.contains('material')) {
        if (!map.containsKey('MATERIALS')) map['MATERIALS'] = value;
      } else if (attrLower == 'height' || attrLower.contains('heel')) {
        if (!map.containsKey('HEIGHT')) map['HEIGHT'] = value;
      } else {
        // Include all other attributes (WIDTH, MEASUREMENT, BRAND, etc.) for exact variant matching
        final key = opt.apiAttributeName?.isNotEmpty == true
            ? opt.apiAttributeName!
            : opt.attributeName;
        map[key] = value;
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

  /// Filters variants based on all selected attributes from variantAttributeOptions.
  /// Returns all variant combinations that match the currently selected attribute values.
  /// This function uses attribute_id + value_name matching when available, falling back to attribute_name + value_name.
  /// 
  /// Example usage:
  /// ```dart
  /// final filteredVariants = productDetails.filterVariantsBySelectedAttributes();
  /// // Returns all variants that match SIZE=36, COLOR=BLACK, MATERIALS=Synthetic Leather, etc.
  /// ```
  List<VariantCombination> filterVariantsBySelectedAttributes() {
    // Get all selected attributes from variantAttributeOptions
    final Map<String, String> selectedAttributes = {};
    
    for (final opt in variantAttributeOptions) {
      if (opt.selectedValue.isEmpty) continue;
      
      // Prefer using attribute_id if available (more reliable matching)
      if (opt.attributeId != null && opt.attributeId!.trim().isNotEmpty) {
        selectedAttributes[opt.attributeId!.trim()] = opt.selectedValue.trim();
      } else {
        // Fallback to attribute name
        final attrKey = opt.apiAttributeName?.isNotEmpty == true 
            ? opt.apiAttributeName! 
            : opt.attributeName;
        selectedAttributes[attrKey] = opt.selectedValue.trim();
      }
    }
    
    if (selectedAttributes.isEmpty) {
      return List.from(variantCombinations);
    }
    
    // Filter variants that match all selected attributes
    final filtered = variantCombinations.where((variant) {
      // Try matching by attribute_id first (more reliable)
      final byAttrId = getSelectedAttributesByAttributeIdAndValueName();
      if (byAttrId.isNotEmpty) {
        return variant.matchesAttributesByAttributeIdAndValueName(byAttrId);
      }
      
      // Fallback to attribute_name matching
      return variant.matchesAttributesByValueName(selectedAttributes);
    }).toList();
    
    return filtered;
  }

  /// Returns all **in‑stock** variants that are compatible with the **current UI
  /// selection** (SIZE, MATERIAL, HEIGHT, etc.).
  ///
  /// This uses [filterVariantsBySelectedAttributes] and then applies the stock
  /// rule (`inStock == true && quantityAvailable > 0`).
  List<VariantCombination> getCompatibleInStockVariantsForCurrentSelection() {
    if (variantCombinations.isEmpty) {
      return const <VariantCombination>[];
    }

    final filtered = filterVariantsBySelectedAttributes();
    if (filtered.isEmpty) {
      return const <VariantCombination>[];
    }

    final compatible = filtered.where((v) {
      final qty = v.quantityAvailable ?? 0;
      return v.inStock && qty > 0;
    }).toList();

    return compatible;
  }

  /// Builds a map of **attribute name → set of enabled value names** based on the
  /// **current selection across all attributes**.
  ///
  /// - Keys are normalized attribute names (lower‑cased, trimmed), e.g.:
  ///   `"size"`, `"materials"`, `"height"`, `"width"`, `"material name"`, etc.
  /// - Values are normalized value names, e.g. `"40"`, `"synthetic leather"`, `"7"`.
  ///
  /// **CRITICAL**: For each attribute, enabled values are computed by filtering variants
  /// that match **ALL OTHER selected attributes** (excluding the attribute being computed).
  /// This ensures that:
  /// - When SIZE=40 is selected, SIZE buttons still show all sizes available for the selected COLOR
  /// - When MATERIAL=Synthetic Leather is selected, MATERIAL buttons still show all materials available for COLOR+SIZE
  ///
  /// A value is considered **enabled** if there exists at least one in‑stock variant that:
  /// - Matches all OTHER selected attributes (excluding the attribute we're computing for)
  /// - Contains this attribute/value pair
  ///
  /// This is the safest way to decide which attribute buttons should be enabled
  /// after the user has already selected some combination of attributes.
  Map<String, Set<String>> getEnabledValuesForCurrentSelection() {
    final Map<String, Set<String>> enabled = {};

    if (variantCombinations.isEmpty) {
      return enabled;
    }

    String norm(String s) => s.toLowerCase().trim();

    // Get all unique attribute names from variantAttributeOptions
    final Set<String> allAttributeNames = {};
    for (final opt in variantAttributeOptions) {
      final attrKey = opt.apiAttributeName?.isNotEmpty == true 
          ? opt.apiAttributeName! 
          : opt.attributeName;
      allAttributeNames.add(attrKey);
    }

    // For each attribute type, compute enabled values by filtering variants that match
    // ALL OTHER selected attributes (excluding this attribute)
    for (final attributeName in allAttributeNames) {
      final normalizedAttrName = norm(attributeName);
      
      // Skip color attributes (they're handled separately via getEnabledAttributeValuesForColor)
      if (normalizedAttrName.contains('color') ||
          normalizedAttrName == 'colour' ||
          normalizedAttrName == 'اللون' ||
          normalizedAttrName == 'لون') {
        continue;
      }

      // Build selection map WITHOUT this attribute
      final Map<String, String> selectionWithoutThisAttr = {};
      final Map<String, String> selectionWithoutThisAttrByAttrId = {};
      
      // Add selectedColor if it's not the attribute we're computing for
      if (selectedColor.isNotEmpty) {
        final colorAttrNameLower = norm(attributeName);
        final isColorAttribute = colorAttrNameLower.contains('color') ||
            colorAttrNameLower == 'colour' ||
            colorAttrNameLower == 'اللون' ||
            colorAttrNameLower == 'لون';
        
        if (!isColorAttribute) {
          // Find color attribute name from variantAttributeOptions or use common names
          String? colorAttrName;
          for (final opt in variantAttributeOptions) {
            final optAttrName = opt.apiAttributeName?.isNotEmpty == true 
                ? opt.apiAttributeName! 
                : opt.attributeName;
            final optAttrNameLower = norm(optAttrName);
            if (optAttrNameLower.contains('color') ||
                optAttrNameLower == 'colour' ||
                optAttrNameLower == 'اللون') {
              colorAttrName = optAttrName;
              if (opt.attributeId != null && opt.attributeId!.trim().isNotEmpty) {
                selectionWithoutThisAttrByAttrId[opt.attributeId!.trim()] = selectedColor.trim();
              }
              break;
            }
          }
          // Fallback to common color attribute names
          colorAttrName ??= 'COLOR NAME';
          selectionWithoutThisAttr[colorAttrName] = selectedColor.trim();
        }
      }
      
      // Add selectedSize if it's not the attribute we're computing for
      if (selectedSize.isNotEmpty) {
        final sizeAttrNameLower = norm(attributeName);
        final isSizeAttribute = sizeAttrNameLower == 'size' ||
            sizeAttrNameLower == norm(primaryVariantLabel);
        
        if (!isSizeAttribute) {
          // Find size attribute name from variantAttributeOptions or use common names
          String? sizeAttrName;
          for (final opt in variantAttributeOptions) {
            final optAttrName = opt.apiAttributeName?.isNotEmpty == true 
                ? opt.apiAttributeName! 
                : opt.attributeName;
            final optAttrNameLower = norm(optAttrName);
            if (optAttrNameLower == 'size' ||
                optAttrNameLower == norm(primaryVariantLabel)) {
              sizeAttrName = optAttrName;
              if (opt.attributeId != null && opt.attributeId!.trim().isNotEmpty) {
                selectionWithoutThisAttrByAttrId[opt.attributeId!.trim()] = selectedSize.trim();
              }
              break;
            }
          }
          // Fallback to common size attribute names
          sizeAttrName ??= primaryVariantLabel.isNotEmpty ? primaryVariantLabel : 'SIZE';
          selectionWithoutThisAttr[sizeAttrName] = selectedSize.trim();
        }
      }
      
      // Add other selected attributes from variantAttributeOptions
      for (final opt in variantAttributeOptions) {
        if (opt.selectedValue.isEmpty) continue;
        
        final optAttrName = opt.apiAttributeName?.isNotEmpty == true 
            ? opt.apiAttributeName! 
            : opt.attributeName;
        
        // Skip this attribute
        if (norm(optAttrName) == normalizedAttrName) {
          continue;
        }
        
        // Skip if already added from selectedColor/selectedSize
        final optAttrNameLower = norm(optAttrName);
        final isColorAttr = optAttrNameLower.contains('color') ||
            optAttrNameLower == 'colour' ||
            optAttrNameLower == 'اللون';
        final isSizeAttr = optAttrNameLower == 'size' ||
            optAttrNameLower == norm(primaryVariantLabel);
        
        if (isColorAttr && selectedColor.isNotEmpty) continue;
        if (isSizeAttr && selectedSize.isNotEmpty) continue;
        
        // Add to selection map
        if (opt.attributeId != null && opt.attributeId!.trim().isNotEmpty) {
          selectionWithoutThisAttrByAttrId[opt.attributeId!.trim()] = opt.selectedValue.trim();
        }
        selectionWithoutThisAttr[optAttrName] = opt.selectedValue.trim();
      }

      // Filter variants that match all OTHER selected attributes and are in stock
      final compatibleVariants = variantCombinations.where((combo) {
        // Check stock first
        final double qty = combo.quantityAvailable ?? 0;
        if (!combo.inStock || qty <= 0) return false;

        // If no other attributes are selected, all variants are compatible
        if (selectionWithoutThisAttr.isEmpty && selectionWithoutThisAttrByAttrId.isEmpty) {
          return true;
        }

        // Try matching by attribute_id first (more reliable)
        if (selectionWithoutThisAttrByAttrId.isNotEmpty) {
          return combo.matchesAttributesByAttributeIdAndValueName(selectionWithoutThisAttrByAttrId);
        }
        
        // Fallback to attribute_name matching
        return combo.matchesAttributesByValueName(selectionWithoutThisAttr);
      }).toList();

      // Collect all values for this attribute from compatible variants
      final Set<String> enabledValues = {};
      for (final combo in compatibleVariants) {
        for (final attr in combo.attributes) {
          final attrName = attr.attributeName;
          final valueName = attr.valueName;
          if (attrName.isEmpty || valueName.isEmpty) continue;
          
          // Check if this attribute matches (flexible matching)
          final attrNameNormalized = norm(attrName);
          bool matches = false;
          
          // 1) Exact match
          if (attrNameNormalized == normalizedAttrName) {
            matches = true;
          }
          // 2) Check if attribute name contains the normalized name or vice versa
          else if (attrNameNormalized.contains(normalizedAttrName) ||
                   normalizedAttrName.contains(attrNameNormalized)) {
            matches = true;
          }
          // 3) Check against apiAttributeName from variantAttributeOptions
          else {
            for (final opt in variantAttributeOptions) {
              final optAttrName = opt.apiAttributeName?.isNotEmpty == true 
                  ? opt.apiAttributeName! 
                  : opt.attributeName;
              final optAttrNameNormalized = norm(optAttrName);
              
              // If the option's normalized name matches what we're looking for,
              // and the variant's attribute name matches the option's name
              if (optAttrNameNormalized == normalizedAttrName &&
                  (attrNameNormalized == optAttrNameNormalized ||
                   attrNameNormalized.contains(optAttrNameNormalized) ||
                   optAttrNameNormalized.contains(attrNameNormalized))) {
                matches = true;
                break;
              }
            }
          }
          
          // 4) Special handling for material attributes (MATERIALS, MATERIAL NAME, etc.)
          if (!matches && (normalizedAttrName.contains('material') || attrNameNormalized.contains('material'))) {
            matches = true;
          }
          
          // 5) Special handling for size attributes
          if (!matches && (normalizedAttrName == 'size' || attrNameNormalized == 'size')) {
            // Check if this is the primary variant label
            final primaryLabelNormalized = norm(primaryVariantLabel);
            if (attrNameNormalized == primaryLabelNormalized || 
                normalizedAttrName == primaryLabelNormalized) {
              matches = true;
            }
          }
          
          if (matches) {
            enabledValues.add(norm(valueName));
          }
        }
      }

      if (enabledValues.isNotEmpty) {
        enabled[normalizedAttrName] = enabledValues;
      }
    }

    return enabled;
  }

  /// Returns true when there exists at least one variant in [variantCombinations]
  /// that matches **both** the given [colorName] and the attribute/value pair
  /// ([attributeName] = [valueName]) and is actually available in stock
  /// (`inStock == true` and `quantityAvailable > 0`).
  ///
  /// This is used by the UI attribute section to decide whether a specific
  /// attribute button (size, material, height, etc.) should be enabled for the
  /// currently selected color.
  bool hasInStockVariantForColorAndAttributeValue({
    required String colorName,
    required String attributeName,
    required String valueName,
  }) {
    if (colorName.isEmpty || valueName.isEmpty) return false;

    String norm(String s) => s.toLowerCase().trim();
    final normalizedColor = norm(colorName);
    final normalizedValue = norm(valueName);

    // Common attribute names used by the backend for color.
    const colorAttrNames = [
      'COLOR NAME',
      'color name',
      'Color Name',
      'color',
      'Color',
      'COLOR',
      'colour',
      'Colour',
      'اللون',
      'لون',
    ];

    for (final combo in variantCombinations) {
      // 1) Match color using flexible comparison (handles minor naming
      // differences like "Black", "BLACK 01", Arabic display, etc.).
      String? variantColor;
      for (final attrName in colorAttrNames) {
        final v = combo.getAttributeValue(attrName);
        if (v != null && v.isNotEmpty) {
          variantColor = v;
          break;
        }
      }
      if (variantColor == null || variantColor.isEmpty) continue;

      final nVariantColor = norm(variantColor);
      final bool colorMatches =
          nVariantColor == normalizedColor ||
          nVariantColor.contains(normalizedColor) ||
          normalizedColor.contains(nVariantColor);
      if (!colorMatches) continue;

      // 2) Match the target attribute/value pair.
      final String? variantAttrValue =
          combo.getAttributeValue(attributeName);
      if (variantAttrValue == null || variantAttrValue.isEmpty) continue;

      if (norm(variantAttrValue) != normalizedValue) continue;

      // 3) Stock rule: only consider variants that are actually available.
      final double qty = combo.quantityAvailable ?? 0;
      final bool inStockAndPositiveQty = combo.inStock && qty > 0;
      if (!inStockAndPositiveQty) continue;

      // Found at least one matching, in‑stock variant.
      return true;
    }

    return false;
  }

  /// Returns true when there exists at least one variant in [variantCombinations]
  /// that matches the given [colorName] and is actually available in stock
  /// (`inStock == true` and `quantityAvailable > 0`).
  ///
  /// This is used to check if a color has ANY in-stock variants at all.
  /// If a color has no in-stock variants, all attribute buttons should be disabled.
  bool hasAnyInStockVariantForColor(String colorName) {
    if (colorName.isEmpty) return false;

    String norm(String s) => s.toLowerCase().trim();
    final normalizedColor = norm(colorName);

    // Common attribute names used by the backend for color.
    const colorAttrNames = [
      'COLOR NAME',
      'color name',
      'Color Name',
      'color',
      'Color',
      'COLOR',
      'colour',
      'Colour',
      'اللون',
      'لون',
    ];

    for (final combo in variantCombinations) {
      // Match color using flexible comparison (handles minor naming
      // differences like "Black", "BLACK 01", Arabic display, etc.).
      String? variantColor;
      for (final attrName in colorAttrNames) {
        final v = combo.getAttributeValue(attrName);
        if (v != null && v.isNotEmpty) {
          variantColor = v;
          break;
        }
      }
      if (variantColor == null || variantColor.isEmpty) continue;

      final nVariantColor = norm(variantColor);
      final bool colorMatches =
          nVariantColor == normalizedColor ||
          nVariantColor.contains(normalizedColor) ||
          normalizedColor.contains(nVariantColor);
      if (!colorMatches) continue;

      // Stock rule: only consider variants that are actually available.
      final double qty = combo.quantityAvailable ?? 0;
      final bool inStockAndPositiveQty = combo.inStock && qty > 0;
      if (!inStockAndPositiveQty) continue;

      // Found at least one in-stock variant for this color.
      return true;
    }

    return false;
  }

  /// Filters variants by the given [colorName] that have `inStock == true` and
  /// `quantityAvailable > 0`, then collects ALL attribute values from those variants.
  ///
  /// Returns a map where:
  /// - Key: attribute name (e.g., "SIZE", "MATERIAL NAME", "HEIGHT")
  /// - Value: Set of value names that are available for this color with stock
  ///
  /// This is used to determine which attribute buttons should be enabled
  /// and which values should be auto-selected for the selected color.
  Map<String, Set<String>> getEnabledAttributeValuesForColor(String colorName) {
    final Map<String, Set<String>> enabledAttributes = {};
    
    if (colorName.isEmpty || variantCombinations.isEmpty) {
      return enabledAttributes;
    }

    String norm(String s) => s.toLowerCase().trim();
    final normalizedColor = norm(colorName);

    // Common attribute names used by the backend for color.
    const colorAttrNames = [
      'COLOR NAME',
      'color name',
      'Color Name',
      'color',
      'Color',
      'COLOR',
      'colour',
      'Colour',
      'اللون',
      'لون',
    ];

    // Step 1: Filter variants that match color AND have stock
    final List<VariantCombination> matchingVariants = [];
    
    for (int i = 0; i < variantCombinations.length; i++) {
      final combo = variantCombinations[i];
      
      // Match color
      String? variantColor;
      for (final attrName in colorAttrNames) {
        final v = combo.getAttributeValue(attrName);
        if (v != null && v.isNotEmpty) {
          variantColor = v;
          break;
        }
      }
      
      if (variantColor == null || variantColor.isEmpty) {
        continue;
      }
      
      final nVariantColor = norm(variantColor);
      final bool colorMatches =
          nVariantColor == normalizedColor ||
          nVariantColor.contains(normalizedColor) ||
          normalizedColor.contains(nVariantColor);
      
      if (!colorMatches) {
        continue;
      }

      // Check stock conditions: inStock == true AND quantityAvailable > 0
      final double qty = combo.quantityAvailable ?? 0;
      final bool inStockAndPositiveQty = combo.inStock && qty > 0;
      
      if (!inStockAndPositiveQty) {
        continue;
      }

      matchingVariants.add(combo);
    }

    // Step 2: Collect all attribute values from matching variants
    for (int i = 0; i < matchingVariants.length; i++) {
      final combo = matchingVariants[i];
      
      for (final attr in combo.attributes) {
        final attrName = attr.attributeName;
        final attrValue = attr.valueName;
        
        // Skip color attributes
        final attrNameLower = attrName.toLowerCase();
        if (attrNameLower == 'color name' ||
            attrNameLower == 'color' ||
            attrNameLower == 'colour' ||
            attrNameLower == 'اللون' ||
            attrNameLower == 'لون') {
          continue;
        }

        if (attrValue.isEmpty) {
          continue;
        }

        // Add to enabled set for this attribute
        enabledAttributes.putIfAbsent(attrName, () => <String>{});
        enabledAttributes[attrName]!.add(attrValue);
      }
    }

    return enabledAttributes;
  }

  /// Returns the first matching variant for the given [colorName] that has
  /// `inStock == true` and `quantityAvailable > 0`, along with its stock info.
  /// This is used to update the stock badge based on the matched variant.
  VariantCombination? getFirstInStockVariantForColor(String colorName) {
    if (colorName.isEmpty || variantCombinations.isEmpty) {
      return null;
    }

    String norm(String s) => s.toLowerCase().trim();
    final normalizedColor = norm(colorName);

    // Common attribute names used by the backend for color.
    const colorAttrNames = [
      'COLOR NAME',
      'color name',
      'Color Name',
      'color',
      'Color',
      'COLOR',
      'colour',
      'Colour',
      'اللون',
      'لون',
    ];

    for (final combo in variantCombinations) {
      // Match color
      String? variantColor;
      for (final attrName in colorAttrNames) {
        final v = combo.getAttributeValue(attrName);
        if (v != null && v.isNotEmpty) {
          variantColor = v;
          break;
        }
      }
      if (variantColor == null || variantColor.isEmpty) continue;

      final nVariantColor = norm(variantColor);
      final bool colorMatches =
          nVariantColor == normalizedColor ||
          nVariantColor.contains(normalizedColor) ||
          normalizedColor.contains(nVariantColor);
      if (!colorMatches) continue;

      // Check stock conditions: inStock == true AND quantityAvailable > 0
      final double qty = combo.quantityAvailable ?? 0;
      final bool inStockAndPositiveQty = combo.inStock && qty > 0;
      if (!inStockAndPositiveQty) continue;

      // Found first matching variant with stock
      return combo;
    }

    return null;
  }

  /// Gets a map of all currently selected attribute values.
  /// Key: attribute name (or attribute_id if available), Value: selected value name.
  /// This is useful for debugging and displaying selected attributes.
  Map<String, String> getAllSelectedAttributes() {
    final Map<String, String> selected = {};
    
    for (final opt in variantAttributeOptions) {
      if (opt.selectedValue.isEmpty) continue;
      
      // Use attribute_id as key if available, otherwise use attribute name
      final key = opt.attributeId?.isNotEmpty == true 
          ? opt.attributeId! 
          : (opt.apiAttributeName?.isNotEmpty == true ? opt.apiAttributeName! : opt.attributeName);
      
      selected[key] = opt.selectedValue;
    }
    
    return selected;
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
  final String brand;
  final double price;
  final String imageUrl;
  final String type; // 'template' or 'variant'

  const RelatedProduct({
    required this.id,
    required this.name,
    this.brand = '',
    required this.price,
    required this.imageUrl,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, brand, price, imageUrl, type];
}

class VariantCombination extends Equatable {
  final String variantId;
  final bool inStock;
  final List<VariantAttribute> attributes;
  final double? quantityAvailable;
  final double? price; // Variant-specific price

  const VariantCombination({
    required this.variantId,
    required this.inStock,
    required this.attributes,
    this.quantityAvailable,
    this.price,
  });

  @override
  List<Object?> get props => [variantId, inStock, attributes, quantityAvailable, price];

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
