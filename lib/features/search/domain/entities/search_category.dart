import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product_category.dart';

class SearchCategory extends Equatable {
  final String id;
  final String title;
  final String iconName;
  final String colorHex;
  final int sortOrder;
  final bool isActive;
  final List<SearchCategory> children;
  final int productCount;
  final bool hasChildren;
  final String? image;

  const SearchCategory({
    required this.id,
    required this.title,
    required this.iconName,
    required this.colorHex,
    required this.sortOrder,
    this.isActive = true,
    this.children = const [],
    this.productCount = 0,
    this.hasChildren = false,
    this.image,
  });

  // Factory constructor to create SearchCategory from ProductCategory
  factory SearchCategory.fromProductCategory(ProductCategory productCategory) {
    return SearchCategory(
      id: productCategory.id.toString(),
      title: productCategory.name,
      iconName: _getDefaultIconForCategory(productCategory.name),
      colorHex: _getDefaultColorForCategory(productCategory.name),
      sortOrder: productCategory.sequence,
      isActive: true,
      children: productCategory.children
          .map((child) => SearchCategory.fromProductCategory(child))
          .toList(),
      productCount: productCategory.productCount,
      hasChildren: productCategory.hasChildren || productCategory.children.isNotEmpty,
      image: productCategory.image,
    );
  }

  // Helper method to get default icon for category
  static String _getDefaultIconForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('desk')) return 'desk';
    if (name.contains('furniture')) return 'chair';
    if (name.contains('box')) return 'inventory';
    if (name.contains('drawer')) return 'folder';
    if (name.contains('cabinet')) return 'storage';
    if (name.contains('bin')) return 'delete';
    if (name.contains('lamp')) return 'lightbulb';
    if (name.contains('service')) return 'build';
    if (name.contains('multimedia')) return 'video_library';
    return 'category'; // default icon
  }

  // Helper method to get default color for category
  static String _getDefaultColorForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('desk')) return '#FF9800'; // Orange
    if (name.contains('furniture')) return '#4CAF50'; // Green
    if (name.contains('box')) return '#2196F3'; // Blue
    if (name.contains('drawer')) return '#9C27B0'; // Purple
    if (name.contains('cabinet')) return '#795548'; // Brown
    if (name.contains('bin')) return '#607D8B'; // Blue Grey
    if (name.contains('lamp')) return '#FFC107'; // Amber
    if (name.contains('service')) return '#E91E63'; // Pink
    if (name.contains('multimedia')) return '#3F51B5'; // Indigo
    return '#757575'; // default grey
  }

  @override
  List<Object?> get props => [id, title, iconName, colorHex, sortOrder, isActive, children, productCount, hasChildren, image];
}
