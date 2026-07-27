/// App-wide constants that don't belong to a specific feature.
class AppConstants {
  AppConstants._();

  static const String appName = 'DMV بالعربي';
  static const String defaultLocale = 'ar';

  /// Free-tier question quota per session (SRS).
  static const int freeQuotaDefault = 10;

  /// Full simulation exam parameters (SRS).
  static const int examQuestionCount = 46;
  static const int examMinPassCount = 38;

  static const String themePrefsKey = 'theme_mode';
  static const String localePrefsKey = 'locale';
  static const String onboardingDoneKey = 'onboarding_done';
}
