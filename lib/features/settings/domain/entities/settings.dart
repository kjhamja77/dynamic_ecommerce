import 'package:equatable/equatable.dart';
import 'language.dart';

enum ThemeMode {
  light,
  dark,
  system,
}

class Settings extends Equatable {
  final Language language;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool autoUpdateEnabled;
  final bool locationServicesEnabled;
  final bool analyticsEnabled;

  const Settings({
    required this.language,
    required this.themeMode,
    required this.notificationsEnabled,
    required this.pushNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.autoUpdateEnabled,
    required this.locationServicesEnabled,
    required this.analyticsEnabled,
  });

  Settings copyWith({
    Language? language,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? autoUpdateEnabled,
    bool? locationServicesEnabled,
    bool? analyticsEnabled,
  }) {
    return Settings(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoUpdateEnabled: autoUpdateEnabled ?? this.autoUpdateEnabled,
      locationServicesEnabled: locationServicesEnabled ?? this.locationServicesEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }

  static Settings get defaultSettings => Settings(
        language: Language.defaultLanguage,
        themeMode: ThemeMode.system,
        notificationsEnabled: true,
        pushNotificationsEnabled: true,
        emailNotificationsEnabled: true,
        soundEnabled: true,
        vibrationEnabled: true,
        autoUpdateEnabled: true,
        locationServicesEnabled: false,
        analyticsEnabled: true,
      );

  @override
  List<Object?> get props => [
        language,
        themeMode,
        notificationsEnabled,
        pushNotificationsEnabled,
        emailNotificationsEnabled,
        soundEnabled,
        vibrationEnabled,
        autoUpdateEnabled,
        locationServicesEnabled,
        analyticsEnabled,
      ];
}
