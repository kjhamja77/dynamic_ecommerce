import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchService {
  static const String _firstLaunchKey = 'first_launch_completed';
  static const String _languageSelectedKey = 'language_selected';

  static final FirstLaunchService _instance = FirstLaunchService._internal();
  factory FirstLaunchService() => _instance;
  FirstLaunchService._internal();

  /// Check if this is the first launch of the app
  Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool(_firstLaunchKey) ?? false);
    } catch (e) {
      // If there's an error, assume it's first launch to be safe
      return true;
    }
  }

  /// Check if user has selected a language before
  Future<bool> hasSelectedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_languageSelectedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mark first launch as completed
  Future<void> markFirstLaunchCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstLaunchKey, true);
    } catch (e) {
      // Log error but don't throw - this is not critical
      debugPrint('Error marking first launch completed: $e');
    }
  }

  /// Mark language as selected
  Future<void> markLanguageSelected() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_languageSelectedKey, true);
    } catch (e) {
      debugPrint('Error marking language selected: $e');
    }
  }

  /// Reset first launch status (for testing purposes)
  Future<void> resetFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_firstLaunchKey);
      await prefs.remove(_languageSelectedKey);
    } catch (e) {
      debugPrint('Error resetting first launch: $e');
    }
  }

  /// Check if we should show language selection
  /// This is true if it's first launch OR if user hasn't selected a language
  Future<bool> shouldShowLanguageSelection() async {
    final isFirst = await isFirstLaunch();
    final hasLang = await hasSelectedLanguage();
    return isFirst || !hasLang;
  }
}
