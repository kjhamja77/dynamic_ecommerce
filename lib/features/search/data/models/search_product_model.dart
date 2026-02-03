import 'package:equatable/equatable.dart';

class SearchProductModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final String shortDescription;
  final String sku;
  final double price;
  final String currency;
  final double qtyAvailable;
  final double weight;
  final double volume;
  final List<SearchProductImage> images;
  final List<SearchProductAttribute> attributes;
  final List<SearchProductCategory> categories;
  final List<SearchProductAttributeGroup> productAttributes;
  final bool isPublished;
  final String createDate;
  final String writeDate;
  final String brand;
  final SearchProductTemplate productTemplate;

  const SearchProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.sku,
    required this.price,
    required this.currency,
    required this.qtyAvailable,
    required this.weight,
    required this.volume,
    required this.images,
    required this.attributes,
    required this.categories,
    required this.productAttributes,
    required this.isPublished,
    required this.createDate,
    required this.writeDate,
    required this.brand,
    required this.productTemplate,
  });

  factory SearchProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return SearchProductModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        shortDescription: json['short_description'] ?? '',
        sku: json['sku'] ?? '',
        price: (json['price'] ?? 0.0).toDouble(),
        currency: json['currency'] ?? '',
        qtyAvailable: (json['qty_available'] ?? 0.0).toDouble(),
        weight: (json['weight'] ?? 0.0).toDouble(),
        volume: (json['volume'] ?? 0.0).toDouble(),
        images: (json['images'] as List<dynamic>?)
            ?.map((img) => SearchProductImage.fromJson(img))
            .toList() ?? [],
        attributes: (json['attributes'] as List<dynamic>?)
            ?.map((attr) => SearchProductAttribute.fromJson(attr))
            .toList() ?? [],
        categories: (json['categories'] as List<dynamic>?)
            ?.map((cat) => SearchProductCategory.fromJson(cat))
            .toList() ?? [],
        productAttributes: (json['product_attributes'] as List<dynamic>?)
            ?.map((attr) => SearchProductAttributeGroup.fromJson(attr))
            .toList() ?? [],
        isPublished: json['is_published'] ?? false,
        createDate: json['create_date'] ?? '',
        writeDate: json['write_date'] ?? '',
        brand: json['brand'] ?? '',
        productTemplate: SearchProductTemplate.fromJson(json['product_template'] ?? {}),
      );
    } catch (e) {
      print('SearchProductModel.fromJson - Error parsing product: $e');
      print('SearchProductModel.fromJson - Product JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'short_description': shortDescription,
      'sku': sku,
      'price': price,
      'currency': currency,
      'qty_available': qtyAvailable,
      'weight': weight,
      'volume': volume,
      'images': images.map((img) => img.toJson()).toList(),
      'attributes': attributes.map((attr) => attr.toJson()).toList(),
      'categories': categories.map((cat) => cat.toJson()).toList(),
      'product_attributes': productAttributes.map((attr) => attr.toJson()).toList(),
      'is_published': isPublished,
      'create_date': createDate,
      'write_date': writeDate,
      'brand': brand,
      'product_template': productTemplate.toJson(),
    };
  }

  // Helper methods for easier access
  String get primaryImageUrl {
    if (images.isEmpty) return '';
    return images.first.image;
  }

  String get primaryCategoryName {
    if (categories.isEmpty) return '';
    return categories.first.name;
  }

  List<String> get availableColors {
    return attributes
        .where((attr) => attr.attributeName.toLowerCase().contains('color'))
        .map((attr) => attr.valueName)
        .toList();
  }

  List<String> get availableSizes {
    return attributes
        .where((attr) => attr.attributeName.toLowerCase().contains('size'))
        .map((attr) => attr.valueName)
        .toList();
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        shortDescription,
        sku,
        price,
        currency,
        qtyAvailable,
        weight,
        volume,
        images,
        attributes,
        categories,
        productAttributes,
        isPublished,
        createDate,
        writeDate,
        brand,
        productTemplate,
      ];
}

class SearchProductImage extends Equatable {
  final int id;
  final String image;
  final String alt;

  const SearchProductImage({
    required this.id,
    required this.image,
    required this.alt,
  });

  factory SearchProductImage.fromJson(Map<String, dynamic> json) {
    try {
      return SearchProductImage(
        id: json['id'] ?? 0,
        image: json['image'] ?? '',
        alt: json['alt'] ?? '',
      );
    } catch (e) {
      print('SearchProductImage.fromJson - Error parsing image: $e');
      print('SearchProductImage.fromJson - Image JSON: $json');
      // Return default image instead of failing
      return const SearchProductImage(
        id: 0,
        image: '',
        alt: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'alt': alt,
    };
  }

  @override
  List<Object?> get props => [id, image, alt];
}

class SearchProductAttribute extends Equatable {
  final int attributeId;
  final String attributeName;
  final int valueId;
  final String valueName;

  const SearchProductAttribute({
    required this.attributeId,
    required this.attributeName,
    required this.valueId,
    required this.valueName,
  });

  factory SearchProductAttribute.fromJson(Map<String, dynamic> json) {
    return SearchProductAttribute(
      attributeId: json['attribute_id'] ?? 0,
      attributeName: json['attribute_name'] ?? '',
      valueId: json['value_id'] ?? 0,
      valueName: json['value_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attribute_id': attributeId,
      'attribute_name': attributeName,
      'value_id': valueId,
      'value_name': valueName,
    };
  }

  @override
  List<Object?> get props => [attributeId, attributeName, valueId, valueName];
}

class SearchProductCategory extends Equatable {
  final int id;
  final String name;

  const SearchProductCategory({
    required this.id,
    required this.name,
  });

  factory SearchProductCategory.fromJson(Map<String, dynamic> json) {
    return SearchProductCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}

class SearchProductAttributeGroup extends Equatable {
  final int id;
  final String name;
  final List<SearchProductAttributeValue> values;

  const SearchProductAttributeGroup({
    required this.id,
    required this.name,
    required this.values,
  });

  factory SearchProductAttributeGroup.fromJson(Map<String, dynamic> json) {
    return SearchProductAttributeGroup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      values: (json['values'] as List<dynamic>?)
          ?.map((val) => SearchProductAttributeValue.fromJson(val))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'values': values.map((val) => val.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, name, values];
}

class SearchProductAttributeValue extends Equatable {
  final int id;
  final String name;

  const SearchProductAttributeValue({
    required this.id,
    required this.name,
  });

  factory SearchProductAttributeValue.fromJson(Map<String, dynamic> json) {
    return SearchProductAttributeValue(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}

class SearchProductTemplate extends Equatable {
  final int id;
  final String name;
  final bool hasVariants;

  const SearchProductTemplate({
    required this.id,
    required this.name,
    required this.hasVariants,
  });

  factory SearchProductTemplate.fromJson(Map<String, dynamic> json) {
    try {
      return SearchProductTemplate(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        hasVariants: json['has_variants'] ?? false,
      );
    } catch (e) {
      print('SearchProductTemplate.fromJson - Error parsing template: $e');
      print('SearchProductTemplate.fromJson - Template JSON: $json');
      // Return default template instead of failing
      return const SearchProductTemplate(
        id: 0,
        name: '',
        hasVariants: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'has_variants': hasVariants,
    };
  }

  @override
  List<Object?> get props => [id, name, hasVariants];
}
