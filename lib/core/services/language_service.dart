import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _apiLanguageKey = 'api_language_code';
  static const Map<String, String> _appToApiCode = {
    'ar': 'ar_001',
    'en': 'en_US',
  };

  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  Future<String?> getApiLanguageCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_apiLanguageKey);
      if (stored != null && stored.isNotEmpty) {
        return stored;
      }
      // Fallback: default to Arabic API code on first launch if nothing stored yet
      // This ensures we always send some Accept-Language header for APIs that rely on it.
      return _appToApiCode['ar'];
    } catch (e) {
      debugPrint('LanguageService:getApiLanguageCode error: $e');
      // On any error, also fall back to default Arabic API code
      return _appToApiCode['ar'];
    }
  }

  Future<void> setApiLanguageCode(String apiCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiLanguageKey, apiCode);
    } catch (e) {
      debugPrint('LanguageService:setApiLanguageCode error: $e');
    }
  }

  Future<void> setFromAppLanguageCode(String appLanguageCode) async {
    final apiCode = _appToApiCode[appLanguageCode];
    if (apiCode != null) {
      await setApiLanguageCode(apiCode);
    }
  }
}


