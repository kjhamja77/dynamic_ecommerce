import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart' as la;
import 'package:flutter/services.dart';
import '../../domain/entities/biometric_settings.dart';

abstract class BiometricLocalDataSource {
  Future<bool> isBiometricAvailable();
  Future<BiometricType> getAvailableBiometricType();
  Future<bool> authenticateWithBiometric();
  Future<BiometricSettings> getBiometricSettings();
  Future<BiometricSettings> updateBiometricSettings(BiometricSettings settings);
}

class BiometricLocalDataSourceImpl implements BiometricLocalDataSource {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricTypeKey = 'biometric_type';
  static const String _lastUsedKey = 'biometric_last_used';

  final la.LocalAuthentication _localAuth = la.LocalAuthentication();

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return isSupported && canCheck;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<BiometricType> getAvailableBiometricType() async {
    try {
      final available = await _localAuth.getAvailableBiometrics();
      if (available.contains(la.BiometricType.face)) {
        return BiometricType.faceId;
      }
      if (available.contains(la.BiometricType.fingerprint) || available.contains(la.BiometricType.strong) || available.contains(la.BiometricType.weak)) {
        return BiometricType.fingerprint;
      }
      return BiometricType.none;
    } catch (_) {
      return BiometricType.none;
    }
  }

  @override
  Future<bool> authenticateWithBiometric() async {
    try {
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Authenticate to continue',
        options: const la.AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return didAuth;
    } on PlatformException catch (e) {
      // Map common local_auth error codes to user-friendly messages
      final code = e.code;
      String message;
      switch (code) {
        case 'NotAvailable':
          message = 'Biometric authentication is not available on this device';
          break;
        case 'NotEnrolled':
          message = 'No biometrics enrolled. Please add a fingerprint or Face ID';
          break;
        case 'LockedOut':
          message = 'Biometrics locked. Try again later or use your passcode';
          break;
        case 'PermanentlyLockedOut':
          message = 'Biometrics permanently locked. Use your passcode to unlock';
          break;
        case 'PasscodeNotSet':
          message = 'Device passcode is not set. Set a passcode to use biometrics';
          break;
        case 'NotInteractive':
          message = 'Cannot show biometric prompt right now';
          break;
        default:
          message = e.message ?? 'Biometric authentication failed';
      }
      throw Exception(message);
    }
  }

  @override
  Future<BiometricSettings> getBiometricSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final isEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
    final biometricTypeString = prefs.getString(_biometricTypeKey) ?? 'fingerprint';
    final lastUsedString = prefs.getString(_lastUsedKey);
    
    BiometricType biometricType;
    switch (biometricTypeString) {
      case 'fingerprint':
        biometricType = BiometricType.fingerprint;
        break;
      case 'faceId':
        biometricType = BiometricType.faceId;
        break;
      default:
        biometricType = BiometricType.none;
    }
    
    final isAvailable = await isBiometricAvailable();
    final lastUsed = lastUsedString != null ? DateTime.parse(lastUsedString) : null;
    
    return BiometricSettings(
      isEnabled: isEnabled,
      biometricType: biometricType,
      isAvailable: isAvailable,
      lastUsed: lastUsed,
    );
  }

  @override
  Future<BiometricSettings> updateBiometricSettings(BiometricSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_biometricEnabledKey, settings.isEnabled);
    await prefs.setString(_biometricTypeKey, settings.biometricType.name);
    
    if (settings.lastUsed != null) {
      await prefs.setString(_lastUsedKey, settings.lastUsed!.toIso8601String());
    } else {
      await prefs.remove(_lastUsedKey);
    }
    
    return settings;
  }
}
