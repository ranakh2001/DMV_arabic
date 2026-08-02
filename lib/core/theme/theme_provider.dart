import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_providers.dart';
import '../constants/app_constants.dart';

/// Exposes and persists [ThemeMode]. Default: system (follows device).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final raw = ref
        .read(prefsServiceProvider)
        .getString(AppConstants.themePrefsKey);
    return _fromString(raw);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref
        .read(prefsServiceProvider)
        .setString(AppConstants.themePrefsKey, mode.name);
  }

  /// Cycles: system → dark → light → system
  Future<void> toggle() async {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.system,
    };
    await setMode(next);
  }

  static ThemeMode _fromString(String? raw) => switch (raw) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    'system' => ThemeMode.system,
    _ => ThemeMode.system,
  };
}

/// Global provider for [ThemeMode].
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
