import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/favorites/data/models/favorite_product_model.dart';

void main() {
  group('FavoriteProductModel', () {
    group('fromJson', () {
      test('should create FavoriteProductModel from valid JSON', () {
        // arrange
        final json = {
          'id': '1',
          'name': 'Test Product',
          'brand': 'Test Brand',
          'price': 99.99,
          'imageUrl': 'https://example.com/image.jpg',
          'category': 'Test Category',
          'addedAt': '2024-01-01T00:00:00.000Z',
        };

        // act
        final result = FavoriteProductModel.fromJson(json);

        // assert
        expect(result.id, '1');
        expect(result.name, 'Test Product');
        expect(result.brand, 'Test Brand');
        expect(result.price, 99.99);
        expect(result.imageUrl, 'https://example.com/image.jpg');
        expect(result.category, 'Test Category');
        expect(result.addedAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      });

      test('should handle missing optional fields', () {
        // arrange
        final json = {
          'id': '1',
          'name': 'Test Product',
          'brand': 'Test Brand',
          'price': 99.99,
          'addedAt': '2024-01-01T00:00:00.000Z',
        };

        // act
        final result = FavoriteProductModel.fromJson(json);

        // assert
        expect(result.id, '1');
        expect(result.name, 'Test Product');
        expect(result.brand, 'Test Brand');
        expect(result.price, 99.99);
        expect(result.imageUrl, null);
        expect(result.category, null);
        expect(result.addedAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      });
    });

    group('toJson', () {
      test('should convert FavoriteProductModel to JSON', () {
        // arrange
        final model = FavoriteProductModel(
          id: '1',
          name: 'Test Product',
          brand: 'Test Brand',
          price: 99.99,
          imageUrl: 'https://example.com/image.jpg',
          category: 'Test Category',
          addedAt: DateTime(2024, 1, 1),
        );

        // act
        final result = model.toJson();

        // assert
        expect(result['id'], '1');
        expect(result['name'], 'Test Product');
        expect(result['brand'], 'Test Brand');
        expect(result['price'], 99.99);
        expect(result['imageUrl'], 'https://example.com/image.jpg');
        expect(result['category'], 'Test Category');
        expect(result['addedAt'], '2024-01-01T00:00:00.000');
      });
    });

    group('fromEntity', () {
      test('should create FavoriteProductModel from entity', () {
        // arrange
        final entity = FavoriteProductModel(
          id: '1',
          name: 'Test Product',
          brand: 'Test Brand',
          price: 99.99,
          imageUrl: 'https://example.com/image.jpg',
          category: 'Test Category',
          addedAt: DateTime(2024, 1, 1),
        );

        // act
        final result = FavoriteProductModel.fromEntity(entity);

        // assert
        expect(result.id, '1');
        expect(result.name, 'Test Product');
        expect(result.brand, 'Test Brand');
        expect(result.price, 99.99);
        expect(result.imageUrl, 'https://example.com/image.jpg');
        expect(result.category, 'Test Category');
        expect(result.addedAt, DateTime(2024, 1, 1));
      });
    });

    group('fromWishlistJson', () {
      test('should parse complete wishlist API response', () {
        // arrange
        final wishlistJson = {
          'id': 2,
          'product': {
            'id': 17,
            'name': '[E-COM07] Large Cabinet',
            'price': 320.0,
            'template_id': 11,
            'image': '/web/image/product.product/17/image_1920',
            'attributes': []
          }
        };

        // act
        final result = FavoriteProductModel.fromWishlistJson(wishlistJson);

        // assert
        expect(result.id, '17');
        expect(result.name, '[E-COM07] Large Cabinet');
        expect(result.brand, 'Brand'); // Default brand from model
        expect(result.price, 320.0);
        expect(result.imageUrl, 'https://bazar-iq.filesdna.com/web/image/product.product/17/image_1920');
        expect(result.category, 'Featured'); // Default category from model
        expect(result.addedAt, isA<DateTime>());
      });

      test('should handle product with attributes', () {
        // arrange
        final wishlistJson = {
          'id': 1,
          'product': {
            'id': 36,
            'name': '[DESK0005] Customizable Desk (Custom, White)',
            'price': 750.0,
            'template_id': 9,
            'image': '/web/image/product.product/36/image_1920',
            'attributes': [
              {
                'attribute_id': 1,
                'attribute_name': 'Legs',
                'value_id': 7,
                'value_name': 'Custom'
              },
              {
                'attribute_id': 2,
                'attribute_name': 'Color',
                'value_id': 3,
                'value_name': 'White'
              }
            ]
          }
        };

        // act
        final result = FavoriteProductModel.fromWishlistJson(wishlistJson);

        // assert
        expect(result.id, '36');
        expect(result.name, '[DESK0005] Customizable Desk (Custom, White)');
        expect(result.brand, 'Brand'); // Default brand from model
        expect(result.price, 750.0);
        expect(result.imageUrl, 'https://bazar-iq.filesdna.com/web/image/product.product/36/image_1920');
        expect(result.category, 'Featured'); // Default category from model
      });

      test('should handle missing product data gracefully', () {
        // arrange
        final wishlistJson = {
          'id': 1,
          'product': {
            'id': 1,
            'name': 'Test Product',
            // Missing price, image, attributes
          },
        };

        // act
        final result = FavoriteProductModel.fromWishlistJson(wishlistJson);

        // assert
        expect(result.id, '1');
        expect(result.name, 'Test Product');
        expect(result.brand, 'Brand'); // Default brand from model
        expect(result.price, 0.0);
        expect(result.imageUrl, null);
        expect(result.category, 'Featured'); // Default category from model
      });

      test('should handle missing image data gracefully', () {
        // arrange
        final wishlistJson = {
          'id': 1,
          'product': {
            'id': 1,
            'name': 'No Image Product',
            'price': 100.0,
            // Missing image
          },
        };

        // act
        final result = FavoriteProductModel.fromWishlistJson(wishlistJson);

        // assert
        expect(result.id, '1');
        expect(result.name, 'No Image Product');
        expect(result.brand, 'Brand'); // Default brand from model
        expect(result.price, 100.0);
        expect(result.imageUrl, null);
        expect(result.category, 'Featured'); // Default category from model
      });

      test('should handle null product gracefully', () {
        // arrange
        final wishlistJson = {
          'id': 1,
          'product': null,
        };

        // act
        final result = FavoriteProductModel.fromWishlistJson(wishlistJson);

        // assert
        expect(result.id, '0'); // Default ID when product is null
        expect(result.name, 'Unknown Product'); // Default name when product is null
        expect(result.brand, 'Brand'); // Default brand from model
        expect(result.price, 0.0);
        expect(result.imageUrl, null);
        expect(result.category, 'Featured'); // Default category from model
      });

      test('should handle empty product gracefully', () {
        // arrange
        final wishlistJson = {
          'id': 1,
          'product': <String, dynamic>{},
        };

        // act
        final result = FavoriteProductModel.fromWishlistJson(wishlistJson);

        // assert
        expect(result.id, '0'); // Default ID when product is empty
        expect(result.name, 'Unknown Product'); // Default name when product is empty
        expect(result.brand, 'Brand'); // Default brand from model
        expect(result.price, 0.0);
        expect(result.imageUrl, null);
        expect(result.category, 'Featured'); // Default category from model
      });
    });
  });
}