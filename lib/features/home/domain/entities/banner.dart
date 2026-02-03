import 'package:equatable/equatable.dart';

/// Banner entity for home screen carousel
class Banner extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? actionUrl;
  final String? actionText;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Banner({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.actionUrl,
    this.actionText,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        actionUrl,
        actionText,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}
