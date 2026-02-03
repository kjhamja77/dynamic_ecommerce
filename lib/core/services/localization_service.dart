import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/domain/entities/language.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  Language _currentLanguage = Language.defaultLanguage;
  Locale _currentLocale = const Locale('en');

  Language get currentLanguage => _currentLanguage;
  Locale get currentLocale => _currentLocale;

  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Future<void> initialize() async {
    await _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        final language = Language.supportedLanguages.firstWhere(
          (lang) => lang.code.code == languageCode,
          orElse: () => Language.defaultLanguage,
        );
        await setLanguage(language);
      }
    } catch (e) {
      print('Error loading language: $e');
    }
  }

  Future<void> setLanguage(Language language) async {
    if (_currentLanguage.code != language.code) {
      _currentLanguage = language;
      _currentLocale = Locale(language.code.code);
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, language.code.code);
      } catch (e) {
        print('Error saving language: $e');
      }
      
      notifyListeners();
    }
  }

  String getString(String key) {
    // Simple localization - in a real app, you'd use a proper localization package
    switch (_currentLanguage.code) {
      case LanguageCode.english:
        return _getEnglishString(key);
      case LanguageCode.arabic:
        return _getArabicString(key);
      default:
        return _getEnglishString(key);
    }
  }

  String _getEnglishString(String key) {
    switch (key) {
      case 'settings':
        return 'Settings';
      case 'language_region':
        return 'Language & Region';
      case 'appearance':
        return 'Appearance';
      case 'notifications':
        return 'Notifications';
      case 'app_settings':
        return 'App Settings';
      case 'about':
        return 'About';
      case 'select_language':
        return 'Select Language';
      case 'theme':
        return 'Theme';
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System';
      case 'use_light_theme':
        return 'Use light theme';
      case 'use_dark_theme':
        return 'Use dark theme';
      case 'follow_system_theme':
        return 'Follow system theme';
      case 'push_notifications':
        return 'Push Notifications';
      case 'receive_push_notifications':
        return 'Receive push notifications';
      case 'email_notifications':
        return 'Email Notifications';
      case 'receive_email_notifications':
        return 'Receive email notifications';
      case 'sound':
        return 'Sound';
      case 'play_sound_for_notifications':
        return 'Play sound for notifications';
      case 'vibration':
        return 'Vibration';
      case 'vibrate_for_notifications':
        return 'Vibrate for notifications';
      case 'auto_update':
        return 'Auto Update';
      case 'automatically_update_the_app':
        return 'Automatically update the app';
      case 'location_services':
        return 'Location Services';
      case 'allow_app_to_access_location':
        return 'Allow app to access location';
      case 'analytics':
        return 'Analytics';
      case 'help_improve_the_app_with_analytics':
        return 'Help improve the app with analytics';
      case 'app_version':
        return 'App Version';
      case 'privacy_policy':
        return 'Privacy Policy';
      case 'read_our_privacy_policy':
        return 'Read our privacy policy';
      case 'terms_of_service':
        return 'Terms of Service';
      case 'read_our_terms_of_service':
        return 'Read our terms of service';
      default:
        return key;
    }
  }

  String _getArabicString(String key) {
    switch (key) {
      case 'settings':
        return 'الإعدادات';
      case 'language_region':
        return 'اللغة والمنطقة';
      case 'appearance':
        return 'المظهر';
      case 'notifications':
        return 'الإشعارات';
      case 'app_settings':
        return 'إعدادات التطبيق';
      case 'about':
        return 'حول';
      case 'select_language':
        return 'اختر اللغة';
      case 'theme':
        return 'المظهر';
      case 'light':
        return 'فاتح';
      case 'dark':
        return 'داكن';
      case 'system':
        return 'النظام';
      case 'use_light_theme':
        return 'استخدم المظهر الفاتح';
      case 'use_dark_theme':
        return 'استخدم المظهر الداكن';
      case 'follow_system_theme':
        return 'اتبع مظهر النظام';
      case 'push_notifications':
        return 'الإشعارات الفورية';
      case 'receive_push_notifications':
        return 'استقبل الإشعارات الفورية';
      case 'email_notifications':
        return 'إشعارات البريد الإلكتروني';
      case 'receive_email_notifications':
        return 'استقبل إشعارات البريد الإلكتروني';
      case 'sound':
        return 'الصوت';
      case 'play_sound_for_notifications':
        return 'شغل الصوت للإشعارات';
      case 'vibration':
        return 'الاهتزاز';
      case 'vibrate_for_notifications':
        return 'اهتز للإشعارات';
      case 'auto_update':
        return 'التحديث التلقائي';
      case 'automatically_update_the_app':
        return 'حدث التطبيق تلقائياً';
      case 'location_services':
        return 'خدمات الموقع';
      case 'allow_app_to_access_location':
        return 'اسمح للتطبيق بالوصول للموقع';
      case 'analytics':
        return 'التحليلات';
      case 'help_improve_the_app_with_analytics':
        return 'ساعد في تحسين التطبيق بالتحليلات';
      case 'app_version':
        return 'إصدار التطبيق';
      case 'privacy_policy':
        return 'سياسة الخصوصية';
      case 'read_our_privacy_policy':
        return 'اقرأ سياسة الخصوصية';
      case 'terms_of_service':
        return 'شروط الخدمة';
      case 'read_our_terms_of_service':
        return 'اقرأ شروط الخدمة';
      default:
        return key;
    }
  }
}
