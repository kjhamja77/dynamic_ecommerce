import '../../domain/entities/banner.dart';

/// Banner data model with JSON serialization
class BannerModel extends Banner {
  const BannerModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    super.actionUrl,
    super.actionText,
    super.isActive,
    super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create BannerModel from JSON
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      actionUrl: json['actionUrl'] as String?,
      actionText: json['actionText'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert BannerModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'actionText': actionText,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create BannerModel from Banner entity
  factory BannerModel.fromEntity(Banner banner) {
    return BannerModel(
      id: banner.id,
      title: banner.title,
      description: banner.description,
      imageUrl: banner.imageUrl,
      actionUrl: banner.actionUrl,
      actionText: banner.actionText,
      isActive: banner.isActive,
      sortOrder: banner.sortOrder,
      createdAt: banner.createdAt,
      updatedAt: banner.updatedAt,
    );
  }
}
