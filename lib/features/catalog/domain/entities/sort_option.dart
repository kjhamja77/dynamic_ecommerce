import 'package:equatable/equatable.dart';

class SortOption extends Equatable {
  final String value;
  final String label;
  final String subtitle;
  final SortType type;

  const SortOption({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.type,
  });

  @override
  List<Object?> get props => [value, label, subtitle, type];

  @override
  String toString() => 'SortOption(value: $value, label: $label, type: $type)';
}

enum SortType {
  priceLowToHigh,
  priceHighToLow,
  newest,
  featured,
  rating,
  popularity,
}

extension SortTypeExtension on SortType {
  String get apiValue {
    switch (this) {
      case SortType.priceLowToHigh:
        return 'price_asc';
      case SortType.priceHighToLow:
        return 'price_desc';
      case SortType.newest:
        return 'newest';
      case SortType.featured:
        return 'featured';
      case SortType.rating:
        return 'rating';
      case SortType.popularity:
        return 'popularity';
    }
  }
}
