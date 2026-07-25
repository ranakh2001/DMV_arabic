import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dmv/core/localization/app_localizations_delegate.dart';
import 'package:dmv/core/storage/storage_providers.dart';
import 'package:dmv/core/theme/app_theme.dart';
import 'package:dmv/features/exam/presentation/screens/exam_question_screen.dart';

/// Throwaway entrypoint used only to visually verify the exam screen without
/// going through the (backend-gated) auth flow. Not part of the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
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
      home: const ExamQuestionScreen(),
    );
  }
}
