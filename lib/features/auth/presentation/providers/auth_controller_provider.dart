import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../domain/entities/auth_user.dart';
import '../state/auth_state.dart';
import 'auth_providers.dart';

export '../state/auth_state.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> bootstrap() async {
    state = state.copyWith(status: AuthStatus.unknown);
    final result = await ref.read(bootstrapSessionUsecaseProvider).call();
    result.fold(
      onSuccess: (user) {
        if (user != null) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
      onFailure: (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure.messageAr,
        );
      },
    );
  }

  void setAuthenticated(AuthUser user) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      clearError: true,
    );
  }

  Future<void> logout() async {
    await ref.read(logoutUsecaseProvider).call();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Signs out without contacting the backend — wipes the local session
  /// only. Used while the logout endpoint isn't available yet.
  Future<void> signOutLocally() async {
    await ref.read(secureStorageProvider).clearAll();
    await ref.read(prefsServiceProvider).clearUserData();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

// ─── Per-form controllers ────────────────────────────────────────────────────

class LoginController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> login({required String contact, required String password}) async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref.read(loginUsecaseProvider).call(
          contact: contact,
          password: password,
        );
    result.fold(
      onSuccess: (data) {
        if (data.unverifiedContact != null) {
          state = state.copyWith(
            status: FormStatus.failure,
            error: 'UNVERIFIED:${data.unverifiedContact}',
          );
          return;
        }
        ref.read(authControllerProvider.notifier).setAuthenticated(data.session!.user);
        state = state.copyWith(status: FormStatus.success, clearError: true);
      },
      onFailure: (failure) =>
          state = state.copyWith(status: FormStatus.failure, error: failure.messageAr),
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
    required String password,
  }) async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref.read(registerUsecaseProvider).call(
          name: name,
          contact: contact,
          password: password,
        );
    result.fold(
      onSuccess: (_) =>
          state = state.copyWith(status: FormStatus.success, clearError: true),
      onFailure: (failure) =>
          state = state.copyWith(status: FormStatus.failure, error: failure.messageAr),
    );
  }
}

final registerControllerProvider =
    NotifierProvider<RegisterController, AuthFormState>(RegisterController.new);

class ForgotPasswordController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> send({required String contact}) async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref.read(forgotPasswordUsecaseProvider).call(contact: contact);
    result.fold(
      onSuccess: (_) =>
          state = state.copyWith(status: FormStatus.success, clearError: true),
      onFailure: (f) =>
          state = state.copyWith(status: FormStatus.failure, error: f.messageAr),
    );
  }
}

final forgotPasswordControllerProvider =
    NotifierProvider<ForgotPasswordController, AuthFormState>(
        ForgotPasswordController.new);

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
      onFailure: (f) =>
          state = state.copyWith(status: FormStatus.failure, error: f.messageAr),
    );
  }
}

final resetPasswordControllerProvider =
    NotifierProvider<ResetPasswordController, AuthFormState>(
        ResetPasswordController.new);
