import 'package:equatable/equatable.dart';

class SubcategoryDetails extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String parentCategoryId;
  final List<SubcategoryItem> items;
  final List<SubcategorySection> sections;

  const SubcategoryDetails({
    required this.id,
    required this.title,
    this.description,
    required this.parentCategoryId,
    this.items = const [],
    this.sections = const [],
  });

  @override
  List<Object?> get props => [id, title, description, parentCategoryId, items, sections];
}

class SubcategoryItem extends Equatable {
  final String id;
  final String title;
  final String iconName;
  final String? description;
  final bool hasChildren;
  final int sortOrder;

  const SubcategoryItem({
    required this.id,
    required this.title,
    required this.iconName,
    this.description,
    this.hasChildren = false,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, title, iconName, description, hasChildren, sortOrder];
}

class SubcategorySection extends Equatable {
  final String id;
  final String title;
  final List<SubcategoryItem> items;
  final int sortOrder;

  const SubcategorySection({
    required this.id,
    required this.title,
    required this.items,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, title, items, sortOrder];
}
