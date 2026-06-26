import 'package:flutter/widgets.dart';
import 'strings_ar.dart';
import 'strings_en.dart';

/// Runtime localization accessor. Reached via [context.t('key')].
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Translates [key]; falls back to the key itself if not found.
  String t(String key) {
    final map = locale.languageCode == 'ar' ? stringsAr : stringsEn;
    return map[key] ?? key;
  }

  /// Convenience: translates with named placeholder substitution.
  /// e.g. t('auth.verify.subtitle', {'contact': '+1 555 555 5555'})
  String ts(String key, Map<String, String> args) {
    var result = t(key);
    for (final entry in args.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }
}

/// Extension for ergonomic access: [context.t('key')].
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Shorthand: [context.t('key')].
  String t(String key) => l10n.t(key);

  /// Shorthand with args: [context.ts('key', {'var': 'value'})].
  String ts(String key, Map<String, String> args) => l10n.ts(key, args);
}
