import '../../domain/entities/page.dart';

class PageModel extends Page {
  const PageModel({
    required super.id,
    required super.name,
    super.title,
    super.description,
    super.icon,
    super.order,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['id'] as int? ?? 0,
      name: _safeStringCast(json['name']),
      title: _safeStringCast(json['name']), // Use name as title since API doesn't provide separate title
      description: _safeStringCast(json['description']).isNotEmpty 
          ? _safeStringCast(json['description'])
          : null,
      icon: null, // API doesn't provide icon
      order: json['sequence'] as int?, // Use sequence from API response for ordering
      isActive: true, // Assume active if returned
      createdAt: null, // API doesn't provide timestamps
      updatedAt: null,
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
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'icon': icon,
      'order': order,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
