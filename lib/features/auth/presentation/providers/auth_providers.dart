import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/social_auth_service.dart';
import '../../domain/usecases/bootstrap_session_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/resend_code_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';
import '../../domain/usecases/verify_usecase.dart';

// NOTE: wired to [MockAuthRepository] until the real backend is live — see
// auth_repository_impl.dart (kept in place, unused) for the Dio-backed version
// to swap back in once the API is ready.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(
    secureStorage: ref.watch(secureStorageProvider),
    prefs: ref.watch(prefsServiceProvider),
  ),
);

final socialAuthServiceProvider = Provider<SocialAuthService>(
  (ref) => const UnavailableSocialAuthService(),
);

// Use-case providers
final registerUsecaseProvider = Provider(
  (ref) => RegisterUsecase(ref.watch(authRepositoryProvider)),
);

final verifyUsecaseProvider = Provider(
  (ref) => VerifyUsecase(ref.watch(authRepositoryProvider)),
);

final resendCodeUsecaseProvider = Provider(
  (ref) => ResendCodeUsecase(ref.watch(authRepositoryProvider)),
);

final loginUsecaseProvider = Provider(
  (ref) => LoginUsecase(ref.watch(authRepositoryProvider)),
);

final socialLoginUsecaseProvider = Provider(
  (ref) => SocialLoginUsecase(
    ref.watch(authRepositoryProvider),
    ref.watch(socialAuthServiceProvider),
  ),
);

final logoutUsecaseProvider = Provider(
  (ref) => LogoutUsecase(ref.watch(authRepositoryProvider)),
);

final forgotPasswordUsecaseProvider = Provider(
  (ref) => ForgotPasswordUsecase(ref.watch(authRepositoryProvider)),
);

final resetPasswordUsecaseProvider = Provider(
  (ref) => ResetPasswordUsecase(ref.watch(authRepositoryProvider)),
);

final bootstrapSessionUsecaseProvider = Provider(
  (ref) => BootstrapSessionUsecase(ref.watch(authRepositoryProvider)),
);
