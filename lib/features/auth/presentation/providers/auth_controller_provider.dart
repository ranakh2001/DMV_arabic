import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/notifications/notification_service_provider.dart';
import '../../../../core/notifications/notification_settings_provider.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/utils/result.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../domain/entities/auth_user.dart';
import '../state/auth_state.dart';
import 'auth_providers.dart';

export '../state/auth_state.dart';

/// How long before the access token actually expires to proactively refresh
/// it, so a request never races an about-to-expire token.
const _refreshLeadTime = Duration(seconds: 60);

class AuthController extends Notifier<AuthState> {
  Timer? _refreshTimer;

  @override
  AuthState build() {
    ref.onDispose(() => _refreshTimer?.cancel());
    return const AuthState.initial();
  }

  Future<void> bootstrap() async {
    state = state.copyWith(status: AuthStatus.unknown);
    final result = await ref.read(bootstrapSessionUsecaseProvider).call();
    result.fold(
      onSuccess: (user) async {
        if (user != null) {
          debugPrint('[auth] bootstrap: session restored, showing home');
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
          final expiresAt = await ref
              .read(secureStorageProvider)
              .readTokenExpiry();
          if (expiresAt != null) _scheduleRefresh(expiresAt);
          unawaited(_requestNotificationPermission());
          unawaited(ref.read(subscriptionProvider.notifier).hydrate());
        } else {
          debugPrint('[auth] bootstrap: no valid session, showing welcome');
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
      onFailure: (failure) {
        debugPrint(
          '[auth] bootstrap: failed (${failure.messageEn}), showing welcome',
        );
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure.messageAr,
        );
      },
    );
  }

  void setAuthenticated(AuthUser user, {DateTime? expiresAt}) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      clearError: true,
    );
    if (expiresAt != null) _scheduleRefresh(expiresAt);
    // Fire-and-forget: ask for push permission right after login/verification
    // instead of blocking app startup on it (see bootstrap()).
    unawaited(_requestNotificationPermission());
    unawaited(ref.read(subscriptionProvider.notifier).hydrate());
  }

  Future<void> _requestNotificationPermission() async {
    try {
      await ref.read(notificationServiceProvider).initialize();
      await ref.read(notificationSettingsProvider.notifier).syncTopics();
      await ref
          .read(notificationSettingsProvider.notifier)
          .registerDeviceToken();
    } catch (e) {
      // Push setup is best-effort; login must not fail because of it.
      debugPrint('[notifications] setup failed: $e');
    }
  }

  /// Schedules a proactive token refresh [_refreshLeadTime] before [expiresAt].
  /// Reschedules itself on success; on failure it does nothing further — the
  /// reactive 401 path in [AuthInterceptor] catches a truly dead session on
  /// the next real request.
  void _scheduleRefresh(DateTime expiresAt) {
    _refreshTimer?.cancel();
    final delay = expiresAt
        .subtract(_refreshLeadTime)
        .difference(DateTime.now());
    _refreshTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      _performScheduledRefresh,
    );
  }

  Future<void> _performScheduledRefresh() async {
    final result = await ref.read(refreshTokenUsecaseProvider).call();
    result.fold(
      onSuccess: _scheduleRefresh,
      onFailure: (_) {
        // Leave it: a still-valid token keeps working until it actually
        // expires, and a dead refresh token will surface via the next 401.
      },
    );
  }

  Future<void> logout() async {
    _refreshTimer?.cancel();
    await ref.read(logoutUsecaseProvider).call();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

// ─── Per-form controllers ────────────────────────────────────────────────────

class LoginController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> login({
    required String contact,
    required String password,
  }) async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref
        .read(loginUsecaseProvider)
        .call(contact: contact, password: password);
    result.fold(
      onSuccess: (data) {
        if (data.unverifiedContact != null) {
          state = state.copyWith(
            status: FormStatus.failure,
            error: 'UNVERIFIED:${data.unverifiedContact}',
          );
          return;
        }
        ref
            .read(authControllerProvider.notifier)
            .setAuthenticated(
              data.session!.user,
              expiresAt: data.session!.expiresAt,
            );
        state = state.copyWith(status: FormStatus.success, clearError: true);
      },
      onFailure: (failure) => state = state.copyWith(
        status: FormStatus.failure,
        error: failure.messageAr,
      ),
    );
  }

  void reset() => state = const AuthFormState();
}

final loginControllerProvider =
    NotifierProvider<LoginController, AuthFormState>(LoginController.new);

class RegisterController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> register({
    required String name,
    required String contact,
    required int stateId,
    required String password,
  }) async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref
        .read(registerUsecaseProvider)
        .call(
          name: name,
          contact: contact,
          stateId: stateId,
          password: password,
        );
    result.fold(
      onSuccess: (_) =>
          state = state.copyWith(status: FormStatus.success, clearError: true),
      onFailure: (failure) => state = state.copyWith(
        status: FormStatus.failure,
        error: failure.messageAr,
      ),
    );
  }
}

final registerControllerProvider =
    NotifierProvider<RegisterController, AuthFormState>(RegisterController.new);

class ForgotPasswordController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<Result<void>> send({required String contact}) async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref
        .read(forgotPasswordUsecaseProvider)
        .call(contact: contact);
    result.fold(
      onSuccess: (_) =>
          state = state.copyWith(status: FormStatus.success, clearError: true),
      onFailure: (f) => state = state.copyWith(
        status: FormStatus.failure,
        error: f.messageAr,
      ),
    );
    return result;
  }

  void reset() => state = const AuthFormState();
}

final forgotPasswordControllerProvider =
    NotifierProvider<ForgotPasswordController, AuthFormState>(
      ForgotPasswordController.new,
    );

class ForgotVerifyController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<Result<void>> verify({
    required String contact,
    required String code,
  }) async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref
        .read(verifyResetCodeUsecaseProvider)
        .call(contact: contact, code: code);
    result.fold(
      onSuccess: (_) =>
          state = state.copyWith(status: FormStatus.success, clearError: true),
      onFailure: (f) => state = state.copyWith(
        status: FormStatus.failure,
        error: f.messageAr,
      ),
    );
    return result;
  }

  void reset() => state = const AuthFormState();
}

final forgotVerifyControllerProvider =
    NotifierProvider<ForgotVerifyController, AuthFormState>(
      ForgotVerifyController.new,
    );

class ResetPasswordController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> reset({
    required String contact,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref
        .read(resetPasswordUsecaseProvider)
        .call(contact: contact, code: code, newPassword: newPassword);
    result.fold(
      onSuccess: (_) =>
          state = state.copyWith(status: FormStatus.success, clearError: true),
      onFailure: (f) => state = state.copyWith(
        status: FormStatus.failure,
        error: f.messageAr,
      ),
    );
  }

  void clearState() => state = const AuthFormState();
}

final resetPasswordControllerProvider =
    NotifierProvider<ResetPasswordController, AuthFormState>(
      ResetPasswordController.new,
    );
