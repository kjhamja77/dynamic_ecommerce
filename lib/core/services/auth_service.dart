import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Clear the authentication token and trigger logout
  Future<void> handleTokenExpiration() async {
    debugPrint('🔐 AuthService:handleTokenExpiration → Clearing token and triggering logout');
    
    try {
      // Clear the stored token
      await _storage.delete(key: AppConstants.tokenKey);
      debugPrint('✅ AuthService:handleTokenExpiration → Token cleared successfully');
    } catch (e) {
      debugPrint('❌ AuthService:handleTokenExpiration → Error clearing token: $e');
    }
  }

  /// Check if token exists and is valid
  Future<bool> hasValidToken() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('❌ AuthService:hasValidToken → Error checking token: $e');
      return false;
    }
  }

  /// Get the current token
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.tokenKey);
    } catch (e) {
      debugPrint('❌ AuthService:getToken → Error getting token: $e');
      return null;
    }
  }
}
