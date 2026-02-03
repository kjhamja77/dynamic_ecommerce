# Filters Feature v2 - BLoC Architecture

This is a clean, BLoC-based implementation of the filters feature.

## Structure

```
filters_v2/
├── domain/          (symlinked to ../filters/domain)
├── data/            (symlinked to ../filters/data)
└── presentation/
    ├── bloc/
    │   ├── filters_event.dart    # All filter events
    │   ├── filters_state.dart    # Filter states
    │   └── filters_bloc.dart     # Main BLoC implementation
    ├── pages/
    │   ├── filters_page.dart           # Main filters UI
    │   └── filters_loading_page.dart   # Loading page
    └── widgets/
        └── filters_shimmer.dart        # Loading shimmer
```

## Key Features

### BLoC Pattern
- **Events**: All user actions are represented as events
- **States**: Clear state management with `FiltersLoaded`, `FiltersLoading`, `FiltersError`
- **BLoC**: Clean separation of business logic from UI

### Events
- `FiltersInitialized` - Initialize with criteria
- `FiltersCriteriaUpdated` - Update entire criteria
- `FiltersOnSaleToggled` - Toggle on sale
- `FiltersInStockToggled` - Toggle in stock
- `FiltersMinPriceSet` / `FiltersMaxPriceSet` - Price range
- `FiltersBrandIdsSet` / `FiltersCategoryIdsSet` - IDs
- `FiltersSizesSet` / `FiltersColorsSet` / etc. - Attributes
- `FiltersCleared` - Reset all filters

### States
- `FiltersInitial` - Initial state
- `FiltersLoaded` - Filters ready with criteria and subcategories
- `FiltersLoading` - Loading state
- `FiltersError` - Error state

## Usage

```dart
// In your page
final criteria = await Navigator.push<FilterCriteria>(
  MaterialPageRoute(
    builder: (_) => FiltersLoadingPage(
      initial: FilterCriteria(...),
      category: category,
      brand: brand,
      query: query,
    ),
  ),
);

if (criteria != null) {
  // Apply filters
  bloc.add(UpdateCatalogFilters(filterCriteria: criteria));
}
```

## Benefits

1. **Clean Architecture**: Clear separation of concerns
2. **Testable**: Easy to test BLoC logic independently
3. **Maintainable**: Well-structured, easy to extend
4. **Type-Safe**: Strong typing with events and states
5. **Reactive**: UI automatically updates on state changes



