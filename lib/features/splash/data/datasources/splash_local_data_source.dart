import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';

abstract class SplashLocalDataSource {
  Future<bool> isAppInitialized();
  Future<void> markAppAsInitialized();
  Future<bool> shouldShowLanguageSelection();
  Future<bool> isUserAuthenticated();
}

class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage _secureStorage;
  // Align with onboarding flag to avoid duplicated keys causing onboarding to reappear
  static const String _appInitializedKey = 'onboarding_completed';

  SplashLocalDataSourceImpl(this.sharedPreferences, this._secureStorage);

  @override
  Future<bool> isAppInitialized() async {
    return sharedPreferences.getBool(_appInitializedKey) ?? false;
  }

  @override
  Future<void> markAppAsInitialized() async {
    await sharedPreferences.setBool(_appInitializedKey, true);
  }

  @override
  Future<bool> shouldShowLanguageSelection() async {
    // Check if it's first launch or if language hasn't been selected
    final firstLaunchCompleted = sharedPreferences.getBool('first_launch_completed') ?? false;
    final languageSelected = sharedPreferences.getBool('language_selected') ?? false;
    
    return !firstLaunchCompleted || !languageSelected;
  }

  @override
  Future<bool> isUserAuthenticated() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
