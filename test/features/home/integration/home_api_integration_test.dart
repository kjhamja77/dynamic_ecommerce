import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/home/data/models/page_model.dart';

void main() {
  group('Home API Integration Tests', () {
    test('should have correct PageModel structure for API integration', () {
      // Test that PageModel can handle the actual API response format
      final apiResponse = {
        'id': 1,
        'name': 'Fashion',
        'description': 'Fashion pages',
      };

      final page = PageModel.fromJson(apiResponse);

      expect(page.id, equals(1));
      expect(page.name, equals('Fashion'));
      expect(page.title, equals('Fashion')); // PageModel uses name as title
      expect(page.description, equals('Fashion pages'));
      expect(page.icon, isNull); // API doesn't provide icon
      expect(page.order, isNull); // API doesn't provide order
      expect(page.isActive, equals(true)); // Default to true
      expect(page.createdAt, isNull); // API doesn't provide timestamps
      expect(page.updatedAt, isNull);
    });

    test('should handle API response with false description', () {
      // Test handling of false description from API
      final apiResponse = {
        'id': 22,
        'name': 'Trends',
        'description': false,
      };

      final page = PageModel.fromJson(apiResponse);

      expect(page.id, equals(22));
      expect(page.name, equals('Trends'));
      expect(page.title, equals('Trends'));
      expect(page.description, isNull); // false should be converted to null
    });
  });
}
