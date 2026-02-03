import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../core/di/injection_container.dart' as di;

/// Service for managing location permissions and access
/// Respects user's location services setting from Settings
class LocationService {
  final SettingsRepository _settingsRepository = di.sl<SettingsRepository>();

  /// Check if location services are enabled in settings
  Future<bool> isLocationServicesEnabled() async {
    try {
      final result = await _settingsRepository.getSettings();
      return result.fold(
        (_) => false,
        (settings) => settings.locationServicesEnabled,
      );
    } catch (e) {
      debugPrint('Error checking location services setting: $e');
      return false;
    }
  }

  /// Request location permission (only if location services are enabled in settings)
  Future<bool> requestLocationPermission() async {
    // First check if user has enabled location services in settings
    final isEnabled = await isLocationServicesEnabled();
    if (!isEnabled) {
      debugPrint('Location services disabled in settings');
      return false;
    }

    try {
      // Check current permission status
      final status = await Permission.location.status;
      
      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        // Request permission
        final result = await Permission.location.request();
        return result.isGranted;
      }

      if (status.isPermanentlyDenied) {
        // Permission was denied permanently, user needs to enable in settings
        debugPrint('Location permission permanently denied');
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  /// Open app settings to allow user to enable location permission
  Future<bool> openLocationSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }
}


