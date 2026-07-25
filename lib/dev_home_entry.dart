import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dmv/core/localization/app_localizations_delegate.dart';
import 'package:dmv/core/storage/storage_providers.dart';
import 'package:dmv/core/theme/app_theme.dart';
import 'package:dmv/features/auth/domain/entities/auth_user.dart';
import 'package:dmv/features/auth/presentation/providers/auth_controller_provider.dart';
import 'package:dmv/features/home/presentation/screens/main_shell_screen.dart';
import 'package:dmv/features/subscription/presentation/providers/subscription_provider.dart';

/// Throwaway entrypoint used only to visually verify the home shell without
/// going through the (backend-gated) auth flow. Not part of the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  container.read(authControllerProvider.notifier).setAuthenticated(
        const AuthUser(id: 'dev-user', name: 'Dev User', phone: '+11234567890'),
      );
  container.read(paywallDismissedProvider.notifier).state = true;

  runApp(UncontrolledProviderScope(container: container, child: const _DevApp()));
}

class _DevApp extends StatelessWidget {
  const _DevApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(context),
      darkTheme: AppTheme.dark(context),
      themeMode: ThemeMode.dark,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainShellScreen(),
    );
  }
}
