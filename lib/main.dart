import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/injection_container.dart' as di;
import 'core/app/app_theme.dart';
import 'core/app/app_router.dart';
import 'core/app/app_bloc_observer.dart';
import 'core/navigation/navigation_service.dart';
import 'core/app/app_providers.dart';
import 'core/services/app_localization_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/connectivity_navigation_service.dart';
import 'core/providers/currency_provider.dart';
import 'l10n/app_localizations.dart';
import 'core/services/app_restart.dart';
import 'core/widgets/app_loading_widget.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/settings/domain/entities/settings.dart' as settings_domain;

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // Lock orientation to portrait only
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
        
      // Initialize Firebase first (with error handling)
      try {
        await Firebase.initializeApp();
        print('✅ Firebase initialized successfully');
      } catch (e) {
        print('⚠️ Firebase initialization failed: $e');
        print('App will continue without Firebase services');
      }
      
      await di.init();
      
      // Initialize localization service
      await AppLocalizationService().initialize();
      
      // Initialize connectivity service
      await ConnectivityService().initialize();
      
      // Initialize connectivity navigation service
      ConnectivityNavigationService().initialize();

      FlutterError.onError = (FlutterErrorDetails 
      details) {
        FlutterError.dumpErrorToConsole(details);
      };

      Bloc.observer = AppBlocObserver();

      runApp(const AppRoot());
    },
    (error, stackTrace) {
      // Handle FlutterSecureStorage decryption errors gracefully
      if (error is PlatformException && 
          error.code == 'read' && 
          (error.message?.contains('BAD_DECRYPT') == true || 
           error.message?.contains('BadPaddingException') == true)) {
        // This is expected when secure storage is corrupted (e.g., after app reinstall)
        // The error is already handled in AuthWrapper and ApiClient, so we can ignore it here
        debugPrint('⚠️ Zone: Corrupted secure storage detected (handled gracefully)');
        return;
      }
      // Log other uncaught errors
      debugPrint('❌ Uncaught zone error: $error');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
    },
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: createAppBlocProviders(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CurrencyProvider()..initializeCurrency()),
          ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812), // iPhone X design size
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return ListenableBuilder(
              listenable: AppLocalizationService(),
              builder: (context, child) {
                final localizationService = AppLocalizationService();
                return BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, settingsState) {
                    // Load settings on first build if not already loaded
                    if (settingsState is SettingsInitial) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.read<SettingsBloc>().add(LoadSettings());
                      });
                    }
                    
                    // Get theme mode from settings or default to system
                    ThemeMode themeMode = ThemeMode.system;
                    if (settingsState is SettingsLoaded) {
                      themeMode = AppRoot._convertToFlutterThemeMode(settingsState.settings.themeMode);
                    } else if (settingsState is SettingsUpdated) {
                      themeMode = AppRoot._convertToFlutterThemeMode(settingsState.settings.themeMode);
                    }
                    
                    return AppRestart(
                      child: MaterialApp(
                        title: 'Kardosi',
                        debugShowCheckedModeBanner: false,
                        theme: buildLightTheme(),
                        darkTheme: buildDarkTheme(),
                        themeMode: themeMode,
                        navigatorKey: NavigationService.navigatorKey,
                        initialRoute: '/',
                        onGenerateRoute: AppRouter.onGenerateRoute,
                        
                        // Localization support
                        localizationsDelegates: const [
                          AppLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                          CountryLocalizations.delegate,
                        ],
                        supportedLocales: const [
                          Locale('ar'), // Arabic (default)
                          Locale('en'), // English
                        ],
                        locale: localizationService.currentLocale,
                        
                        // RTL support + global language-change loader overlay
                        builder: (context, child) {
                          // Base app content with correct text direction and
                          // global tap-to-unfocus behavior.
                          Widget content = GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => FocusScope.of(context).unfocus(),
                            onPanDown: (_) => FocusScope.of(context).unfocus(),
                            child: Directionality(
                              textDirection: localizationService.textDirection,
                              child: child!,
                            ),
                          );

                          // When language is being changed, show a full-screen
                          // skeleton/loader overlay above the entire app.
                          if (localizationService.isChangingLanguage) {
                            content = Stack(
                              children: [
                                content,
                                Positioned.fill(
                                  child: Container(
                                    // Use near-opaque background so the user
                                    // doesn't see texts changing one‑by‑one
                                    // underneath while language is switching.
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background
                                        .withValues(alpha: 0.95),
                                    child: Center(
                                      child: AppLoadingWidget.large(
                                        message: AppLocalizations.of(context)?.changingLanguage,
                                        showMessage: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return content;
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
  
  /// Convert custom ThemeMode enum to Flutter's ThemeMode
  static ThemeMode _convertToFlutterThemeMode(settings_domain.ThemeMode mode) {
    switch (mode) {
      case settings_domain.ThemeMode.light:
        return ThemeMode.light;
      case settings_domain.ThemeMode.dark:
        return ThemeMode.dark;
      case settings_domain.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}

// AuthWrapper and helpers moved under core/app