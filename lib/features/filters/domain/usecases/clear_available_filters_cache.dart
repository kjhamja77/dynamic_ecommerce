import '../repositories/filter_repository.dart';

/// Simple use case to clear the in-memory cache of available filters.
/// This is used when the user explicitly refreshes the filters screen
/// so that all filter endpoints are called again.
class ClearAvailableFiltersCache {
  final FilterRepository repository;

  const ClearAvailableFiltersCache(this.repository);

  void call() {
    repository.clearAvailableFiltersCache();
  }
}

