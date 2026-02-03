import '../entities/sort_option.dart';

class GetSortOptions {
  const GetSortOptions();

  List<SortOption> call() {
    // Note: These are placeholder labels that will be replaced with localized strings
    // in the presentation layer. The domain layer should not depend on BuildContext.
    return [
      const SortOption(
        value: 'price_asc',
        label: 'PRICE_LOW_TO_HIGH', // Will be replaced with localized string
        subtitle: 'BEST_DEALS_FIRST', // Will be replaced with localized string
        type: SortType.priceLowToHigh,
      ),
      const SortOption(
        value: 'price_desc',
        label: 'PRICE_HIGH_TO_LOW', // Will be replaced with localized string
        subtitle: 'PREMIUM_PICKS_FIRST', // Will be replaced with localized string
        type: SortType.priceHighToLow,
      ),
      const SortOption(
        value: 'newest',
        label: 'NEWEST', // Will be replaced with localized string
        subtitle: 'LATEST_ARRIVALS', // Will be replaced with localized string
        type: SortType.newest,
      ),
      const SortOption(
        value: 'featured',
        label: 'FEATURED', // Will be replaced with localized string
        subtitle: 'EDITORS_PICKS', // Will be replaced with localized string
        type: SortType.featured,
      ),
    ];
  }
}
