import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/filters/domain/entities/filter_attribute.dart';

void main() {
  group('FilterAttribute', () {
    test('should create FilterAttribute with required fields', () {
      // Arrange & Act
      const attribute = FilterAttribute(
        id: 1,
        name: 'Size',
        type: 'text',
      );

      // Assert
      expect(attribute.id, 1);
      expect(attribute.name, 'Size');
      expect(attribute.type, 'text');
      expect(attribute.values, isEmpty);
      expect(attribute.isRequired, false);
      expect(attribute.isVisible, true);
    });

    test('should create FilterAttribute with all fields', () {
      // Arrange
      const value1 = FilterAttributeValue(
        id: 1,
        name: 'Small',
        value: 'S',
        productCount: 50,
      );
      const value2 = FilterAttributeValue(
        id: 2,
        name: 'Medium',
        value: 'M',
        productCount: 75,
      );

      // Act
      const attribute = FilterAttribute(
        id: 1,
        name: 'Size',
        type: 'text',
        values: [value1, value2],
        isRequired: true,
        isVisible: true,
      );

      // Assert
      expect(attribute.id, 1);
      expect(attribute.name, 'Size');
      expect(attribute.type, 'text');
      expect(attribute.values, [value1, value2]);
      expect(attribute.isRequired, true);
      expect(attribute.isVisible, true);
    });

    test('should create FilterAttribute from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Size',
        'type': 'text',
        'values': [
          {
            'id': 1,
            'name': 'Small',
            'value': 'S',
            'product_count': 50,
            'is_active': true,
          },
          {
            'id': 2,
            'name': 'Medium',
            'value': 'M',
            'product_count': 75,
            'is_active': true,
          },
        ],
        'is_required': true,
        'is_visible': true,
      };

      // Act
      final attribute = FilterAttribute.fromJson(json);

      // Assert
      expect(attribute.id, 1);
      expect(attribute.name, 'Size');
      expect(attribute.type, 'text');
      expect(attribute.values.length, 2);
      expect(attribute.values.first.id, 1);
      expect(attribute.values.first.name, 'Small');
      expect(attribute.values.first.value, 'S');
      expect(attribute.values.first.productCount, 50);
      expect(attribute.values.first.isActive, true);
      expect(attribute.isRequired, true);
      expect(attribute.isVisible, true);
    });

    test('should handle missing fields in JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Size',
      };

      // Act
      final attribute = FilterAttribute.fromJson(json);

      // Assert
      expect(attribute.id, 1);
      expect(attribute.name, 'Size');
      expect(attribute.type, 'text');
      expect(attribute.values, isEmpty);
      expect(attribute.isRequired, false);
      expect(attribute.isVisible, true);
    });

    test('should convert FilterAttribute to JSON', () {
      // Arrange
      const value1 = FilterAttributeValue(
        id: 1,
        name: 'Small',
        value: 'S',
        productCount: 50,
      );
      const value2 = FilterAttributeValue(
        id: 2,
        name: 'Medium',
        value: 'M',
        productCount: 75,
      );

      const attribute = FilterAttribute(
        id: 1,
        name: 'Size',
        type: 'text',
        values: [value1, value2],
        isRequired: true,
        isVisible: true,
      );

      // Act
      final json = attribute.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'Size');
      expect(json['type'], 'text');
      expect(json['values'], isA<List>());
      expect(json['values'].length, 2);
      expect(json['values'][0]['id'], 1);
      expect(json['values'][0]['name'], 'Small');
      expect(json['values'][0]['value'], 'S');
      expect(json['values'][0]['product_count'], 50);
      expect(json['values'][0]['is_active'], true);
      expect(json['is_required'], true);
      expect(json['is_visible'], true);
    });

    test('should support equality comparison', () {
      // Arrange
      const attribute1 = FilterAttribute(
        id: 1,
        name: 'Size',
        type: 'text',
        isRequired: true,
      );
      const attribute2 = FilterAttribute(
        id: 1,
        name: 'Size',
        type: 'text',
        isRequired: true,
      );
      const attribute3 = FilterAttribute(
        id: 2,
        name: 'Size',
        type: 'text',
        isRequired: true,
      );

      // Assert
      expect(attribute1, equals(attribute2));
      expect(attribute1, isNot(equals(attribute3)));
    });
  });

  group('FilterAttributeValue', () {
    test('should create FilterAttributeValue with required fields', () {
      // Arrange & Act
      const value = FilterAttributeValue(
        id: 1,
        name: 'Small',
        value: 'S',
      );

      // Assert
      expect(value.id, 1);
      expect(value.name, 'Small');
      expect(value.value, 'S');
      expect(value.productCount, 0);
      expect(value.isActive, true);
    });

    test('should create FilterAttributeValue with all fields', () {
      // Arrange & Act
      const value = FilterAttributeValue(
        id: 1,
        name: 'Small',
        value: 'S',
        productCount: 50,
        isActive: true,
      );

      // Assert
      expect(value.id, 1);
      expect(value.name, 'Small');
      expect(value.value, 'S');
      expect(value.productCount, 50);
      expect(value.isActive, true);
    });

    test('should create FilterAttributeValue from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Small',
        'value': 'S',
        'product_count': 50,
        'is_active': true,
      };

      // Act
      final value = FilterAttributeValue.fromJson(json);

      // Assert
      expect(value.id, 1);
      expect(value.name, 'Small');
      expect(value.value, 'S');
      expect(value.productCount, 50);
      expect(value.isActive, true);
    });

    test('should handle missing fields in JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Small',
        'value': 'S',
      };

      // Act
      final value = FilterAttributeValue.fromJson(json);

      // Assert
      expect(value.id, 1);
      expect(value.name, 'Small');
      expect(value.value, 'S');
      expect(value.productCount, 0);
      expect(value.isActive, true);
    });

    test('should convert FilterAttributeValue to JSON', () {
      // Arrange
      const value = FilterAttributeValue(
        id: 1,
        name: 'Small',
        value: 'S',
        productCount: 50,
        isActive: true,
      );

      // Act
      final json = value.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'Small');
      expect(json['value'], 'S');
      expect(json['product_count'], 50);
      expect(json['is_active'], true);
    });

    test('should support equality comparison', () {
      // Arrange
      const value1 = FilterAttributeValue(
        id: 1,
        name: 'Small',
        value: 'S',
        productCount: 50,
      );
      const value2 = FilterAttributeValue(
        id: 1,
        name: 'Small',
        value: 'S',
        productCount: 50,
      );
      const value3 = FilterAttributeValue(
        id: 2,
        name: 'Small',
        value: 'S',
        productCount: 50,
      );

      // Assert
      expect(value1, equals(value2));
      expect(value1, isNot(equals(value3)));
    });
  });
}
