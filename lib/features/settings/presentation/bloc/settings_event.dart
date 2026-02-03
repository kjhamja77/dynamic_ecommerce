import 'package:equatable/equatable.dart';
import '../../domain/entities/settings.dart';
import '../../domain/entities/language.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateLanguage extends SettingsEvent {
  final Language language;

  const UpdateLanguage(this.language);

  @override
  List<Object?> get props => [language];
}

class UpdateThemeMode extends SettingsEvent {
  final ThemeMode themeMode;

  const UpdateThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class UpdateNotifications extends SettingsEvent {
  final bool enabled;

  const UpdateNotifications(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdatePushNotifications extends SettingsEvent {
  final bool enabled;

  const UpdatePushNotifications(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateEmailNotifications extends SettingsEvent {
  final bool enabled;

  const UpdateEmailNotifications(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateSound extends SettingsEvent {
  final bool enabled;

  const UpdateSound(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateVibration extends SettingsEvent {
  final bool enabled;

  const UpdateVibration(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateAutoUpdate extends SettingsEvent {
  final bool enabled;

  const UpdateAutoUpdate(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateLocationServices extends SettingsEvent {
  final bool enabled;

  const UpdateLocationServices(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateAnalytics extends SettingsEvent {
  final bool enabled;

  const UpdateAnalytics(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
