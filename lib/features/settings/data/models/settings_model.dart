import '../../domain/entities/settings.dart';
import 'language_model.dart';

class SettingsModel extends Settings {
  const SettingsModel({
    required super.language,
    required super.themeMode,
    required super.notificationsEnabled,
    required super.pushNotificationsEnabled,
    required super.emailNotificationsEnabled,
    required super.soundEnabled,
    required super.vibrationEnabled,
    required super.autoUpdateEnabled,
    required super.locationServicesEnabled,
    required super.analyticsEnabled,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      language: LanguageModel.fromJson(json['language'] as Map<String, dynamic>),
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled: json['emailNotificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      autoUpdateEnabled: json['autoUpdateEnabled'] as bool? ?? true,
      locationServicesEnabled: json['locationServicesEnabled'] as bool? ?? false,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': LanguageModel.fromLanguage(language).toJson(),
      'themeMode': themeMode.name,
      'notificationsEnabled': notificationsEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'autoUpdateEnabled': autoUpdateEnabled,
      'locationServicesEnabled': locationServicesEnabled,
      'analyticsEnabled': analyticsEnabled,
    };
  }

  factory SettingsModel.fromSettings(Settings settings) {
    return SettingsModel(
      language: settings.language,
      themeMode: settings.themeMode,
      notificationsEnabled: settings.notificationsEnabled,
      pushNotificationsEnabled: settings.pushNotificationsEnabled,
      emailNotificationsEnabled: settings.emailNotificationsEnabled,
      soundEnabled: settings.soundEnabled,
      vibrationEnabled: settings.vibrationEnabled,
      autoUpdateEnabled: settings.autoUpdateEnabled,
      locationServicesEnabled: settings.locationServicesEnabled,
      analyticsEnabled: settings.analyticsEnabled,
    );
  }
}
