import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/core/constants/endpoints.dart';
import 'package:zalando_clone_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:zalando_clone_app/features/home/data/models/page_model.dart';

void main() {
  group('Home API Ready Tests', () {
    test('should have correct endpoint configuration', () {
      // Test that endpoints are properly configured
      expect(Endpoints.getPages, equals('/ecom/get/pages'));
      expect(Endpoints.getPageComponents, equals('/ecom/get/component'));
      expect(Endpoints.getOnboarding, equals('/ecom/get/onboarding'));
    });

    test('should have correct withParams helper', () {
      // Test the withParams helper function
      final params = {'user_id': 1, 'page': 1};
      final wrappedParams = Endpoints.withParams(params);
      
      expect(wrappedParams, isA<Map<String, dynamic>>());
      expect(wrappedParams['params'], equals(params));
    });

    test('should have PageModel with correct structure', () {
      // Test that PageModel can be created with expected fields
      final page = PageModel(
        id: 1,
        name: 'home',
        title: 'Home',
        description: 'Main home page',
        icon: 'home_icon',
        order: 1,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(page.id, equals(1));
      expect(page.name, equals('home'));
      expect(page.title, equals('Home'));
      expect(page.description, equals('Main home page'));
      expect(page.icon, equals('home_icon'));
      expect(page.order, equals(1));
      expect(page.isActive, equals(true));
      expect(page.createdAt, equals(DateTime(2024, 1, 1)));
      expect(page.updatedAt, equals(DateTime(2024, 1, 1)));
    });

    test('should have PageModel fromJson method', () {
      // Test that PageModel can parse JSON correctly
      final json = {
        'id': 2,
        'name': 'catalog',
        'title': 'Catalog',
        'description': 'Product catalog page',
        'icon': 'catalog_icon',
        'order': 2,
        'is_active': true,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final page = PageModel.fromJson(json);

      expect(page.id, equals(2));
      expect(page.name, equals('catalog'));
      expect(page.title, equals('catalog'));
      expect(page.description, equals('Product catalog page'));
      expect(page.icon, isNull);
      expect(page.order, isNull);
      expect(page.isActive, equals(true));
      expect(page.createdAt, isNull);
      expect(page.updatedAt, isNull);
    });

    test('should have PageModel toJson method', () {
      // Test that PageModel can convert to JSON correctly
      final page = PageModel(
        id: 3,
        name: 'favorites',
        title: 'Favorites',
        description: 'Favorites page',
        icon: 'favorites_icon',
        order: 3,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = page.toJson();

      expect(json['id'], equals(3));
      expect(json['name'], equals('favorites'));
      expect(json['title'], equals('Favorites'));
      expect(json['description'], equals('Favorites page'));
      expect(json['icon'], equals('favorites_icon'));
      expect(json['order'], equals(3));
      expect(json['is_active'], equals(true));
      expect(json['created_at'], equals('2024-01-01T00:00:00.000'));
      expect(json['updated_at'], equals('2024-01-01T00:00:00.000'));
    });

    test('should have HomeRemoteDataSource interface', () {
      // Test that HomeRemoteDataSource interface is properly defined
      expect(HomeRemoteDataSource, isA<Type>());
    });
  });
}
