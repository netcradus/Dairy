import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported default map/navigation apps.
enum NavigationApp { googleMaps, appleMaps, waze }

/// Persisted application settings for the user-facing app.
class AppSettings {
  final bool notificationsEnabled;
  final bool pushNotifications;
  final bool emailNotifications;
  final NavigationApp navigationApp;
  final String languageCode;
  final ThemeMode themeMode;

  const AppSettings({
    this.notificationsEnabled = true,
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.navigationApp = NavigationApp.googleMaps,
    this.languageCode = 'en',
    this.themeMode = ThemeMode.system,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? pushNotifications,
    bool? emailNotifications,
    NavigationApp? navigationApp,
    String? languageCode,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      navigationApp: navigationApp ?? this.navigationApp,
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// Manages [AppSettings] and persists every change to [SharedPreferences].
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  static const String _kNotifications = 'settings_notifications_enabled';
  static const String _kPush = 'settings_push_notifications';
  static const String _kEmail = 'settings_email_notifications';
  static const String _kNavApp = 'settings_navigation_app';
  static const String _kLang = 'settings_language_code';
  static const String _kTheme = 'settings_theme_mode';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = AppSettings(
        notificationsEnabled: prefs.getBool(_kNotifications) ?? true,
        pushNotifications: prefs.getBool(_kPush) ?? true,
        emailNotifications: prefs.getBool(_kEmail) ?? true,
        navigationApp:
            NavigationApp.values[prefs.getInt(_kNavApp) ?? 0],
        languageCode: prefs.getString(_kLang) ?? 'en',
        themeMode: ThemeMode.values.firstWhere(
          (e) => e.name == (prefs.getString(_kTheme) ?? 'system'),
          orElse: () => ThemeMode.system,
        ),
      );
    } catch (_) {
      // Keep defaults on failure.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kNotifications, state.notificationsEnabled);
      await prefs.setBool(_kPush, state.pushNotifications);
      await prefs.setBool(_kEmail, state.emailNotifications);
      await prefs.setInt(_kNavApp, state.navigationApp.index);
      await prefs.setString(_kLang, state.languageCode);
      await prefs.setString(_kTheme, state.themeMode.name);
    } catch (_) {
      // Ignore persistence failures.
    }
  }

  void updateNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
    _save();
  }

  void updatePushNotifications(bool value) {
    state = state.copyWith(pushNotifications: value);
    _save();
  }

  void updateEmailNotifications(bool value) {
    state = state.copyWith(emailNotifications: value);
    _save();
  }

  void updateNavigationApp(NavigationApp value) {
    state = state.copyWith(navigationApp: value);
    _save();
  }

  void updateLanguage(String code) {
    state = state.copyWith(languageCode: code);
    _save();
  }

  void updateThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _save();
  }
}

/// Global, persistent settings provider for the user app.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
