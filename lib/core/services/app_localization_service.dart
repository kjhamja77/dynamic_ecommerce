import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'first_launch_service.dart';
import 'language_service.dart';

class AppLocalizationService extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  Locale _currentLocale = const Locale('ar');
  bool _isChangingLanguage = false;
  
  Locale get currentLocale => _currentLocale;
  
  bool get isRTL => _currentLocale.languageCode == 'ar';
  
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;
  bool get isChangingLanguage => _isChangingLanguage;
  
  static final AppLocalizationService _instance = AppLocalizationService._internal();
  factory AppLocalizationService() => _instance;
  AppLocalizationService._internal();
  
  Future<void> initialize() async {
    await _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        _currentLocale = Locale(languageCode);
        // Ensure the app treats language as decided when cached
        await FirstLaunchService().markLanguageSelected();
        // Ensure API language header is synced from cached app language
        await LanguageService().setFromAppLanguageCode(languageCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;

    _currentLocale = locale;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      
      // Mark language as selected when user changes it
      await FirstLaunchService().markLanguageSelected();

      // Sync API Accept-Language code with selected app language
      await LanguageService().setFromAppLanguageCode(locale.languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
    
    notifyListeners();
  }
  
  Future<void> setLanguage(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  /// Explicitly mark the beginning of a language change operation so that
  /// the UI can show a global loader while API‑driven content reloads.
  void beginLanguageChange() {
    if (_isChangingLanguage) return;
    _isChangingLanguage = true;
    notifyListeners();
  }

  /// Mark the end of a language change. An optional delay can be provided
  /// to keep the loader visible while downstream BLoCs refresh their data.
  /// We use a slightly larger default delay so that the user does not see
  /// texts switching one‑by‑one on slow networks.
  Future<void> endLanguageChange({Duration delay = const Duration(milliseconds: 1500)}) async {
    if (!_isChangingLanguage) return;
    if (delay.inMilliseconds > 0) {
      await Future.delayed(delay);
    }
    _isChangingLanguage = false;
    notifyListeners();
  }
  
  // Helper method to get localized text with RTL support
  Widget buildLocalizedText(String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      style: style,
      textAlign: textAlign ?? (isRTL ? TextAlign.right : TextAlign.left),
      maxLines: maxLines,
      overflow: overflow,
      textDirection: textDirection,
    );
  }
  
  // Helper method to get localized widget with RTL support
  Widget buildLocalizedWidget(Widget child) {
    return Directionality(
      textDirection: textDirection,
      child: child,
    );
  }
}
