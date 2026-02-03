import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();

  String? _cachedDeviceId;
  String? _cachedFcmToken;

  /// Get unique device ID
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    try {
      if (kIsWeb) {
        // For web, use a combination of user agent and a generated UUID
        final webBrowserInfo = await _deviceInfo.webBrowserInfo;
        _cachedDeviceId = 'web_${webBrowserInfo.userAgent?.hashCode ?? _uuid.v4()}';
      } else {
        // For mobile platforms
        if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await _deviceInfo.androidInfo;
          _cachedDeviceId = androidInfo.id;
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iosInfo = await _deviceInfo.iosInfo;
          _cachedDeviceId = iosInfo.identifierForVendor ?? _uuid.v4();
        } else {
          // Fallback for other platforms
          _cachedDeviceId = _uuid.v4();
        }
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      _cachedDeviceId = _uuid.v4();
    }

    return _cachedDeviceId!;
  }

  /// Get FCM token
  Future<String?> getFcmToken() async {
    if (_cachedFcmToken != null) {
      return _cachedFcmToken;
    }

    try {
      // Check if Firebase is initialized
      final firebaseApps = Firebase.apps;
      if (firebaseApps.isEmpty) {
        debugPrint('Firebase not initialized, returning null FCM token');
        return null;
      }

      // Get FirebaseMessaging instance safely
      final firebaseMessaging = FirebaseMessaging.instance;
      
      // Request permission for notifications
      final settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        _cachedFcmToken = await firebaseMessaging.getToken();
      } else {
        debugPrint('Notification permission denied');
        _cachedFcmToken = null;
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      _cachedFcmToken = null;
    }

    return _cachedFcmToken;
  }

  /// Refresh FCM token (useful when token changes)
  Future<String?> refreshFcmToken() async {
    _cachedFcmToken = null;
    return await getFcmToken();
  }

  /// Get both device ID and FCM token
  Future<Map<String, String?>> getDeviceInfo() async {
    final deviceId = await getDeviceId();
    final fcmToken = await getFcmToken();
    
    return {
      'device_id': deviceId,
      'device_token': fcmToken,
    };
  }
}
