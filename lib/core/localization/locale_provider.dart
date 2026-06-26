import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_providers.dart';
import '../constants/app_constants.dart';

/// Manages the active [Locale] and persists it to shared_preferences.
/// Default locale: Arabic (per SRS).
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final raw = ref.read(prefsServiceProvider).getString(AppConstants.localePrefsKey);
    return Locale(raw ?? AppConstants.defaultLocale);
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

/// Global provider for the active [Locale].
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
