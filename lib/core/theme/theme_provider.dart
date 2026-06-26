import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_providers.dart';
import '../constants/app_constants.dart';

/// Exposes and persists [ThemeMode]. Default: dark (per SRS).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final raw = ref.read(prefsServiceProvider).getString(AppConstants.themePrefsKey);
    return _fromString(raw);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(prefsServiceProvider).setString(AppConstants.themePrefsKey, mode.name);
  }

  Future<void> toggle() async {
    await setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  static ThemeMode _fromString(String? raw) => switch (raw) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark, // default dark
      };
}

/// Global provider for [ThemeMode].
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
