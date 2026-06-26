import '../../domain/entities/auth_user.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.unverifiedContact,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? error;
  final String? unverifiedContact;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  const AuthState.initial() : this();

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? error,
    String? unverifiedContact,
    bool clearError = false,
    bool clearContact = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: clearError ? null : (error ?? this.error),
        unverifiedContact:
            clearContact ? null : (unverifiedContact ?? this.unverifiedContact),
      );
}

enum FormStatus { idle, submitting, success, failure }

/// Per-form async state. Named [AuthFormState] to avoid clash with Flutter's [FormState].
class AuthFormState {
  const AuthFormState({
    this.status = FormStatus.idle,
    this.error,
  });

  final FormStatus status;
  final String? error;

  bool get isSubmitting => status == FormStatus.submitting;
  bool get isSuccess => status == FormStatus.success;
  bool get isFailure => status == FormStatus.failure;

  AuthFormState copyWith({
    FormStatus? status,
    String? error,
    bool clearError = false,
  }) =>
      AuthFormState(
        status: status ?? this.status,
        error: clearError ? null : (error ?? this.error),
      );
}
