import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller_provider.dart';
import 'auth_providers.dart';

class VerifyState {
  const VerifyState({
    this.formStatus = FormStatus.idle,
    this.error,
    this.secondsRemaining = 300,
    this.resendCooldownSeconds = 0,
    this.resendsUsed = 0,
  });

  final FormStatus formStatus;
  final String? error;
  final int secondsRemaining;
  final int resendCooldownSeconds;
  final int resendsUsed;

  static const int maxResends = 3;
  static const int resendCooldown = 60;

  bool get isExpired => secondsRemaining <= 0;
  bool get canResend => resendCooldownSeconds <= 0 && resendsUsed < maxResends;
  bool get maxResendsReached => resendsUsed >= maxResends;
  bool get isSubmitting => formStatus == FormStatus.submitting;
  bool get isSuccess => formStatus == FormStatus.success;
  bool get isFailure => formStatus == FormStatus.failure;

  VerifyState copyWith({
    FormStatus? formStatus,
    String? error,
    bool clearError = false,
    int? secondsRemaining,
    int? resendCooldownSeconds,
    int? resendsUsed,
  }) =>
      VerifyState(
        formStatus: formStatus ?? this.formStatus,
        error: clearError ? null : (error ?? this.error),
        secondsRemaining: secondsRemaining ?? this.secondsRemaining,
        resendCooldownSeconds: resendCooldownSeconds ?? this.resendCooldownSeconds,
        resendsUsed: resendsUsed ?? this.resendsUsed,
      );
}

class VerifyController extends Notifier<VerifyState> {
  Timer? _expiryTimer;
  Timer? _cooldownTimer;

  @override
  VerifyState build() {
    ref.onDispose(() {
      _expiryTimer?.cancel();
      _cooldownTimer?.cancel();
    });
    _startExpiryCountdown();
    return const VerifyState();
  }

  void _startExpiryCountdown() {
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.secondsRemaining - 1;
      if (remaining <= 0) {
        _expiryTimer?.cancel();
        state = state.copyWith(secondsRemaining: 0);
      } else {
        state = state.copyWith(secondsRemaining: remaining);
      }
    });
  }

  Future<void> verify({required String contact, required String code}) async {
    if (state.isExpired) {
      state = state.copyWith(
        formStatus: FormStatus.failure,
        error: 'انتهت صلاحية الرمز. اطلب رمزاً جديداً.',
      );
      return;
    }
    state = state.copyWith(formStatus: FormStatus.submitting, clearError: true);
    final result = await ref.read(verifyUsecaseProvider).call(contact: contact, code: code);
    result.fold(
      onSuccess: (session) {
        _expiryTimer?.cancel();
        ref.read(authControllerProvider.notifier).setAuthenticated(session.user);
        state = state.copyWith(formStatus: FormStatus.success, clearError: true);
      },
      onFailure: (failure) =>
          state = state.copyWith(formStatus: FormStatus.failure, error: failure.messageAr),
    );
  }

  Future<void> resend({required String contact}) async {
    if (!state.canResend) return;
    final result = await ref.read(resendCodeUsecaseProvider).call(contact: contact);
    result.fold(
      onSuccess: (_) {
        final newResendsUsed = state.resendsUsed + 1;
        state = state.copyWith(
          resendsUsed: newResendsUsed,
          resendCooldownSeconds: VerifyState.resendCooldown,
          secondsRemaining: 300,
          clearError: true,
        );
        _startExpiryCountdown();
        _startCooldown();
      },
      onFailure: (failure) => state = state.copyWith(error: failure.messageAr),
    );
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final cd = state.resendCooldownSeconds - 1;
      if (cd <= 0) {
        _cooldownTimer?.cancel();
        state = state.copyWith(resendCooldownSeconds: 0);
      } else {
        state = state.copyWith(resendCooldownSeconds: cd);
      }
    });
  }
}

final verifyControllerProvider =
    NotifierProvider<VerifyController, VerifyState>(VerifyController.new);

class SocialLoginController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref.read(socialLoginUsecaseProvider).callGoogle();
    result.fold(
      onSuccess: (session) {
        ref.read(authControllerProvider.notifier).setAuthenticated(session.user);
        state = state.copyWith(status: FormStatus.success, clearError: true);
      },
      onFailure: (f) =>
          state = state.copyWith(status: FormStatus.failure, error: f.messageAr),
    );
  }

  Future<void> loginWithApple() async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref.read(socialLoginUsecaseProvider).callApple();
    result.fold(
      onSuccess: (session) {
        ref.read(authControllerProvider.notifier).setAuthenticated(session.user);
        state = state.copyWith(status: FormStatus.success, clearError: true);
      },
      onFailure: (f) =>
          state = state.copyWith(status: FormStatus.failure, error: f.messageAr),
    );
  }
}

final socialLoginControllerProvider =
    NotifierProvider<SocialLoginController, AuthFormState>(SocialLoginController.new);
