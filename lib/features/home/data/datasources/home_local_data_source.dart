import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/page_model.dart';
import '../models/component_model.dart';

abstract class HomeLocalDataSource {
  Future<void> cachePages({
    required int userId,
    required String languageCode,
    required List<PageModel> pages,
  });

  Future<List<PageModel>?> getCachedPages({
    required int userId,
    required String languageCode,
  });

  /// Clear cached pages and timestamps for a specific user + language.
  Future<void> clearPages({
    required int userId,
    required String languageCode,
  });

  Future<void> cachePageComponents({
    required int componentId,
    required int page,
    required int pageSize,
    required String languageCode,
    required PageComponentsModel components,
  });

  Future<PageComponentsModel?> getCachedPageComponents({
    required int componentId,
    required int page,
    required int pageSize,
    required String languageCode,
  });

  /// Clear cached page components (and timestamp) for a specific component
  /// + pagination + language combination.
  Future<void> clearPageComponents({
    required int componentId,
    required int page,
    required int pageSize,
    required String languageCode,
  });

  Future<void> cacheWelcomeTexts({
    required String languageCode,
    required List<String> messages,
  });

  Future<List<String>?> getCachedWelcomeTexts({
    required String languageCode,
  });

  /// Clear cached welcome texts for the given language.
  Future<void> clearWelcomeTexts({
    required String languageCode,
  });

  /// Clear all home-related caches (pages, components, welcome texts).
  /// Used on logout so the next user does not see the previous user's cached home data.
  Future<void> clearAllCachesForLogout();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  static const Duration _pagesTtl = Duration(minutes: 10);
  static const Duration _componentsTtl = Duration(minutes: 5);
  static const Duration _welcomeTextsTtl = Duration(minutes: 30);

  final SharedPreferences _prefs;

  HomeLocalDataSourceImpl(this._prefs);

  String _pagesKey(int userId, String languageCode) =>
      'home_pages_${languageCode}_u$userId';
  String _pagesTsKey(int userId, String languageCode) =>
      'home_pages_${languageCode}_u${userId}_ts';

  String _componentsKey(
    int componentId,
    int page,
    int pageSize,
    String languageCode,
  ) =>
      'home_page_components_${languageCode}_$componentId\_$page\_$pageSize';
  String _componentsTsKey(
    int componentId,
    int page,
    int pageSize,
    String languageCode,
  ) =>
      'home_page_components_${languageCode}_$componentId\_$page\_${pageSize}_ts';

  String _welcomeKey(String languageCode) =>
      'home_welcome_texts_$languageCode';
  String _welcomeTsKey(String languageCode) =>
      'home_welcome_texts_${languageCode}_ts';

  bool _isExpired(int? timestampMillis, Duration ttl) {
    if (timestampMillis == null) return true;
    final cachedAt =
        DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: false);
    final age = DateTime.now().difference(cachedAt);
    return age > ttl;
  }

  @override
  Future<void> cachePages({
    required int userId,
    required String languageCode,
    required List<PageModel> pages,
  }) async {
    final key = _pagesKey(userId, languageCode);
    final tsKey = _pagesTsKey(userId, languageCode);

    final jsonList = pages.map((p) => p.toJson()).toList();
    await _prefs.setString(key, jsonEncode(jsonList));
    await _prefs.setInt(tsKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<List<PageModel>?> getCachedPages({
    required int userId,
    required String languageCode,
  }) async {
    final key = _pagesKey(userId, languageCode);
    final tsKey = _pagesTsKey(userId, languageCode);

    final ts = _prefs.getInt(tsKey);
    if (_isExpired(ts, _pagesTtl)) return null;

    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PageModel.fromJson)
          .toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearPages({
    required int userId,
    required String languageCode,
  }) async {
    final key = _pagesKey(userId, languageCode);
    final tsKey = _pagesTsKey(userId, languageCode);
    await _prefs.remove(key);
    await _prefs.remove(tsKey);
  }

  @override
  Future<void> cachePageComponents({
    required int componentId,
    required int page,
    required int pageSize,
    required String languageCode,
    required PageComponentsModel components,
  }) async {
    final key =
        _componentsKey(componentId, page, pageSize, languageCode);
    final tsKey =
        _componentsTsKey(componentId, page, pageSize, languageCode);

    final jsonMap = components.toJson();
    await _prefs.setString(key, jsonEncode(jsonMap));
    await _prefs.setInt(tsKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<PageComponentsModel?> getCachedPageComponents({
    required int componentId,
    required int page,
    required int pageSize,
    required String languageCode,
  }) async {
    final key =
        _componentsKey(componentId, page, pageSize, languageCode);
    final tsKey =
        _componentsTsKey(componentId, page, pageSize, languageCode);

    final ts = _prefs.getInt(tsKey);
    if (_isExpired(ts, _componentsTtl)) return null;

    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return PageComponentsModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearPageComponents({
    required int componentId,
    required int page,
    required int pageSize,
    required String languageCode,
  }) async {
    final key =
        _componentsKey(componentId, page, pageSize, languageCode);
    final tsKey =
        _componentsTsKey(componentId, page, pageSize, languageCode);
    await _prefs.remove(key);
    await _prefs.remove(tsKey);
  }

  @override
  Future<void> cacheWelcomeTexts({
    required String languageCode,
    required List<String> messages,
  }) async {
    final key = _welcomeKey(languageCode);
    final tsKey = _welcomeTsKey(languageCode);

    await _prefs.setString(key, jsonEncode(messages));
    await _prefs.setInt(tsKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<List<String>?> getCachedWelcomeTexts({
    required String languageCode,
  }) async {
    final key = _welcomeKey(languageCode);
    final tsKey = _welcomeTsKey(languageCode);

    final ts = _prefs.getInt(tsKey);
    if (_isExpired(ts, _welcomeTextsTtl)) return null;

    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearWelcomeTexts({
    required String languageCode,
  }) async {
    final key = _welcomeKey(languageCode);
    final tsKey = _welcomeTsKey(languageCode);
    await _prefs.remove(key);
    await _prefs.remove(tsKey);
  }

  @override
  Future<void> clearAllCachesForLogout() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('home_')).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}

