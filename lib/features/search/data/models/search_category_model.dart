import '../../domain/entities/search_category.dart';

class SearchCategoryModel extends SearchCategory {
  const SearchCategoryModel({
    required super.id,
    required super.title,
    required super.iconName,
    required super.colorHex,
    required super.sortOrder,
    super.isActive,
  });

  factory SearchCategoryModel.fromJson(Map<String, dynamic> json) {
    return SearchCategoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      iconName: json['iconName'] as String,
      colorHex: json['colorHex'] as String,
      sortOrder: json['sortOrder'] as int,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconName': iconName,
      'colorHex': colorHex,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }
}
