import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_language.dart' as domain;
import '../../domain/usecases/update_theme.dart';
import '../../domain/usecases/update_notifications.dart' as domain_notifications;
import '../../domain/usecases/update_settings.dart' as domain_settings;
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/device_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings getSettings;
  final domain.UpdateLanguage updateLanguage;
  final UpdateTheme updateTheme;
  final domain_notifications.UpdateNotifications updateNotifications;
  final domain_settings.UpdateSettings updateSettings;

  SettingsBloc({
    required this.getSettings,
    required this.updateLanguage,
    required this.updateTheme,
    required this.updateNotifications,
    required this.updateSettings,
  }) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateNotifications>(_onUpdateNotifications);
    on<UpdatePushNotifications>(_onUpdatePushNotifications);
    on<UpdateEmailNotifications>(_onUpdateEmailNotifications);
    on<UpdateSound>(_onUpdateSound);
    on<UpdateVibration>(_onUpdateVibration);
    on<UpdateAutoUpdate>(_onUpdateAutoUpdate);
    on<UpdateLocationServices>(_onUpdateLocationServices);
    on<UpdateAnalytics>(_onUpdateAnalytics);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    
    final result = await getSettings(NoParams());
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await updateLanguage(event.language);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) {
        final currentSettings = _getCurrentSettingsOrNull();
        if (currentSettings != null) {
          final updatedSettings = currentSettings.copyWith(language: event.language);
          emit(SettingsUpdated(updatedSettings));
        }
      },
    );
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await updateTheme(event.themeMode);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) {
        final currentSettings = _getCurrentSettingsOrNull();
        if (currentSettings != null) {
          final updatedSettings = currentSettings.copyWith(themeMode: event.themeMode);
          emit(SettingsUpdated(updatedSettings));
        }
      },
    );
  }

  Future<void> _onUpdateNotifications(
    UpdateNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await updateNotifications(event.enabled);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) {
        final currentSettings = _getCurrentSettingsOrNull();
        if (currentSettings != null) {
          final updatedSettings = currentSettings.copyWith(
            notificationsEnabled: event.enabled,
            pushNotificationsEnabled: event.enabled,
            emailNotificationsEnabled: event.enabled,
          );
          emit(SettingsUpdated(updatedSettings));
        }
      },
    );
  }

  Future<void> _onUpdatePushNotifications(
    UpdatePushNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    final currentSettings = _getCurrentSettingsOrNull();
    if (currentSettings == null) return;

    // When enabling push notifications, request OS permission + FCM token
    if (event.enabled) {
      // If Firebase is not initialized (e.g. dev environment without FCM),
      // skip FCM registration but still allow the toggle to be enabled.
      final firebaseApps = Firebase.apps;
      final firebaseAvailable = firebaseApps.isNotEmpty;

      if (firebaseAvailable) {
        final deviceService = DeviceService();
        final fcmToken = await deviceService.getFcmToken();

        if (fcmToken == null) {
          // Permission was denied or token could not be obtained
          debugPrint('🔕 Push notifications permission not granted or FCM token is null');

          // Ensure the setting stays disabled and persisted
          final revertedSettings = currentSettings.copyWith(
            pushNotificationsEnabled: false,
          );
          emit(SettingsUpdated(revertedSettings));
          await updateSettings(revertedSettings);
          return;
        }

        debugPrint('🔔 Push notifications enabled with FCM token: $fcmToken');
      } else {
        debugPrint('ℹ️ Firebase not initialized – enabling local push setting without FCM registration');
      }
    }

    // For both enable / disable flows, persist the new value
    final updatedSettings = currentSettings.copyWith(
      pushNotificationsEnabled: event.enabled,
    );
    emit(SettingsUpdated(updatedSettings));
    await updateSettings(updatedSettings);
  }

  Future<void> _onUpdateEmailNotifications(
    UpdateEmailNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    final currentSettings = _getCurrentSettingsOrNull();
    if (currentSettings != null) {
      final updatedSettings = currentSettings.copyWith(
        emailNotificationsEnabled: event.enabled,
      );
      emit(SettingsUpdated(updatedSettings));
    }
  }

  Future<void> _onUpdateSound(
    UpdateSound event,
    Emitter<SettingsState> emit,
  ) async {
    final currentSettings = _getCurrentSettingsOrNull();
    if (currentSettings != null) {
      final updatedSettings = currentSettings.copyWith(
        soundEnabled: event.enabled,
      );
      emit(SettingsUpdated(updatedSettings));
    }
  }

  Future<void> _onUpdateVibration(
    UpdateVibration event,
    Emitter<SettingsState> emit,
  ) async {
    final currentSettings = _getCurrentSettingsOrNull();
    if (currentSettings != null) {
      final updatedSettings = currentSettings.copyWith(
        vibrationEnabled: event.enabled,
      );
      emit(SettingsUpdated(updatedSettings));
    }
  }

  Future<void> _onUpdateAutoUpdate(
    UpdateAutoUpdate event,
    Emitter<SettingsState> emit,
  ) async {
    final currentSettings = _getCurrentSettingsOrNull();
    if (currentSettings != null) {
      final updatedSettings = currentSettings.copyWith(
        autoUpdateEnabled: event.enabled,
      );
      emit(SettingsUpdated(updatedSettings));
      await updateSettings(updatedSettings);
    }
  }

  Future<void> _onUpdateLocationServices(
    UpdateLocationServices event,
    Emitter<SettingsState> emit,
  ) async {
    final currentSettings = _getCurrentSettingsOrNull();
    if (currentSettings != null) {
      final updatedSettings = currentSettings.copyWith(
        locationServicesEnabled: event.enabled,
      );
      emit(SettingsUpdated(updatedSettings));
      await updateSettings(updatedSettings);
      
      // If enabling location services, request permission
      if (event.enabled) {
        final locationService = LocationService();
        final hasPermission = await locationService.requestLocationPermission();
        if (!hasPermission) {
          // Permission denied - could emit an error state or show a message
          // For now, we'll just log it. The UI can check permission status separately
          debugPrint('Location permission not granted');
        }
      }
    }
  }

  Future<void> _onUpdateAnalytics(
    UpdateAnalytics event,
    Emitter<SettingsState> emit,
  ) async {
    final currentSettings = _getCurrentSettingsOrNull();
    if (currentSettings != null) {
      final updatedSettings = currentSettings.copyWith(
        analyticsEnabled: event.enabled,
      );
      emit(SettingsUpdated(updatedSettings));
      await updateSettings(updatedSettings);
      
      // If disabling analytics, reset analytics data
      if (!event.enabled) {
        final analyticsService = AnalyticsService();
        await analyticsService.resetAnalyticsData();
        debugPrint('Analytics disabled - data reset');
      }
    }
  }

  Settings? _getCurrentSettingsOrNull() {
    if (state is SettingsLoaded) return (state as SettingsLoaded).settings;
    if (state is SettingsUpdated) return (state as SettingsUpdated).settings;
    return null;
  }
}
