import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/localization/app_localizations_delegate.dart';
import '../core/localization/locale_provider.dart';
import '../core/routing/app_router.dart';
import '../core/security/app_shield.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../core/widgets/connectivity_banner.dart';

/// Root widget. Wires theme, locale, RTL, and app-switcher shield.
/// Navigation is handled by [AuthGate] — no routing package required.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'DMV بالعربي',
      debugShowCheckedModeBanner: false,

      themeMode: themeMode,
      theme: AppTheme.light(context),
      darkTheme: AppTheme.dark(context),

      locale: locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, child) => AppShield(child: ConnectivityBanner(child: child!)),
      home: const AuthGate(),
    );
  }
}
