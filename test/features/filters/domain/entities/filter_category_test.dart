import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/filters/domain/entities/filter_category.dart';

void main() {
  group('FilterCategory', () {
    test('should create FilterCategory with required fields', () {
      // Arrange & Act
      const category = FilterCategory(
        id: 1,
        name: 'Shoes',
        completeName: 'All / Shoes',
        sequence: 1,
      );

      // Assert
      expect(category.id, 1);
      expect(category.name, 'Shoes');
      expect(category.parentId, isNull);
      expect(category.completeName, 'All / Shoes');
      expect(category.sequence, 1);
      expect(category.image, isNull);
      expect(category.productCount, 0);
      expect(category.hasChildren, false);
      expect(category.children, isEmpty);
    });

    test('should create FilterCategory with all fields', () {
      // Arrange
      const childCategory = FilterCategory(
        id: 2,
        name: 'Running Shoes',
        completeName: 'All / Shoes / Running Shoes',
        sequence: 1,
        productCount: 50,
      );

      // Act
      const category = FilterCategory(
        id: 1,
        name: 'Shoes',
        parentId: 0,
        completeName: 'All / Shoes',
        sequence: 1,
        image: 'shoes.jpg',
        productCount: 100,
        hasChildren: true,
        children: [childCategory],
      );

      // Assert
      expect(category.id, 1);
      expect(category.name, 'Shoes');
      expect(category.parentId, 0);
      expect(category.completeName, 'All / Shoes');
      expect(category.sequence, 1);
      expect(category.image, 'shoes.jpg');
      expect(category.productCount, 100);
      expect(category.hasChildren, true);
      expect(category.children, [childCategory]);
    });

    test('should create FilterCategory from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Shoes',
        'parent_id': 0,
        'complete_name': 'All / Shoes',
        'sequence': 1,
        'image': 'shoes.jpg',
        'product_count': 100,
        'hasChildren': true,
        'children': [
          {
            'id': 2,
            'name': 'Running Shoes',
            'complete_name': 'All / Shoes / Running Shoes',
            'sequence': 1,
            'product_count': 50,
            'hasChildren': false,
            'children': [],
          }
        ],
      };

      // Act
      final category = FilterCategory.fromJson(json);

      // Assert
      expect(category.id, 1);
      expect(category.name, 'Shoes');
      expect(category.parentId, 0);
      expect(category.completeName, 'All / Shoes');
      expect(category.sequence, 1);
      expect(category.image, 'shoes.jpg');
      expect(category.productCount, 100);
      expect(category.hasChildren, true);
      expect(category.children.length, 1);
      expect(category.children.first.id, 2);
      expect(category.children.first.name, 'Running Shoes');
    });

    test('should handle missing fields in JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Shoes',
      };

      // Act
      final category = FilterCategory.fromJson(json);

      // Assert
      expect(category.id, 1);
      expect(category.name, 'Shoes');
      expect(category.parentId, isNull);
      expect(category.completeName, '');
      expect(category.sequence, 0);
      expect(category.image, isNull);
      expect(category.productCount, 0);
      expect(category.hasChildren, false);
      expect(category.children, isEmpty);
    });

    test('should convert FilterCategory to JSON', () {
      // Arrange
      const childCategory = FilterCategory(
        id: 2,
        name: 'Running Shoes',
        completeName: 'All / Shoes / Running Shoes',
        sequence: 1,
        productCount: 50,
      );

      const category = FilterCategory(
        id: 1,
        name: 'Shoes',
        parentId: 0,
        completeName: 'All / Shoes',
        sequence: 1,
        image: 'shoes.jpg',
        productCount: 100,
        hasChildren: true,
        children: [childCategory],
      );

      // Act
      final json = category.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'Shoes');
      expect(json['parent_id'], 0);
      expect(json['complete_name'], 'All / Shoes');
      expect(json['sequence'], 1);
      expect(json['image'], 'shoes.jpg');
      expect(json['product_count'], 100);
      expect(json['hasChildren'], true);
      expect(json['children'], isA<List>());
      expect(json['children'].length, 1);
      expect(json['children'][0]['id'], 2);
      expect(json['children'][0]['name'], 'Running Shoes');
    });

    test('should support equality comparison', () {
      // Arrange
      const category1 = FilterCategory(
        id: 1,
        name: 'Shoes',
        completeName: 'All / Shoes',
        sequence: 1,
        productCount: 100,
      );
      const category2 = FilterCategory(
        id: 1,
        name: 'Shoes',
        completeName: 'All / Shoes',
        sequence: 1,
        productCount: 100,
      );
      const category3 = FilterCategory(
        id: 2,
        name: 'Shoes',
        completeName: 'All / Shoes',
        sequence: 1,
        productCount: 100,
      );

      // Assert
      expect(category1, equals(category2));
      expect(category1, isNot(equals(category3)));
    });
  });
}
