import '../repositories/catalog_repository.dart';

/// Simple use case to clear the in-memory catalog cache.
/// Used when the user changes language so that product lists
/// are reloaded from the API in the new locale.
class ClearCatalogCache {
  final CatalogRepository repository;

  const ClearCatalogCache(this.repository);

  void call() {
    repository.clearCache();
  }
}

