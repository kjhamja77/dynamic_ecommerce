import 'package:equatable/equatable.dart';

class FilterSortOption extends Equatable {
  final String id;
  final String name;
  final String field; // e.g., 'list_price', 'create_date', 'name', 'sales_count'
  final String order; // 'asc' or 'desc'

  const FilterSortOption({
    required this.id,
    required this.name,
    required this.field,
    required this.order,
  });

  factory FilterSortOption.fromJson(Map<String, dynamic> json) {
    return FilterSortOption(
      id: json['id'] as String,
      name: json['name'] as String,
      field: json['field'] as String,
      order: json['order'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'field': field,
      'order': order,
    };
  }

  @override
  List<Object?> get props => [id, name, field, order];
}






