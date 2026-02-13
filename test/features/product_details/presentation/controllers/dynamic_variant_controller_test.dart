import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/product_details/domain/entities/product_details.dart';
import 'package:zalando_clone_app/features/product_details/presentation/controllers/dynamic_variant_controller.dart';

void main() {
  group('DynamicVariantController', () {
    late DynamicVariantController controller;
    late ProductDetails mockProductDetails;

    setUp(() {
      controller = DynamicVariantController();
      mockProductDetails = _createMockProductDetails();
    });

    tearDown(() {
      controller.dispose();
    });

    group('Initialization', () {
      test('initializes with product details', () {
        controller.initialize(mockProductDetails);

        expect(controller.productDetails, equals(mockProductDetails));
        expect(controller.selectedAttributes, isNotEmpty);
        expect(controller.selectedVariant, isNotNull);
      });

      test('initializes selectedAttributes from selected variant', () {
        controller.initialize(mockProductDetails);

        // Should have 3 attributes: Color (8), Size (7), Material (9)
        expect(controller.selectedAttributes.length, equals(3));
        expect(controller.selectedAttributes[8], equals(101)); // Black
        expect(controller.selectedAttributes[7], equals(201)); // 36
        expect(controller.selectedAttributes[9], equals(301)); // Leather
      });

      test('finds matching variant on initialization', () {
        controller.initialize(mockProductDetails);

        expect(controller.selectedVariant, isNotNull);
        expect(controller.selectedVariant!.variantId, equals('12345'));
        expect(controller.inStock, isTrue);
        expect(controller.quantityAvailable, equals(10));
      });

      test('sets correct price on initialization', () {
        controller.initialize(mockProductDetails);

        expect(controller.currentPrice, equals(99.99));
      });

      test('sets correct images on initialization', () {
        controller.initialize(mockProductDetails);

        expect(controller.currentImages, isNotEmpty);
      });
    });

    group('Selection', () {
      test('updates selectedAttributes when value is selected', () {
        controller.initialize(mockProductDetails);

        controller.selectAttributeValue(8, 102); // Select White

        expect(controller.selectedAttributes[8], equals(102));
      });

      test('finds new matching variant after selection', () {
        controller.initialize(mockProductDetails);

        controller.selectAttributeValue(8, 102); // Select White

        expect(controller.selectedVariant, isNotNull);
        expect(controller.selectedVariant!.variantId, equals('12346'));
      });

      test('updates stock status after selection', () {
        controller.initialize(mockProductDetails);

        // Select combination that's out of stock
        controller.selectAttributeValue(7, 202); // Select size 37

        expect(controller.inStock, isFalse);
        expect(controller.quantityAvailable, equals(0));
      });

      test('notifies listeners when selection changes', () {
        controller.initialize(mockProductDetails);
        var notified = false;

        controller.addListener(() {
          notified = true;
        });

        controller.selectAttributeValue(8, 102);

        expect(notified, isTrue);
      });

      test('handles selection of non-existent combination', () {
        controller.initialize(mockProductDetails);

        // Select combination that doesn't exist
        controller.selectAttributeValue(8, 999);

        expect(controller.selectedVariant, isNull);
        expect(controller.inStock, isFalse);
        expect(controller.variantId, isEmpty);
      });
    });

    group('Availability', () {
      test('returns available values for attribute', () {
        controller.initialize(mockProductDetails);

        final availableColors = controller.getAvailableValuesForAttribute(8);

        expect(availableColors, contains(101)); // Black
        expect(availableColors, contains(102)); // White
        expect(availableColors.length, equals(2));
      });

      test('filters available values based on current selection', () {
        controller.initialize(mockProductDetails);

        // Select size 37 (which has limited color options)
        controller.selectAttributeValue(7, 202);

        final availableColors = controller.getAvailableValuesForAttribute(8);

        // Should only show colors available for size 37
        expect(availableColors.length, lessThanOrEqualTo(2));
      });

      test('checks if specific value is available', () {
        controller.initialize(mockProductDetails);

        final isBlackAvailable = controller.isValueAvailable(8, 101);
        final isInvalidAvailable = controller.isValueAvailable(8, 999);

        expect(isBlackAvailable, isTrue);
        expect(isInvalidAvailable, isFalse);
      });

      test('returns empty set for non-existent attribute', () {
        controller.initialize(mockProductDetails);

        final availableValues = controller.getAvailableValuesForAttribute(999);

        expect(availableValues, isEmpty);
      });
    });

    group('Matching Logic', () {
      test('matches variant with all attributes', () {
        controller.initialize(mockProductDetails);

        controller.selectAttributeValue(8, 101); // Black
        controller.selectAttributeValue(7, 201); // 36
        controller.selectAttributeValue(9, 301); // Leather

        expect(controller.selectedVariant, isNotNull);
        expect(controller.selectedVariant!.variantId, equals('12345'));
      });

      test('does not match variant with partial attributes', () {
        controller.initialize(mockProductDetails);

        controller.selectAttributeValue(8, 101); // Black
        controller.selectAttributeValue(7, 999); // Invalid size

        expect(controller.selectedVariant, isNull);
      });

      test('matches variant case-insensitively', () {
        controller.initialize(mockProductDetails);

        // All IDs should match regardless of case in names
        controller.selectAttributeValue(8, 101);
        controller.selectAttributeValue(7, 201);
        controller.selectAttributeValue(9, 301);

        expect(controller.selectedVariant, isNotNull);
      });
    });

    group('Images', () {
      test('updates images when variant changes', () {
        controller.initialize(mockProductDetails);
        final initialImages = List.from(controller.currentImages);

        controller.selectAttributeValue(8, 102); // Change color

        expect(controller.currentImages, isNot(equals(initialImages)));
      });

      test('uses variant-specific images when available', () {
        controller.initialize(mockProductDetails);

        // Variant 12345 should have specific images
        expect(controller.currentImages, contains('https://example.com/variant-12345-1.jpg'));
      });

      test('falls back to template images when variant has no images', () {
        controller.initialize(mockProductDetails);

        // Select variant without specific images
        controller.selectAttributeValue(8, 103); // Red (no specific images)

        expect(controller.currentImages, contains('https://example.com/template.jpg'));
      });
    });

    group('Helper Methods', () {
      test('gets attribute name by id', () {
        controller.initialize(mockProductDetails);

        final colorName = controller.getAttributeNameById(8);
        final sizeName = controller.getAttributeNameById(7);

        expect(colorName, equals('Color'));
        expect(sizeName, equals('Size'));
      });

      test('gets value name by ids', () {
        controller.initialize(mockProductDetails);

        final blackName = controller.getValueNameByIds(8, 101);
        final size36Name = controller.getValueNameByIds(7, 201);

        expect(blackName, equals('Black'));
        expect(size36Name, equals('36'));
      });

      test('returns null for non-existent attribute id', () {
        controller.initialize(mockProductDetails);

        final name = controller.getAttributeNameById(999);

        expect(name, isNull);
      });

      test('returns null for non-existent value id', () {
        controller.initialize(mockProductDetails);

        final name = controller.getValueNameByIds(8, 999);

        expect(name, isNull);
      });
    });

    group('Reset', () {
      test('clears all state on reset', () {
        controller.initialize(mockProductDetails);
        controller.selectAttributeValue(8, 102);

        controller.reset();

        expect(controller.selectedAttributes, isEmpty);
        expect(controller.selectedVariant, isNull);
        expect(controller.currentPrice, equals(0.0));
        expect(controller.variantId, isEmpty);
        expect(controller.currentImages, isEmpty);
        expect(controller.productDetails, isNull);
      });
    });

    group('Edge Cases', () {
      test('handles empty variant combinations', () {
        final emptyProduct = _createMockProductDetails(variantCombinations: []);
        controller.initialize(emptyProduct);

        expect(controller.selectedVariant, isNull);
        expect(controller.inStock, isFalse);
      });

      test('handles single attribute', () {
        final singleAttrProduct = _createMockProductDetails(
          variantAttributes: [
            _createVariantAttributeOption(8, 'Color', [
              _createVariantAttributeValue(101, 'Black'),
            ]),
          ],
        );
        controller.initialize(singleAttrProduct);

        expect(controller.selectedAttributes.length, equals(1));
      });

      test('handles many attributes', () {
        final manyAttrProduct = _createMockProductDetails(
          variantAttributes: List.generate(
            10,
            (i) => _createVariantAttributeOption(i, 'Attr$i', [
              _createVariantAttributeValue(i * 100, 'Value$i'),
            ]),
          ),
        );
        controller.initialize(manyAttrProduct);

        expect(controller.selectedAttributes.length, equals(10));
      });

      test('handles null quantity_available', () {
        final nullQtyProduct = _createMockProductDetails(
          variantCombinations: [
            VariantCombination(
              variantId: '12345',
              inStock: true,
              quantityAvailable: null, // Null quantity
              attributes: [
                const VariantAttribute(
                  attributeName: 'Color',
                  valueName: 'Black',
                  attributeId: '8',
                  valueId: '101',
                ),
              ],
            ),
          ],
        );
        controller.initialize(nullQtyProduct);

        // Should still work with null quantity
        expect(controller.selectedVariant, isNotNull);
      });
    });
  });
}

