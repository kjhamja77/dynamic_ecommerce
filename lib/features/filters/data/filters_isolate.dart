import 'package:flutter/foundation.dart';

import '../domain/entities/filter_options.dart';
import '../domain/entities/filter_category.dart';
import '../domain/entities/filter_brand.dart';
import '../domain/entities/filter_attribute.dart';

class _FilterOptionsIsolatePayload {
  final FilterOptions? baseOptions;
  final List<FilterCategory> categories;
  final List<FilterBrand> brands;
  final List<FilterAttribute> attributes;

  const _FilterOptionsIsolatePayload({
    required this.baseOptions,
    required this.categories,
    required this.brands,
    required this.attributes,
  });
}

Future<FilterOptions> buildFilterOptionsInBackground({
  required FilterOptions? baseOptions,
  required List<FilterCategory> categories,
  required List<FilterBrand> brands,
  required List<FilterAttribute> attributes,
}) {
  return compute<_FilterOptionsIsolatePayload, FilterOptions>(
    _buildFilterOptions,
    _FilterOptionsIsolatePayload(
      baseOptions: baseOptions,
      categories: categories,
      brands: brands,
      attributes: attributes,
    ),
  );
}

FilterOptions _buildFilterOptions(_FilterOptionsIsolatePayload payload) {
  final filterOptionsData = payload.baseOptions;

  final priceRange = filterOptionsData?.priceRange ??
      const FilterPriceRange(minPrice: 0, maxPrice: 1000, currency: 'IQD');
  final sortingOptions = filterOptionsData?.sortingOptions ?? [];

  final availableSizes = <String>[];
  final availableColors = <String>[];
  final availableMaterials = <String>[];
  final availableSeasons = <String>[];
  final availableGenders = <String>[];

  for (final attr in payload.attributes) {
    final attrName = attr.name.toLowerCase();
    final values = attr.values.map((v) => v.name).toList();

    if (attrName.contains('size')) {
      availableSizes.addAll(values);
    } else if (attrName.contains('color')) {
      availableColors.addAll(values);
    } else if (attrName.contains('material')) {
      availableMaterials.addAll(values);
    } else if (attrName.contains('season')) {
      availableSeasons.addAll(values);
    } else if (attrName.contains('gender')) {
      availableGenders.addAll(values);
    }
  }

  return FilterOptions.withLoadedData(
    categories: payload.categories,
    brands: payload.brands,
    attributes: payload.attributes,
    priceRange: priceRange,
    availableSizes: availableSizes,
    availableColors: availableColors,
    availableMaterials: availableMaterials,
    availableSeasons: availableSeasons,
    availableGenders: availableGenders,
    sortingOptions: sortingOptions,
  );
}

