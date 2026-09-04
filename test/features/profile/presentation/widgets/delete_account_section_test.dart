import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dmv/core/errors/failure.dart';
import 'package:dmv/core/localization/app_localizations_delegate.dart';
import 'package:dmv/core/localization/strings_ar.dart';
import 'package:dmv/core/utils/result.dart';
import 'package:dmv/features/auth/domain/repositories/auth_repository.dart';
import 'package:dmv/features/auth/domain/usecases/logout_usecase.dart';
import 'package:dmv/features/auth/presentation/providers/auth_providers.dart';
import 'package:dmv/features/profile/domain/repositories/profile_repository.dart';
import 'package:dmv/features/profile/domain/usecases/delete_account_usecase.dart';
import 'package:dmv/features/profile/presentation/providers/profile_providers.dart';
import 'package:dmv/features/profile/presentation/widgets/delete_account_section.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

Widget _wrap(
  Widget child, {
  required _MockProfileRepository profileRepository,
  required _MockAuthRepository authRepository,
}) {
  return ProviderScope(
    overrides: [
      deleteAccountUsecaseProvider.overrideWithValue(
        DeleteAccountUsecase(profileRepository),
      ),
      logoutUsecaseProvider.overrideWithValue(LogoutUsecase(authRepository)),
    ],
    child: MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  late _MockProfileRepository profileRepository;
  late _MockAuthRepository authRepository;

  setUp(() {
    profileRepository = _MockProfileRepository();
    authRepository = _MockAuthRepository();
    when(
      () => profileRepository.deleteAccount(),
    ).thenAnswer((_) async => const Result.success(null));
    when(
      () => authRepository.logout(),
    ).thenAnswer((_) async => const Result.success(null));
  });

  testWidgets('cancelling the confirmation dialog does not delete the account', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const DeleteAccountSection(),
        profileRepository: profileRepository,
        authRepository: authRepository,
      ),
    );

    await tester.tap(find.text(stringsAr['profile.delete_account']!));
    await tester.pumpAndSettle();

    expect(
      find.text(stringsAr['profile.delete_account.confirm_message']!),
      findsOneWidget,
    );

    await tester.tap(find.text(stringsAr['common.cancel']!));
    await tester.pumpAndSettle();

    expect(
      find.text(stringsAr['profile.delete_account.confirm_message']!),
      findsNothing,
    );
    verifyNever(() => profileRepository.deleteAccount());
    verifyNever(() => authRepository.logout());
  });

  testWidgets('confirming the dialog deletes the account and logs out', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const DeleteAccountSection(),
        profileRepository: profileRepository,
        authRepository: authRepository,
      ),
    );

    await tester.tap(find.text(stringsAr['profile.delete_account']!));
    await tester.pumpAndSettle();

    await tester.tap(find.text(stringsAr['common.confirm']!));
    await tester.pumpAndSettle();

    verify(() => profileRepository.deleteAccount()).called(1);
    verify(() => authRepository.logout()).called(1);
  });

  testWidgets(
    'shows an error snackbar and stays logged in when deletion fails',
    (tester) async {
      when(() => profileRepository.deleteAccount()).thenAnswer(
        (_) async => const Result.failure(
          ApiFailureStub('تعذر حذف الحساب. حاول مرة أخرى.'),
        ),
      );

      await tester.pumpWidget(
        _wrap(
          const DeleteAccountSection(),
          profileRepository: profileRepository,
          authRepository: authRepository,
        ),
      );

      await tester.tap(find.text(stringsAr['profile.delete_account']!));
      await tester.pumpAndSettle();

      await tester.tap(find.text(stringsAr['common.confirm']!));
      await tester.pumpAndSettle();

      expect(find.text('تعذر حذف الحساب. حاول مرة أخرى.'), findsOneWidget);
      verifyNever(() => authRepository.logout());
    },
  );
}

/// Minimal [Failure] stand-in so the failure test doesn't need to import
/// the concrete `ApiFailure` type just to supply a message.
class ApiFailureStub extends Failure {
  const ApiFailureStub(String message) : super(messageAr: message);
}
