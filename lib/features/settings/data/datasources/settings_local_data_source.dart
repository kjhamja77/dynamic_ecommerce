import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/settings.dart';
import '../../domain/entities/language.dart';
import '../models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<Settings> getSettings();
  Future<void> saveSettings(Settings settings);
  Future<Language> getCurrentLanguage();
  Future<void> saveLanguage(Language language);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String _settingsKey = 'app_settings';
  static const String _languageKey = 'app_language';

  SettingsLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<Settings> getSettings() async {
    try {
      final settingsJson = sharedPreferences.getString(_settingsKey);
      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
        return SettingsModel.fromJson(settingsMap);
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
    
    // Return default settings if none found
    return Settings.defaultSettings;
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    try {
      final settingsModel = SettingsModel.fromSettings(settings);
      final settingsJson = json.encode(settingsModel.toJson());
      await sharedPreferences.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving settings: $e');
      rethrow;
    }
  }

  @override
  Future<Language> getCurrentLanguage() async {
    try {
      final languageCode = sharedPreferences.getString(_languageKey);
      if (languageCode != null) {
        final language = Language.supportedLanguages.firstWhere(
          (lang) => lang.code.code == languageCode,
          orElse: () => Language.defaultLanguage,
        );
        return language;
      }
    } catch (e) {
      print('Error loading language: $e');
    }
    
    return Language.defaultLanguage;
  }

  @override
  Future<void> saveLanguage(Language language) async {
    try {
      await sharedPreferences.setString(_languageKey, language.code.code);
    } catch (e) {
      print('Error saving language: $e');
      rethrow;
    }
  }
}
