import '../../domain/entities/component.dart';

class ComponentModel extends Component {
  const ComponentModel({
    required super.componentId,
    required super.name,
    required super.valueType,
    required super.type,
    required super.description,
    required super.layoutDesign,
    required super.sequence,
    required super.tags,
    required super.hasImage,
    required super.children,
  });

  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    return ComponentModel(
      componentId: json['component_id'] as int? ?? 0,
      name: _safeStringCast(json['name']),
      valueType: _safeStringCast(json['value_type']),
      type: _safeStringCast(json['type']),
      description: _safeStringCast(json['description']),
      layoutDesign: _safeStringCast(json['layout_design']),
      sequence: json['sequence'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      hasImage: json['has_image'] as bool? ?? false,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => ComponentChildModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Safely cast a value to String, handling bool and null cases
  static String _safeStringCast(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is bool) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'component_id': componentId,
      'name': name,
      'value_type': valueType,
      'type': type,
      'description': description,
      'layout_design': layoutDesign,
      'sequence': sequence,
      'tags': tags,
      'has_image': hasImage,
      'children': children.map((e) => (e as ComponentChildModel).toJson()).toList(),
    };
  }
}

class ComponentChildModel extends ComponentChild {
  const ComponentChildModel({
    required super.componentId,
    required super.name,
    required super.valueType,
    required super.content,
  });

  factory ComponentChildModel.fromJson(Map<String, dynamic> json) {
    return ComponentChildModel(
      componentId: json['component_id'] as int? ?? 0,
      name: _safeStringCast(json['name']),
      valueType: _safeStringCast(json['value_type']),
      content: json['content'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Safely cast a value to String, handling bool and null cases
  static String _safeStringCast(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is bool) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'component_id': componentId,
      'name': name,
      'value_type': valueType,
      'content': content,
    };
  }
}

class PageComponentsModel extends PageComponents {
  const PageComponentsModel({
    required super.totalCount,
    required super.page,
    required super.pageSize,
    required super.totalPages,
    required super.hasNext,
    required super.hasPrev,
    required super.pageComponents,
  });

  factory PageComponentsModel.fromJson(Map<String, dynamic> json) {
    return PageComponentsModel(
      totalCount: json['total_count'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 10,
      totalPages: json['total_pages'] as int? ?? 1,
      hasNext: json['has_next'] as bool? ?? false,
      hasPrev: json['has_prev'] as bool? ?? false,
      pageComponents: (json['page_component'] as List<dynamic>?)
              ?.map((e) => ComponentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'page': page,
      'page_size': pageSize,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_prev': hasPrev,
      'page_component': pageComponents.map((e) => (e as ComponentModel).toJson()).toList(),
    };
  }
}
