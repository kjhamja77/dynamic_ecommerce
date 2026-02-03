import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/filters/domain/entities/filter_brand.dart';

void main() {
  group('FilterBrand', () {
    test('should create FilterBrand with required fields', () {
      // Arrange & Act
      const brand = FilterBrand(
        id: 1,
        name: 'Nike',
      );

      // Assert
      expect(brand.id, 1);
      expect(brand.name, 'Nike');
      expect(brand.image, isNull);
      expect(brand.productCount, 0);
      expect(brand.isActive, true);
    });

    test('should create FilterBrand with all fields', () {
      // Arrange & Act
      const brand = FilterBrand(
        id: 1,
        name: 'Nike',
        image: 'nike.jpg',
        productCount: 150,
        isActive: true,
      );

      // Assert
      expect(brand.id, 1);
      expect(brand.name, 'Nike');
      expect(brand.image, 'nike.jpg');
      expect(brand.productCount, 150);
      expect(brand.isActive, true);
    });

    test('should create FilterBrand from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Nike',
        'image': 'nike.jpg',
        'product_count': 150,
        'is_active': true,
      };

      // Act
      final brand = FilterBrand.fromJson(json);

      // Assert
      expect(brand.id, 1);
      expect(brand.name, 'Nike');
      expect(brand.image, 'nike.jpg');
      expect(brand.productCount, 150);
      expect(brand.isActive, true);
    });

    test('should handle missing fields in JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Nike',
      };

      // Act
      final brand = FilterBrand.fromJson(json);

      // Assert
      expect(brand.id, 1);
      expect(brand.name, 'Nike');
      expect(brand.image, isNull);
      expect(brand.productCount, 0);
      expect(brand.isActive, true);
    });

    test('should convert FilterBrand to JSON', () {
      // Arrange
      const brand = FilterBrand(
        id: 1,
        name: 'Nike',
        image: 'nike.jpg',
        productCount: 150,
        isActive: true,
      );

      // Act
      final json = brand.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'Nike');
      expect(json['image'], 'nike.jpg');
      expect(json['product_count'], 150);
      expect(json['is_active'], true);
    });

    test('should support equality comparison', () {
      // Arrange
      const brand1 = FilterBrand(
        id: 1,
        name: 'Nike',
        productCount: 150,
      );
      const brand2 = FilterBrand(
        id: 1,
        name: 'Nike',
        productCount: 150,
      );
      const brand3 = FilterBrand(
        id: 2,
        name: 'Nike',
        productCount: 150,
      );

      // Assert
      expect(brand1, equals(brand2));
      expect(brand1, isNot(equals(brand3)));
    });
  });
}
