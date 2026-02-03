import 'package:equatable/equatable.dart';
import 'filter_category.dart';
import 'filter_brand.dart';
import 'filter_attribute.dart';
import 'filter_sort_option.dart';

class FilterOptions extends Equatable {
  final List<FilterCategory> categories;
  final List<FilterBrand> brands;
  final List<FilterAttribute> attributes;
  final FilterPriceRange? priceRange;
  final List<String> availableSizes;
  final List<String> availableColors;
  final List<String> availableMaterials;
  final List<String> availableSeasons;
  final List<String> availableGenders;
  final List<FilterSortOption> sortingOptions;

  const FilterOptions({
    this.categories = const [],
    this.brands = const [],
    this.attributes = const [],
    this.priceRange,
    this.availableSizes = const [],
    this.availableColors = const [],
    this.availableMaterials = const [],
    this.availableSeasons = const [],
    this.availableGenders = const [],
    this.sortingOptions = const [],
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      categories: (json['categories'] as List<dynamic>?)
          ?.map((cat) => FilterCategory.fromJson(cat as Map<String, dynamic>))
          .toList() ?? [],
      brands: (json['brands'] as List<dynamic>?)
          ?.map((brand) => FilterBrand.fromJson(brand as Map<String, dynamic>))
          .toList() ?? [],
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((attr) => FilterAttribute.fromJson(attr as Map<String, dynamic>))
          .toList() ?? [],
      priceRange: json['price_range'] != null 
          ? FilterPriceRange.fromJson(json['price_range'] as Map<String, dynamic>)
          : null,
      availableSizes: (json['available_sizes'] as List<dynamic>?)?.cast<String>() ?? [],
      availableColors: (json['available_colors'] as List<dynamic>?)?.cast<String>() ?? [],
      availableMaterials: (json['available_materials'] as List<dynamic>?)?.cast<String>() ?? [],
      availableSeasons: (json['available_seasons'] as List<dynamic>?)?.cast<String>() ?? [],
      availableGenders: (json['available_genders'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  // Factory method to parse API response structure
  factory FilterOptions.fromApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    // Parse sorting options from API
    final sortingOptions = (data['sorting_options'] as List<dynamic>?)
        ?.map((option) => FilterSortOption.fromJson(option as Map<String, dynamic>))
        .toList() ?? [];
    
    return FilterOptions(
      categories: [], // Will be loaded separately from categories API
      brands: [], // Will be loaded separately from brands API
      attributes: [], // Will be loaded separately from attributes API
      priceRange: data['price_range'] != null 
          ? FilterPriceRange.fromApiJson(data['price_range'] as Map<String, dynamic>)
          : const FilterPriceRange(minPrice: 0, maxPrice: 1000),
      availableSizes: (data['available_sizes'] as List<dynamic>?)?.cast<String>() ?? [],
      availableColors: (data['available_colors'] as List<dynamic>?)?.cast<String>() ?? [],
      availableMaterials: (data['available_materials'] as List<dynamic>?)?.cast<String>() ?? [],
      availableSeasons: (data['available_seasons'] as List<dynamic>?)?.cast<String>() ?? [],
      availableGenders: (data['available_genders'] as List<dynamic>?)?.cast<String>() ?? [],
      sortingOptions: sortingOptions,
    );
  }

  // Factory method to create FilterOptions with loaded data
  factory FilterOptions.withLoadedData({
    required FilterPriceRange priceRange,
    List<FilterCategory> categories = const [],
    List<FilterBrand> brands = const [],
    List<FilterAttribute> attributes = const [],
    List<String> availableSizes = const [],
    List<String> availableColors = const [],
    List<String> availableMaterials = const [],
    List<String> availableSeasons = const [],
    List<String> availableGenders = const [],
    List<FilterSortOption> sortingOptions = const [],
  }) {
    return FilterOptions(
      categories: categories,
      brands: brands,
      attributes: attributes,
      priceRange: priceRange,
      availableSizes: availableSizes,
      availableColors: availableColors,
      availableMaterials: availableMaterials,
      availableSeasons: availableSeasons,
      availableGenders: availableGenders,
      sortingOptions: sortingOptions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((cat) => cat.toJson()).toList(),
      'brands': brands.map((brand) => brand.toJson()).toList(),
      'attributes': attributes.map((attr) => attr.toJson()).toList(),
      'price_range': priceRange?.toJson(),
      'available_sizes': availableSizes,
      'available_colors': availableColors,
      'available_materials': availableMaterials,
      'available_seasons': availableSeasons,
      'available_genders': availableGenders,
    };
  }

  @override
  List<Object?> get props => [
        categories,
        brands,
        attributes,
        priceRange,
        availableSizes,
        availableColors,
        availableMaterials,
        availableSeasons,
        availableGenders,
        sortingOptions,
      ];
}

class FilterPriceRange extends Equatable {
  final double minPrice;
  final double maxPrice;
  final String currency;

  const FilterPriceRange({
    required this.minPrice,
    required this.maxPrice,
    this.currency = 'IQD',
  });

  factory FilterPriceRange.fromJson(Map<String, dynamic> json) {
    return FilterPriceRange(
      minPrice: (json['min_price'] ?? 0.0).toDouble(),
      maxPrice: (json['max_price'] ?? 1000.0).toDouble(),
      currency: json['currency'] ?? 'IQD',
    );
  }

  // Factory method to parse API response structure (min/max instead of min_price/max_price)
  factory FilterPriceRange.fromApiJson(Map<String, dynamic> json) {
    return FilterPriceRange(
      minPrice: (json['min'] ?? 0.0).toDouble(),
      maxPrice: (json['max'] ?? 1000.0).toDouble(),
      currency: json['currency'] ?? 'IQD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_price': minPrice,
      'max_price': maxPrice,
      'currency': currency,
    };
  }

  @override
  List<Object?> get props => [minPrice, maxPrice, currency];
}


