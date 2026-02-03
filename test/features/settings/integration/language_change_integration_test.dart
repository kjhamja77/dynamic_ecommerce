import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../lib/core/services/app_localization_service.dart';
import '../../../../lib/core/services/first_launch_service.dart';

void main() {
  group('Language Change Integration Tests', () {
    setUp(() async {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should persist language change across app restarts', () async {
      // Initialize services
      final localizationService = AppLocalizationService();
      final firstLaunchService = FirstLaunchService();
      
      await localizationService.initialize();
      
      // Initially should be Arabic (default)
      expect(localizationService.currentLocale.languageCode, 'ar');
      
      // Change to English
      await localizationService.setLanguage('en');
      
      // Verify immediate change
      expect(localizationService.currentLocale.languageCode, 'en');
      expect(localizationService.isRTL, false);
      
      // Verify persistence by creating new service instance
      final newLocalizationService = AppLocalizationService();
      await newLocalizationService.initialize();
      
      expect(newLocalizationService.currentLocale.languageCode, 'en');
      expect(newLocalizationService.isRTL, false);
      
      // Verify language selection is marked
      expect(await firstLaunchService.hasSelectedLanguage(), true);
    });

    test('should handle RTL properly for Arabic', () async {
      final localizationService = AppLocalizationService();
      await localizationService.initialize();
      
      // Set to Arabic
      await localizationService.setLanguage('ar');
      
      expect(localizationService.currentLocale.languageCode, 'ar');
      expect(localizationService.isRTL, true);
      expect(localizationService.textDirection, TextDirection.rtl);
    });

    test('should handle LTR properly for English', () async {
      final localizationService = AppLocalizationService();
      await localizationService.initialize();
      
      // Set to English
      await localizationService.setLanguage('en');
      
      expect(localizationService.currentLocale.languageCode, 'en');
      expect(localizationService.isRTL, false);
      expect(localizationService.textDirection, TextDirection.ltr);
    });

    test('should sync with first launch service', () async {
      final firstLaunchService = FirstLaunchService();
      
      // Initially language not selected
      expect(await firstLaunchService.hasSelectedLanguage(), false);
      expect(await firstLaunchService.shouldShowLanguageSelection(), true);
      
      // Manually mark language as selected (this is what the UI does)
      await firstLaunchService.markLanguageSelected();
      
      // Should mark language as selected
      expect(await firstLaunchService.hasSelectedLanguage(), true);
      
      // Mark first launch completed
      await firstLaunchService.markFirstLaunchCompleted();
      
      // Should no longer show language selection
      expect(await firstLaunchService.shouldShowLanguageSelection(), false);
    });

    test('should handle invalid language codes gracefully', () async {
      final localizationService = AppLocalizationService();
      await localizationService.initialize();
      
      // Try to set invalid language
      await localizationService.setLanguage('invalid');
      
      // Should create locale anyway (Flutter handles fallback)
      expect(localizationService.currentLocale.languageCode, 'invalid');
      
      // Reset to valid language
      await localizationService.setLanguage('en');
      expect(localizationService.currentLocale.languageCode, 'en');
    });

    test('should notify listeners on language change', () async {
      final localizationService = AppLocalizationService();
      await localizationService.initialize();
      
      bool notified = false;
      localizationService.addListener(() {
        notified = true;
      });
      
      final currentLang = localizationService.currentLocale.languageCode;
      final newLang = currentLang == 'ar' ? 'en' : 'ar';
      
      // Change to different language
      await localizationService.setLanguage(newLang);
      
      // Should have notified listeners
      expect(notified, true);
    });

    test('should maintain state consistency', () async {
      final localizationService = AppLocalizationService();
      await localizationService.initialize();
      
      // Test multiple rapid changes
      await localizationService.setLanguage('en');
      await localizationService.setLanguage('ar');
      await localizationService.setLanguage('en');
      
      // Final state should be English
      expect(localizationService.currentLocale.languageCode, 'en');
      expect(localizationService.isRTL, false);
      
      // Should persist correctly
      final newService = AppLocalizationService();
      await newService.initialize();
      expect(newService.currentLocale.languageCode, 'en');
    });
  });
}
