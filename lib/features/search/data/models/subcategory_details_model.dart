import '../../domain/entities/subcategory_details.dart';

class SubcategoryDetailsModel extends SubcategoryDetails {
  const SubcategoryDetailsModel({
    required super.id,
    required super.title,
    super.description,
    required super.parentCategoryId,
    super.items,
    super.sections,
  });

  factory SubcategoryDetailsModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryDetailsModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      parentCategoryId: json['parentCategoryId'] as String,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => SubcategoryItemModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      sections: (json['sections'] as List<dynamic>?)
          ?.map((section) => SubcategorySectionModel.fromJson(section as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'parentCategoryId': parentCategoryId,
      'items': items.map((item) => (item as SubcategoryItemModel).toJson()).toList(),
      'sections': sections.map((section) => (section as SubcategorySectionModel).toJson()).toList(),
    };
  }
}

class SubcategoryItemModel extends SubcategoryItem {
  const SubcategoryItemModel({
    required super.id,
    required super.title,
    required super.iconName,
    super.description,
    super.hasChildren,
    required super.sortOrder,
  });

  factory SubcategoryItemModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      iconName: json['iconName'] as String,
      description: json['description'] as String?,
      hasChildren: json['hasChildren'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconName': iconName,
      'description': description,
      'hasChildren': hasChildren,
      'sortOrder': sortOrder,
    };
  }
}

class SubcategorySectionModel extends SubcategorySection {
  const SubcategorySectionModel({
    required super.id,
    required super.title,
    required super.items,
    required super.sortOrder,
  });

  factory SubcategorySectionModel.fromJson(Map<String, dynamic> json) {
    return SubcategorySectionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => SubcategoryItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      sortOrder: json['sortOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'items': items.map((item) => (item as SubcategoryItemModel).toJson()).toList(),
      'sortOrder': sortOrder,
    };
  }
}
