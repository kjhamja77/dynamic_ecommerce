import 'package:shared_preferences/shared_preferences.dart';

class SearchLocalDataSource {
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecent = 10;

  final SharedPreferences sharedPreferences;

  SearchLocalDataSource({required this.sharedPreferences});

  List<String> getRecentSearches() {
    final list = sharedPreferences.getStringList(_recentSearchesKey);
    return list ?? <String>[];
  }

  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final current = List<String>.from(getRecentSearches());
    // Remove existing duplicate (case-insensitive)
    current.removeWhere(
      (q) => q.toLowerCase().trim() == trimmed.toLowerCase(),
    );
    current.insert(0, trimmed);
    if (current.length > _maxRecent) {
      current.removeRange(_maxRecent, current.length);
    }
    await sharedPreferences.setStringList(_recentSearchesKey, current);
  }

  Future<void> clearRecentSearches() async {
    await sharedPreferences.remove(_recentSearchesKey);
  }
}





