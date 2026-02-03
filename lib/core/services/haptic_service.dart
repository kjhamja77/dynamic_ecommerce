import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  /// Light haptic feedback for button clicks and taps
  static Future<void> buttonClick() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error providing haptic feedback: $e');
    }
  }

  /// Medium haptic feedback for selection changes
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error providing haptic feedback: $e');
    }
  }

  /// Heavy haptic feedback for important actions
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error providing haptic feedback: $e');
    }
  }

  /// Medium haptic feedback for medium impact actions
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error providing haptic feedback: $e');
    }
  }

  /// Light haptic feedback for light impact actions
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error providing haptic feedback: $e');
    }
  }

  /// Vibrate for notification or alert
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      debugPrint('Error providing haptic feedback: $e');
    }
  }

  /// Success haptic feedback for successful actions
  static Future<void> success() async {
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error providing haptic feedback: $e');
    }
  }

  /// Error haptic feedback for failed actions
  static Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error providing haptic feedback: $e');
    }
  }

  /// Warning haptic feedback for warnings
  static Future<void> warning() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error providing haptic feedback: $e');
    }
  }

  /// Long press haptic feedback
  static Future<void> longPress() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error providing haptic feedback: $e');
    }
  }
}

