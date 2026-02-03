import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/catalog/domain/entities/sort_option.dart';

void main() {
  group('SortOption', () {
    test('should create sort option with correct properties', () {
      // Arrange
      const sortOption = SortOption(
        value: 'price_asc',
        label: 'Price: Low to High',
        subtitle: 'Best deals first',
        type: SortType.priceLowToHigh,
      );

      // Assert
      expect(sortOption.value, 'price_asc');
      expect(sortOption.label, 'Price: Low to High');
      expect(sortOption.subtitle, 'Best deals first');
      expect(sortOption.type, SortType.priceLowToHigh);
    });

    test('should be equal when properties are same', () {
      // Arrange
      const sortOption1 = SortOption(
        value: 'price_asc',
        label: 'Price: Low to High',
        subtitle: 'Best deals first',
        type: SortType.priceLowToHigh,
      );

      const sortOption2 = SortOption(
        value: 'price_asc',
        label: 'Price: Low to High',
        subtitle: 'Best deals first',
        type: SortType.priceLowToHigh,
      );

      // Assert
      expect(sortOption1, equals(sortOption2));
    });

    test('should not be equal when properties are different', () {
      // Arrange
      const sortOption1 = SortOption(
        value: 'price_asc',
        label: 'Price: Low to High',
        subtitle: 'Best deals first',
        type: SortType.priceLowToHigh,
      );

      const sortOption2 = SortOption(
        value: 'price_desc',
        label: 'Price: High to Low',
        subtitle: 'Premium picks first',
        type: SortType.priceHighToLow,
      );

      // Assert
      expect(sortOption1, isNot(equals(sortOption2)));
    });

    test('should have correct props for equality', () {
      // Arrange
      const sortOption = SortOption(
        value: 'price_asc',
        label: 'Price: Low to High',
        subtitle: 'Best deals first',
        type: SortType.priceLowToHigh,
      );

      // Assert
      expect(sortOption.props, [
        'price_asc',
        'Price: Low to High',
        'Best deals first',
        SortType.priceLowToHigh,
      ]);
    });

    test('should have correct string representation', () {
      // Arrange
      const sortOption = SortOption(
        value: 'price_asc',
        label: 'Price: Low to High',
        subtitle: 'Best deals first',
        type: SortType.priceLowToHigh,
      );

      // Act
      final stringRepresentation = sortOption.toString();

      // Assert
      expect(stringRepresentation, contains('price_asc'));
      expect(stringRepresentation, contains('Price: Low to High'));
      expect(stringRepresentation, contains('SortType.priceLowToHigh'));
    });
  });

  group('SortType', () {
    test('should have correct API values for all sort types', () {
      // Assert
      expect(SortType.priceLowToHigh.apiValue, 'price_asc');
      expect(SortType.priceHighToLow.apiValue, 'price_desc');
      expect(SortType.newest.apiValue, 'newest');
      expect(SortType.featured.apiValue, 'featured');
      expect(SortType.rating.apiValue, 'rating');
      expect(SortType.popularity.apiValue, 'popularity');
    });

    test('should have unique API values', () {
      // Arrange
      final apiValues = SortType.values.map((type) => type.apiValue).toList();

      // Assert
      expect(apiValues.toSet().length, equals(apiValues.length));
    });
  });
}
