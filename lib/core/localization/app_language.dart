import 'package:flutter/material.dart';

import 'app_strings_en.dart';
import 'app_strings_hi.dart';

/// Central language state for the whole app.
///
/// The Riverpod [settingsProvider] remains the single source of truth (it
/// persists the choice and drives `MaterialApp.locale`). Whenever it rebuilds,
/// `MyApp` calls [AppLanguage.setLanguage] so the global lookup used by [tr]
/// stays in sync. Because changing `MaterialApp.locale` rebuilds the entire
/// widget tree below it, every screen re-evaluates its [tr] calls and the new
/// language is reflected immediately — no restart required.
class AppLanguage {
  AppLanguage._();

  static const String defaultCode = 'en';
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  static String _code = defaultCode;

  /// Currently active language code ('en' or 'hi').
  static String get code => _code;

  /// Whether the app is currently running in Hindi.
  static bool get isHindi => _code == 'hi';

  /// Update the active language. Ignored for unsupported codes.
  static void setLanguage(String code) {
    if (supportedLocales.any((l) => l.languageCode == code)) {
      _code = code;
    }
  }
}

/// Translate [key] into the active language.
///
/// Keys are the canonical English strings, so in English mode this simply
/// returns the registered English text (or the key itself if not yet
/// registered). In Hindi mode it returns the Hindi translation, falling back
/// to English when a translation is missing — the app never shows raw keys.
String tr(String key) {
  if (!AppLanguage.isHindi) {
    return appStringsEn[key] ?? key;
  }
  return appStringsHi[key] ?? appStringsEn[key] ?? key;
}
