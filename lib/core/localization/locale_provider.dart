import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_providers.dart';
import '../constants/app_constants.dart';

/// Manages the active [Locale] and persists it to shared_preferences.
/// First launch: follows the device locale if supported (ar/en), else Arabic.
class LocaleNotifier extends Notifier<Locale> {
  static const _supported = ['ar', 'en'];

  @override
  Locale build() {
    final saved = ref.read(prefsServiceProvider).getString(AppConstants.localePrefsKey);
    if (saved != null && _supported.contains(saved)) return Locale(saved);
    return const Locale('ar');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref
        .read(prefsServiceProvider)
        .setString(AppConstants.localePrefsKey, locale.languageCode);
  }

  Future<void> toggle() async {
    await setLocale(state.languageCode == 'ar' ? const Locale('en') : const Locale('ar'));
  }

  bool get isArabic => state.languageCode == 'ar';
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