// Helper functions to create mock data

ProductDetails _createMockProductDetails({
  List<VariantAttributeOption>? variantAttributes,
  List<VariantCombination>? variantCombinations,
}) {
  return ProductDetails(
    id: '1',
    brand: 'Test Brand',
    name: 'Test Product',
    description: 'Test Description',
    price: 99.99,
    originalPrice: 129.99,
    rating: 4,
    reviewCount: 100,
    images: ['https://example.com/template.jpg'],
    colorOptions: [],
    sizeOptions: [],
    variantAttributeOptions: variantAttributes ?? _createDefaultVariantAttributes(),
    selectedColor: 'Black',
    selectedSize: '36',
    isFavorite: false,
    hasDiscount: true,
    discountPercentage: 23,
    features: [],
    material: 'Leather',
    careInstructions: 'Test care',
    isPlusMember: false,
    pointsEarned: 10,
    variantCombinations: variantCombinations ?? _createDefaultVariantCombinations(),
    variantImagesMap: {
      '12345': [
        'https://example.com/variant-12345-1.jpg',
        'https://example.com/variant-12345-2.jpg',
      ],
      '12346': [
        'https://example.com/variant-12346-1.jpg',
      ],
    },
  );
}

List<VariantAttributeOption> _createDefaultVariantAttributes() {
  return [
    _createVariantAttributeOption(8, 'Color', [
      _createVariantAttributeValue(101, 'Black'),
      _createVariantAttributeValue(102, 'White'),
      _createVariantAttributeValue(103, 'Red'),
    ]),
    _createVariantAttributeOption(7, 'Size', [
      _createVariantAttributeValue(201, '36'),
      _createVariantAttributeValue(202, '37'),
      _createVariantAttributeValue(203, '38'),
    ]),
    _createVariantAttributeOption(9, 'Material', [
      _createVariantAttributeValue(301, 'Leather'),
      _createVariantAttributeValue(302, 'Synthetic'),
    ]),
  ];
}

