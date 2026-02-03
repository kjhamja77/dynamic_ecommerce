import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/filters/domain/entities/filter_criteria.dart';

void main() {
  group('FilterCriteria', () {
    test('should create FilterCriteria with default values', () {
      // Arrange & Act
      const criteria = FilterCriteria();

      // Assert
      expect(criteria.minPrice, isNull);
      expect(criteria.maxPrice, isNull);
      expect(criteria.minRating, isNull);
      expect(criteria.onSale, false);
      expect(criteria.inStock, false);
      expect(criteria.sizes, isEmpty);
      expect(criteria.colors, isEmpty);
      expect(criteria.materials, isEmpty);
      expect(criteria.seasons, isEmpty);
      expect(criteria.genders, isEmpty);
      expect(criteria.brand, isNull);
      expect(criteria.category, isNull);
      expect(criteria.categoryIds, isEmpty);
      expect(criteria.brandIds, isEmpty);
      expect(criteria.attributeIds, isEmpty);
      expect(criteria.searchQuery, isNull);
      expect(criteria.page, 1);
      expect(criteria.limit, 20);
    });

    test('should create FilterCriteria with custom values', () {
      // Arrange & Act
      const criteria = FilterCriteria(
        minPrice: 10.0,
        maxPrice: 100.0,
        minRating: 4.0,
        onSale: true,
        inStock: true,
        sizes: ['S', 'M', 'L'],
        colors: ['Red', 'Blue'],
        materials: ['Cotton'],
        seasons: ['Summer'],
        genders: ['Men'],
        brand: 'Nike',
        category: 'Shoes',
        categoryIds: [1, 2],
        brandIds: [3, 4],
        attributeIds: [5, 6],
        searchQuery: 'running shoes',
        page: 2,
        limit: 50,
      );

      // Assert
      expect(criteria.minPrice, 10.0);
      expect(criteria.maxPrice, 100.0);
      expect(criteria.minRating, 4.0);
      expect(criteria.onSale, true);
      expect(criteria.inStock, true);
      expect(criteria.sizes, ['S', 'M', 'L']);
      expect(criteria.colors, ['Red', 'Blue']);
      expect(criteria.materials, ['Cotton']);
      expect(criteria.seasons, ['Summer']);
      expect(criteria.genders, ['Men']);
      expect(criteria.brand, 'Nike');
      expect(criteria.category, 'Shoes');
      expect(criteria.categoryIds, [1, 2]);
      expect(criteria.brandIds, [3, 4]);
      expect(criteria.attributeIds, [5, 6]);
      expect(criteria.searchQuery, 'running shoes');
      expect(criteria.page, 2);
      expect(criteria.limit, 50);
    });

    test('should copy FilterCriteria with new values', () {
      // Arrange
      const originalCriteria = FilterCriteria(
        minPrice: 10.0,
        maxPrice: 100.0,
        brand: 'Nike',
        sizes: ['S', 'M'],
      );

      // Act
      final copiedCriteria = originalCriteria.copyWith(
        minPrice: 20.0,
        brand: 'Adidas',
        colors: ['Red'],
      );

      // Assert
      expect(copiedCriteria.minPrice, 20.0);
      expect(copiedCriteria.maxPrice, 100.0); // unchanged
      expect(copiedCriteria.brand, 'Adidas');
      expect(copiedCriteria.sizes, ['S', 'M']); // unchanged
      expect(copiedCriteria.colors, ['Red']);
    });

    test('should convert FilterCriteria to JSON', () {
      // Arrange
      const criteria = FilterCriteria(
        minPrice: 10.0,
        maxPrice: 100.0,
        minRating: 4.0,
        onSale: true,
        inStock: true,
        sizes: ['S', 'M'],
        colors: ['Red'],
        brand: 'Nike',
        category: 'Shoes',
        categoryIds: [1, 2],
        brandIds: [3],
        attributeIds: [4],
        searchQuery: 'running shoes',
        page: 2,
        limit: 50,
      );

      // Act
      final json = criteria.toJson();

      // Assert
      expect(json['min_price'], 10.0);
      expect(json['max_price'], 100.0);
      expect(json['min_rating'], 4.0);
      expect(json['on_sale'], true);
      expect(json['in_stock'], true);
      expect(json['sizes'], ['S', 'M']);
      expect(json['colors'], ['Red']);
      expect(json['brand'], 'Nike');
      expect(json['category'], 'Shoes');
      expect(json['category_ids'], [1, 2]);
      expect(json['brand_ids'], [3]);
      expect(json['attribute_ids'], [4]);
      expect(json['search_query'], 'running shoes');
      expect(json['page'], 2);
      expect(json['limit'], 50);
    });

    test('should support equality comparison', () {
      // Arrange
      const criteria1 = FilterCriteria(
        minPrice: 10.0,
        brand: 'Nike',
        sizes: ['S', 'M'],
      );
      const criteria2 = FilterCriteria(
        minPrice: 10.0,
        brand: 'Nike',
        sizes: ['S', 'M'],
      );
      const criteria3 = FilterCriteria(
        minPrice: 20.0,
        brand: 'Nike',
        sizes: ['S', 'M'],
      );

      // Assert
      expect(criteria1, equals(criteria2));
      expect(criteria1, isNot(equals(criteria3)));
    });

    test('should handle null values in copyWith', () {
      // Arrange
      const originalCriteria = FilterCriteria(
        minPrice: 10.0,
        maxPrice: 100.0,
        brand: 'Nike',
        category: 'Shoes',
      );

      // Act
      final copiedCriteria = originalCriteria.copyWith(
        minPrice: null,
        brand: null,
      );

      // Assert
      expect(copiedCriteria.minPrice, isNull);
      expect(copiedCriteria.maxPrice, 100.0); // unchanged
      expect(copiedCriteria.brand, isNull);
      expect(copiedCriteria.category, 'Shoes'); // unchanged
    });
  });
}
