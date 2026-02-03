import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/catalog/domain/usecases/get_sort_options.dart';
import 'package:zalando_clone_app/features/catalog/domain/entities/sort_option.dart';

void main() {
  group('GetSortOptions', () {
    late GetSortOptions useCase;

    setUp(() {
      useCase = const GetSortOptions();
    });

    test('should return list of sort options', () {
      // Act
      final result = useCase();

      // Assert
      expect(result, isA<List<SortOption>>());
      expect(result.length, 4);
    });

    test('should return correct sort options with proper values', () {
      // Act
      final result = useCase();

      // Assert
      expect(result[0].value, 'price_asc');
      expect(result[0].label, 'PRICE_LOW_TO_HIGH');
      expect(result[0].subtitle, 'BEST_DEALS_FIRST');
      expect(result[0].type, SortType.priceLowToHigh);

      expect(result[1].value, 'price_desc');
      expect(result[1].label, 'PRICE_HIGH_TO_LOW');
      expect(result[1].subtitle, 'PREMIUM_PICKS_FIRST');
      expect(result[1].type, SortType.priceHighToLow);

      expect(result[2].value, 'newest');
      expect(result[2].label, 'NEWEST');
      expect(result[2].subtitle, 'LATEST_ARRIVALS');
      expect(result[2].type, SortType.newest);

      expect(result[3].value, 'featured');
      expect(result[3].label, 'FEATURED');
      expect(result[3].subtitle, 'EDITORS_PICKS');
      expect(result[3].type, SortType.featured);
    });

    test('should have unique values for all sort options', () {
      // Act
      final result = useCase();

      // Assert
      final values = result.map((option) => option.value).toList();
      expect(values.toSet().length, equals(values.length));
    });

    test('should have unique labels for all sort options', () {
      // Act
      final result = useCase();

      // Assert
      final labels = result.map((option) => option.label).toList();
      expect(labels.toSet().length, equals(labels.length));
    });
  });
}
