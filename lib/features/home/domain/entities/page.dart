import 'package:equatable/equatable.dart';

class Page extends Equatable {
  final int id;
  final String name;
  final String? title;
  final String? description;
  final String? icon;
  final int? order;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Page({
    required this.id,
    required this.name,
    this.title,
    this.description,
    this.icon,
    this.order,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        description,
        icon,
        order,
        isActive,
        createdAt,
        updatedAt,
      ];
}
