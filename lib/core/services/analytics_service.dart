import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../core/di/injection_container.dart' as di;

/// Service for analytics tracking that respects user's analytics setting
class AnalyticsService {
  final SettingsRepository _settingsRepository = di.sl<SettingsRepository>();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool? _cachedAnalyticsEnabled;

  /// Check if analytics are enabled in settings
  Future<bool> isAnalyticsEnabled() async {
    try {
      final result = await _settingsRepository.getSettings();
      return result.fold(
        (_) => false,
        (settings) {
          _cachedAnalyticsEnabled = settings.analyticsEnabled;
          return settings.analyticsEnabled;
        },
      );
    } catch (e) {
      debugPrint('Error checking analytics setting: $e');
      // Use cached value if available, otherwise default to false
      return _cachedAnalyticsEnabled ?? false;
    }
  }

  /// Log an event (only if analytics are enabled)
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    final enabled = await isAnalyticsEnabled();
    if (!enabled) {
      debugPrint('Analytics disabled - not logging event: $name');
      return;
    }

    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('Analytics event logged: $name ${parameters != null ? 'with params: $parameters' : ''}');
    } catch (e) {
      debugPrint('Error logging analytics event: $e');
    }
  }

  /// Set user property (only if analytics are enabled)
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    final enabled = await isAnalyticsEnabled();
    if (!enabled) {
      debugPrint('Analytics disabled - not setting user property: $name');
      return;
    }

    try {
      await _analytics.setUserProperty(name: name, value: value);
      debugPrint('Analytics user property set: $name = $value');
    } catch (e) {
      debugPrint('Error setting analytics user property: $e');
    }
  }

  /// Set user ID (only if analytics are enabled)
  Future<void> setUserId(String? userId) async {
    final enabled = await isAnalyticsEnabled();
    if (!enabled) {
      debugPrint('Analytics disabled - not setting user ID');
      return;
    }

    try {
      await _analytics.setUserId(id: userId);
      debugPrint('Analytics user ID set: $userId');
    } catch (e) {
      debugPrint('Error setting analytics user ID: $e');
    }
  }

  /// Log screen view (only if analytics are enabled)
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    final enabled = await isAnalyticsEnabled();
    if (!enabled) {
      debugPrint('Analytics disabled - not logging screen view: $screenName');
      return;
    }

    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      debugPrint('Analytics screen view logged: $screenName');
    } catch (e) {
      debugPrint('Error logging analytics screen view: $e');
    }
  }

  /// Reset analytics data (when user disables analytics)
  Future<void> resetAnalyticsData() async {
    try {
      await _analytics.resetAnalyticsData();
      debugPrint('Analytics data reset');
    } catch (e) {
      debugPrint('Error resetting analytics data: $e');
    }
  }
}

