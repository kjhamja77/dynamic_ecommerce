import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../lib/features/language_selection/presentation/pages/language_selection_page.dart';
import '../../../../../lib/core/services/app_localization_service.dart';
import '../../../../../lib/core/services/first_launch_service.dart';

void main() {
  group('LanguageSelectionPage', () {
    setUpAll(() async {
      // Initialize SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display language selection options', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: const LanguageSelectionPage(),
            routes: {
              '/main': (context) => const Scaffold(body: Text('Main Page')),
            },
          ),
        ),
      );

      // Wait for the widget to fully build
      await tester.pumpAndSettle();

      // Verify that the welcome text is displayed
      expect(find.text('Welcome to Bazar'), findsOneWidget);
      expect(find.text('Choose your preferred language'), findsOneWidget);

      // Verify that both language options are displayed
      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // Verify that the subtitle text is displayed
      expect(find.text('You can change this later in settings'), findsOneWidget);
    });

    testWidgets('should navigate to main page when language is selected', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: const LanguageSelectionPage(),
            routes: {
              '/main': (context) => const Scaffold(body: Text('Main Page')),
            },
          ),
        ),
      );

      // Wait for the widget to fully build
      await tester.pumpAndSettle();

      // Tap on Arabic language option
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      // Wait for navigation delay and processing
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify that we navigated to the main page
      expect(find.text('Main Page'), findsOneWidget);
    });

    testWidgets('should show selection animation when language is tapped', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: const LanguageSelectionPage(),
            routes: {
              '/main': (context) => const Scaffold(body: Text('Main Page')),
            },
          ),
        ),
      );

      // Wait for the widget to fully build
      await tester.pumpAndSettle();

      // Find the English language option container
      final englishOption = find.ancestor(
        of: find.text('English'),
        matching: find.byType(AnimatedContainer),
      ).first;

      // Tap on English language option
      await tester.tap(englishOption);
      await tester.pump(); // Start animation
      
      // Verify the selection state changes
      final container = tester.widget<AnimatedContainer>(englishOption);
      final decoration = container.decoration as BoxDecoration;
      
      // The border should change when selected
      expect(decoration.border, isNotNull);
    });
  });

  group('FirstLaunchService', () {
    setUp(() async {
      // Reset shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should return true for first launch initially', () async {
      final service = FirstLaunchService();
      final isFirst = await service.isFirstLaunch();
      expect(isFirst, true);
    });

    test('should return false after marking first launch completed', () async {
      final service = FirstLaunchService();
      
      // Initially should be first launch
      expect(await service.isFirstLaunch(), true);
      
      // Mark as completed
      await service.markFirstLaunchCompleted();
      
      // Should no longer be first launch
      expect(await service.isFirstLaunch(), false);
    });

    test('should return true for shouldShowLanguageSelection initially', () async {
      final service = FirstLaunchService();
      final shouldShow = await service.shouldShowLanguageSelection();
      expect(shouldShow, true);
    });

    test('should return false for shouldShowLanguageSelection after language selected', () async {
      final service = FirstLaunchService();
      
      // Initially should show language selection
      expect(await service.shouldShowLanguageSelection(), true);
      
      // Mark language as selected and first launch completed
      await service.markLanguageSelected();
      await service.markFirstLaunchCompleted();
      
      // Should no longer show language selection
      expect(await service.shouldShowLanguageSelection(), false);
    });
  });

  group('AppLocalizationService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('should set and persist language preference', () async {
      final service = AppLocalizationService();
      await service.initialize();
      
      // Initially should be Arabic (default)
      expect(service.currentLocale.languageCode, 'ar');
      
      // Change to English
      await service.setLanguage('en');
      expect(service.currentLocale.languageCode, 'en');
      
      // Create new instance to test persistence
      final newService = AppLocalizationService();
      await newService.initialize();
      expect(newService.currentLocale.languageCode, 'en');
    });

    test('should provide correct RTL information', () async {
      final service = AppLocalizationService();
      await service.initialize();
      
      // Arabic should be RTL
      await service.setLanguage('ar');
      expect(service.isRTL, true);
      expect(service.textDirection, TextDirection.rtl);
      
      // English should be LTR
      await service.setLanguage('en');
      expect(service.isRTL, false);
      expect(service.textDirection, TextDirection.ltr);
    });
  });
}
