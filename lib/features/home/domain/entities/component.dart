import 'package:equatable/equatable.dart';

class Component extends Equatable {
  final int componentId;
  final String name;
  final String valueType;
  final String type;
  final String description;
  final String layoutDesign;
  final int sequence;
  final List<String> tags;
  final bool hasImage;
  final List<ComponentChild> children;

  const Component({
    required this.componentId,
    required this.name,
    required this.valueType,
    required this.type,
    required this.description,
    required this.layoutDesign,
    required this.sequence,
    required this.tags,
    required this.hasImage,
    required this.children,
  });

  @override
  List<Object?> get props => [
        componentId,
        name,
        valueType,
        type,
        description,
        layoutDesign,
        sequence,
        tags,
        hasImage,
        children,
      ];
}

class ComponentChild extends Equatable {
  final int componentId;
  final String name;
  final String valueType;
  final Map<String, dynamic> content;
  /// Optional product count when this child represents a category_content item.
  final int? productCount;

  const ComponentChild({
    required this.componentId,
    required this.name,
    required this.valueType,
    required this.content,
    this.productCount,
  });

  @override
  List<Object?> get props => [componentId, name, valueType, content, productCount];
}

class PageComponents extends Equatable {
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
  final List<Component> pageComponents;

  const PageComponents({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
    required this.pageComponents,
  });

  @override
  List<Object?> get props => [
        totalCount,
        page,
        pageSize,
        totalPages,
        hasNext,
        hasPrev,
        pageComponents,
      ];
}
