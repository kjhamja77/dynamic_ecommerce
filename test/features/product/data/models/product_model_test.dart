import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/product/data/models/product_model.dart';
import 'package:zalando_clone_app/features/product/data/models/product_category_model.dart';
import 'package:zalando_clone_app/features/product/data/models/product_image_model.dart';

void main() {
  group('ProductModel', () {
    test('should create a ProductModel from JSON', () {
      // Arrange
      const json = {
        'id': 12,
        'name': 'Storage Box',
        'description': 'A storage box for office supplies',
        'short_description': 'Office storage',
        'price': 15.8,
        'currency': 'IQD',
        'category': {
          'id': 8,
          'name': 'Office Furniture'
        },
        'brand': 'OfficePro',
        'type': 'template',
        'quantity_available': 18.0,
        'in_stock': true,
        'total_variants': 1,
        'available_variants': 1,
        'variant_attributes': [
          {
            'id': 1,
            'name': 'Color',
            'values': [
              {'id': 1, 'name': 'Black'},
              {'id': 2, 'name': 'White'}
            ]
          }
        ],
        'variant_combinations': [
          {
            'variant_id': 18,
            'name': 'Storage Box',
            'price': 15.8,
            'quantity_available': 18.0,
            'quantity_forecast': 18.0,
            'in_stock': true,
            'sku': 'E-COM08',
            'barcode': '123456789',
            'attributes': [
              {
                'attribute_id': 1,
                'attribute_name': 'Color',
                'value_id': 1,
                'value_name': 'Black'
              }
            ]
          }
        ],
        'images': [
          {
            'type': 'template',
            'url': '/web/image/product.template/12/image_1920',
            'alt': 'Storage Box'
          }
        ],
        'optional_product_ids': [
          {
            'id': 16,
            'name': 'Conference Chair',
            'price': 33.0,
            'description': 'Comfortable chair',
            'image': '/web/image/product.template/16/image_1920',
            'product_tag_ids': [1, 2]
          }
        ],
        'accessory_product_ids': [],
        'alternative_product_ids': [],
        'sku': 'E-COM08',
        'barcode': '123456789',
        'ribbon': 'New',
        'main_image': '/web/image/product.template/12/image_1920'
      };

      // Act
      final product = ProductModel.fromJson(json);

      // Assert
      expect(product.id, 12);
      expect(product.name, 'Storage Box');
      expect(product.description, 'A storage box for office supplies');
      expect(product.shortDescription, 'Office storage');
      expect(product.price, 15.8);
      expect(product.currency, 'IQD');
      expect(product.category.id, 8);
      expect(product.category.name, 'Office Furniture');
      expect(product.brand, 'OfficePro');
      expect(product.type, 'template');
      expect(product.quantityAvailable, 18.0);
      expect(product.inStock, true);
      expect(product.totalVariants, 1);
      expect(product.availableVariants, 1);
      expect(product.variantAttributes.length, 1);
      expect(product.variantCombinations.length, 1);
      expect(product.images.length, 1);
      expect(product.optionalProductIds.length, 1);
      expect(product.accessoryProductIds.length, 0);
      expect(product.alternativeProductIds.length, 0);
      expect(product.sku, 'E-COM08');
      expect(product.barcode, '123456789');
      expect(product.ribbon, 'New');
      expect(product.mainImage, '/web/image/product.template/12/image_1920');
    });

    test('should create JSON from ProductModel', () {
      // Arrange
      final product = ProductModel(
        id: 12,
        name: 'Storage Box',
        description: 'A storage box for office supplies',
        shortDescription: 'Office storage',
        price: 15.8,
        currency: 'IQD',
        category: const ProductCategoryModel(
          id: 8, 
          name: 'Office Furniture',
          completeName: 'Office Furniture',
          sequence: 1,
        ),
        brand: 'OfficePro',
        type: 'template',
        quantityAvailable: 18.0,
        inStock: true,
        totalVariants: 1,
        availableVariants: 1,
        variantAttributes: const [],
        variantCombinations: const [],
        images: const [],
        optionalProductIds: const [],
        accessoryProductIds: const [],
        alternativeProductIds: const [],
        sku: 'E-COM08',
        barcode: '123456789',
        ribbon: 'New',
        mainImage: '/web/image/product.template/12/image_1920',
      );

      // Act
      final json = product.toJson();

      // Assert
      expect(json['id'], 12);
      expect(json['name'], 'Storage Box');
      expect(json['description'], 'A storage box for office supplies');
      expect(json['short_description'], 'Office storage');
      expect(json['price'], 15.8);
      expect(json['currency'], 'IQD');
      expect(json['category']['id'], 8);
      expect(json['category']['name'], 'Office Furniture');
      expect(json['brand'], 'OfficePro');
      expect(json['type'], 'template');
      expect(json['quantity_available'], 18.0);
      expect(json['in_stock'], true);
      expect(json['total_variants'], 1);
      expect(json['available_variants'], 1);
      expect(json['sku'], 'E-COM08');
      expect(json['barcode'], '123456789');
      expect(json['ribbon'], 'New');
      expect(json['main_image'], '/web/image/product.template/12/image_1920');
    });

    test('should handle empty JSON gracefully', () {
      // Arrange
      const json = <String, dynamic>{};

      // Act
      final product = ProductModel.fromJson(json);

      // Assert
      expect(product.id, 0);
      expect(product.name, '');
      expect(product.description, '');
      expect(product.shortDescription, '');
      expect(product.price, 0.0);
      expect(product.currency, 'IQD');
      expect(product.category.id, 0);
      expect(product.category.name, '');
      expect(product.brand, null);
      expect(product.type, 'template');
      expect(product.quantityAvailable, 0.0);
      expect(product.inStock, false);
      expect(product.totalVariants, 0);
      expect(product.availableVariants, 0);
      expect(product.variantAttributes, []);
      expect(product.variantCombinations, []);
      expect(product.images, []);
      expect(product.optionalProductIds, []);
      expect(product.accessoryProductIds, []);
      expect(product.alternativeProductIds, []);
      expect(product.sku, '');
      expect(product.barcode, '');
      expect(product.ribbon, null);
      expect(product.mainImage, null);
    });

    test('should return correct helper properties', () {
      // Arrange
      final product = ProductModel(
        id: 12,
        name: 'Storage Box',
        description: 'A storage box',
        shortDescription: 'Office storage',
        price: 15.8,
        currency: 'IQD',
        category: const ProductCategoryModel(
          id: 8, 
          name: 'Office Furniture',
          completeName: 'Office Furniture',
          sequence: 1,
        ),
        type: 'template',
        quantityAvailable: 18.0,
        inStock: true,
        totalVariants: 2,
        availableVariants: 2,
        variantAttributes: const [],
        variantCombinations: const [],
        images: const [],
        optionalProductIds: const [],
        accessoryProductIds: const [],
        alternativeProductIds: const [],
        sku: 'E-COM08',
        barcode: '123456789',
      );

      // Act & Assert
      expect(product.hasVariants, true);
      expect(product.hasAttributes, false);
      expect(product.hasImages, false);
      expect(product.hasOptionalProducts, false);
      expect(product.hasAccessoryProducts, false);
      expect(product.hasAlternativeProducts, false);
    });

    test('should return template image URL correctly', () {
      // Arrange
      final product = ProductModel(
        id: 12,
        name: 'Storage Box',
        description: 'A storage box',
        shortDescription: 'Office storage',
        price: 15.8,
        currency: 'IQD',
        category: const ProductCategoryModel(
          id: 8, 
          name: 'Office Furniture',
          completeName: 'Office Furniture',
          sequence: 1,
        ),
        type: 'template',
        quantityAvailable: 18.0,
        inStock: true,
        totalVariants: 1,
        availableVariants: 1,
        variantAttributes: const [],
        variantCombinations: const [],
        images: const [
          ProductImageModel(
            type: 'template',
            url: '/web/image/product.template/12/image_1920',
            alt: 'Storage Box',
          ),
        ],
        optionalProductIds: const [],
        accessoryProductIds: const [],
        alternativeProductIds: const [],
        sku: 'E-COM08',
        barcode: '123456789',
      );

      // Act
      final imageUrl = product.templateImageUrl;

      // Assert
      expect(imageUrl, '/web/image/product.template/12/image_1920');
    });

    test('should return variant image URL correctly', () {
      // Arrange
      final product = ProductModel(
        id: 12,
        name: 'Storage Box',
        description: 'A storage box',
        shortDescription: 'Office storage',
        price: 15.8,
        currency: 'IQD',
        category: const ProductCategoryModel(
          id: 8, 
          name: 'Office Furniture',
          completeName: 'Office Furniture',
          sequence: 1,
        ),
        type: 'template',
        quantityAvailable: 18.0,
        inStock: true,
        totalVariants: 1,
        availableVariants: 1,
        variantAttributes: const [],
        variantCombinations: const [],
        images: const [
          ProductImageModel(
            type: 'variant',
            variantId: 18,
            url: '/web/image/product.product/18/image_1920',
            alt: 'Storage Box',
          ),
        ],
        optionalProductIds: const [],
        accessoryProductIds: const [],
        alternativeProductIds: const [],
        sku: 'E-COM08',
        barcode: '123456789',
      );

      // Act
      final imageUrl = product.getVariantImageUrl(18);

      // Assert
      expect(imageUrl, '/web/image/product.product/18/image_1920');
    });
  });
}


