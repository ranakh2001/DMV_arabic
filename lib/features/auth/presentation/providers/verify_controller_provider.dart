import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller_provider.dart';
import 'auth_providers.dart';

const _resendCooldownSeconds = 60;

class VerifyState {
  const VerifyState({
    this.formStatus = FormStatus.idle,
    this.error,
    this.secondsRemaining = 300,
    this.resendStatus = FormStatus.idle,
    this.resendError,
    this.resendCooldown = _resendCooldownSeconds,
  });

  final FormStatus formStatus;
  final String? error;
  final int secondsRemaining;
  final FormStatus resendStatus;
  final String? resendError;
  final int resendCooldown;

  bool get isExpired => secondsRemaining <= 0;
  bool get isSubmitting => formStatus == FormStatus.submitting;
  bool get isSuccess => formStatus == FormStatus.success;
  bool get isFailure => formStatus == FormStatus.failure;
  bool get isResending => resendStatus == FormStatus.submitting;
  bool get canResend => resendCooldown <= 0 && !isResending;

  VerifyState copyWith({
    FormStatus? formStatus,
    String? error,
    bool clearError = false,
    int? secondsRemaining,
    FormStatus? resendStatus,
    String? resendError,
    bool clearResendError = false,
    int? resendCooldown,
  }) => VerifyState(
    formStatus: formStatus ?? this.formStatus,
    error: clearError ? null : (error ?? this.error),
    secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    resendStatus: resendStatus ?? this.resendStatus,
    resendError: clearResendError ? null : (resendError ?? this.resendError),
    resendCooldown: resendCooldown ?? this.resendCooldown,
  );
}

class VerifyController extends Notifier<VerifyState> {
  Timer? _expiryTimer;
  Timer? _resendTimer;

  @override
  VerifyState build() {
    ref.onDispose(() {
      _expiryTimer?.cancel();
      _resendTimer?.cancel();
    });
    _startExpiryCountdown();
    _startResendTimer();
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

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.resendCooldown - 1;
      if (remaining <= 0) {
        _resendTimer?.cancel();
        state = state.copyWith(resendCooldown: 0);
      } else {
        state = state.copyWith(resendCooldown: remaining);
      }
    });
  }

  Future<void> resend({required String contact}) async {
    if (!state.canResend) return;
    state = state.copyWith(
      resendStatus: FormStatus.submitting,
      clearResendError: true,
    );
    final result = await ref
        .read(resendVerificationCodeUsecaseProvider)
        .call(contact: contact);
    result.fold(
      onSuccess: (_) {
        state = state.copyWith(
          resendStatus: FormStatus.success,
          clearResendError: true,
          secondsRemaining: 300,
          resendCooldown: _resendCooldownSeconds,
        );
        _startExpiryCountdown();
        _startResendTimer();
      },
      onFailure: (failure) => state = state.copyWith(
        resendStatus: FormStatus.failure,
        resendError: failure.messageAr,
      ),
    );
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
    final result = await ref
        .read(verifyUsecaseProvider)
        .call(contact: contact, code: code);
    result.fold(
      onSuccess: (session) {
        _expiryTimer?.cancel();
        ref
            .read(authControllerProvider.notifier)
            .setAuthenticated(session.user, expiresAt: session.expiresAt);
        state = state.copyWith(
          formStatus: FormStatus.success,
          clearError: true,
        );
      },
      onFailure: (failure) => state = state.copyWith(
        formStatus: FormStatus.failure,
        error: failure.messageAr,
      ),
    );
  }
}

final verifyControllerProvider =
    NotifierProvider<VerifyController, VerifyState>(VerifyController.new);
