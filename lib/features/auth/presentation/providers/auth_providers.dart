import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../states/presentation/providers/states_providers.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/bootstrap_session_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/resend_verification_code_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_reset_code_usecase.dart';
import '../../domain/usecases/verify_usecase.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
    prefs: ref.watch(prefsServiceProvider),
    statesRepository: ref.watch(statesRepositoryProvider),
  ),
);

// Use-case providers
final registerUsecaseProvider = Provider(
  (ref) => RegisterUsecase(ref.watch(authRepositoryProvider)),
);

final verifyUsecaseProvider = Provider(
  (ref) => VerifyUsecase(ref.watch(authRepositoryProvider)),
);

final resendVerificationCodeUsecaseProvider = Provider(
  (ref) => ResendVerificationCodeUsecase(ref.watch(authRepositoryProvider)),
);

final loginUsecaseProvider = Provider(
  (ref) => LoginUsecase(ref.watch(authRepositoryProvider)),
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

final verifyResetCodeUsecaseProvider = Provider(
  (ref) => VerifyResetCodeUsecase(ref.watch(authRepositoryProvider)),
);

final bootstrapSessionUsecaseProvider = Provider(
  (ref) => BootstrapSessionUsecase(ref.watch(authRepositoryProvider)),
);

final refreshTokenUsecaseProvider = Provider(
  (ref) => RefreshTokenUsecase(ref.watch(authRepositoryProvider)),
);