VariantAttributeOption _createVariantAttributeOption(
  int id,
  String name,
  List<VariantAttributeValue> values,
) {
  return VariantAttributeOption(
    attributeName: name,
    values: values,
    selectedValue: values.first.name,
    attributeId: id.toString(),
  );
}

VariantAttributeValue _createVariantAttributeValue(int id, String name) {
  return VariantAttributeValue(
    id: id.toString(),
    name: name,
    isAvailable: true,
    isSelected: false,
  );
}

List<VariantCombination> _createDefaultVariantCombinations() {
  return [
    // Black + 36 + Leather (In stock)
    VariantCombination(
      variantId: '12345',
      inStock: true,
      quantityAvailable: 10,
      attributes: [
        const VariantAttribute(
          attributeName: 'Color',
          valueName: 'Black',
          attributeId: '8',
          valueId: '101',
        ),
        const VariantAttribute(
          attributeName: 'Size',
          valueName: '36',
          attributeId: '7',
          valueId: '201',
        ),
        const VariantAttribute(
          attributeName: 'Material',
          valueName: 'Leather',
          attributeId: '9',
          valueId: '301',
        ),
      ],
    ),
    // White + 36 + Leather (In stock)
    VariantCombination(
      variantId: '12346',
      inStock: true,
      quantityAvailable: 5,
      attributes: [
        const VariantAttribute(
          attributeName: 'Color',
          valueName: 'White',
          attributeId: '8',
          valueId: '102',
        ),
        const VariantAttribute(
          attributeName: 'Size',
          valueName: '36',
          attributeId: '7',
          valueId: '201',
        ),
        const VariantAttribute(
          attributeName: 'Material',
          valueName: 'Leather',
          attributeId: '9',
          valueId: '301',
        ),
      ],
    ),
    // Black + 37 + Leather (Out of stock)
    VariantCombination(
      variantId: '12347',
      inStock: false,
      quantityAvailable: 0,
      attributes: [
        const VariantAttribute(
          attributeName: 'Color',
          valueName: 'Black',
          attributeId: '8',
          valueId: '101',
        ),
        const VariantAttribute(
          attributeName: 'Size',
          valueName: '37',
          attributeId: '7',
          valueId: '202',
        ),
        const VariantAttribute(
          attributeName: 'Material',
          valueName: 'Leather',
          attributeId: '9',
          valueId: '301',
        ),
      ],
    ),
  ];
}
