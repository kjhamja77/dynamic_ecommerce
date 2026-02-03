import 'package:equatable/equatable.dart';

class FilterAttribute extends Equatable {
  final int id;
  final String name;
  final String type;
  final List<FilterAttributeValue> values;
  final bool isRequired;
  final bool isVisible;

  const FilterAttribute({
    required this.id,
    required this.name,
    required this.type,
    this.values = const [],
    this.isRequired = false,
    this.isVisible = true,
  });

  factory FilterAttribute.fromJson(Map<String, dynamic> json) {
    return FilterAttribute(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'text',
      values: (json['values'] as List<dynamic>?)
          ?.map((value) => FilterAttributeValue.fromJson(value as Map<String, dynamic>))
          .toList() ?? [],
      isRequired: json['is_required'] ?? false,
      isVisible: json['is_visible'] ?? true,
    );
  }

  // Factory method to parse API response structure
  factory FilterAttribute.fromApiResponse(Map<String, dynamic> json) {
    return FilterAttribute(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'text',
      values: (json['values'] as List<dynamic>?)
          ?.map((value) => FilterAttributeValue.fromApiResponse(value as Map<String, dynamic>))
          .toList() ?? [],
      isRequired: json['is_required'] ?? false,
      isVisible: json['is_visible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'values': values.map((value) => value.toJson()).toList(),
      'is_required': isRequired,
      'is_visible': isVisible,
    };
  }

  @override
  List<Object?> get props => [id, name, type, values, isRequired, isVisible];
}

class FilterAttributeValue extends Equatable {
  final int id;
  final String name;
  final String value;
  final int productCount;
  final bool isActive;

  const FilterAttributeValue({
    required this.id,
    required this.name,
    required this.value,
    this.productCount = 0,
    this.isActive = true,
  });

  factory FilterAttributeValue.fromJson(Map<String, dynamic> json) {
    return FilterAttributeValue(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      productCount: json['product_count'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  // Factory method to parse API response structure
  factory FilterAttributeValue.fromApiResponse(Map<String, dynamic> json) {
    return FilterAttributeValue(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      value: json['value'] ?? json['name'] ?? '', // Use name as value if value is not provided
      productCount: json['product_count'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'product_count': productCount,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [id, name, value, productCount, isActive];
}
