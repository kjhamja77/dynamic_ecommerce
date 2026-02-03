import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingCompleted();
  Future<void> completeOnboarding();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _onboardingCompletedKey = 'onboarding_completed';

  OnboardingLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<bool> isOnboardingCompleted() async {
    return sharedPreferences.getBool(_onboardingCompletedKey) ?? false;
  }

  @override
  Future<void> completeOnboarding() async {
    await sharedPreferences.setBool(_onboardingCompletedKey, true);
  }
}
