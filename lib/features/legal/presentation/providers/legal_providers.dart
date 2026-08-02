import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import '../../../auth/presentation/providers/auth_controller_provider.dart'
    show FormStatus;
import '../../data/datasources/legal_remote_data_source.dart';
import '../../data/repositories/legal_repository_impl.dart';
import '../../domain/entities/about_info.dart';
import '../../domain/entities/legal_content.dart';
import '../../domain/repositories/legal_repository.dart';
import '../../domain/usecases/get_about_us_usecase.dart';
import '../../domain/usecases/get_privacy_policy_usecase.dart';
import '../../domain/usecases/get_terms_usecase.dart';
import '../../domain/usecases/send_contact_message_usecase.dart';

final legalRemoteDataSourceProvider = Provider<LegalRemoteDataSource>(
  (ref) => LegalRemoteDataSource(ref.watch(dioProvider)),
);

final legalRepositoryProvider = Provider<LegalRepository>(
  (ref) =>
      LegalRepositoryImpl(remote: ref.watch(legalRemoteDataSourceProvider)),
);

final getPrivacyPolicyUsecaseProvider = Provider(
  (ref) => GetPrivacyPolicyUsecase(ref.watch(legalRepositoryProvider)),
);

final getTermsUsecaseProvider = Provider(
  (ref) => GetTermsUsecase(ref.watch(legalRepositoryProvider)),
);

final getAboutUsUsecaseProvider = Provider(
  (ref) => GetAboutUsUsecase(ref.watch(legalRepositoryProvider)),
);

final sendContactMessageUsecaseProvider = Provider(
  (ref) => SendContactMessageUsecase(ref.watch(legalRepositoryProvider)),
);

/// Fetched once and cached for the app session — matches [statesProvider]'s
/// behavior so navigating away and back doesn't re-fetch static content.
final privacyPolicyProvider = FutureProvider<LegalContent>((ref) async {
  ref.keepAlive();
  final result = await ref.watch(getPrivacyPolicyUsecaseProvider).call();
  return result.fold(
    onSuccess: (content) => content,
    onFailure: (failure) => throw failure,
  );
});

final termsProvider = FutureProvider<LegalContent>((ref) async {
  ref.keepAlive();
  final result = await ref.watch(getTermsUsecaseProvider).call();
  return result.fold(
    onSuccess: (content) => content,
    onFailure: (failure) => throw failure,
  );
});

final aboutUsProvider = FutureProvider<AboutInfo>((ref) async {
  ref.keepAlive();
  final result = await ref.watch(getAboutUsUsecaseProvider).call();
  return result.fold(
    onSuccess: (info) => info,
    onFailure: (failure) => throw failure,
  );
});

class ContactUsState {
  const ContactUsState({this.status = FormStatus.idle, this.error});

  final FormStatus status;
  final String? error;

  bool get isSubmitting => status == FormStatus.submitting;
  bool get isSuccess => status == FormStatus.success;
  bool get isFailure => status == FormStatus.failure;

  ContactUsState copyWith({
    FormStatus? status,
    String? error,
    bool clearError = false,
  }) => ContactUsState(
    status: status ?? this.status,
    error: clearError ? null : (error ?? this.error),
  );
}

class ContactUsController extends Notifier<ContactUsState> {
  @override
  ContactUsState build() => const ContactUsState();

  Future<void> submit(String message) async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref
        .read(sendContactMessageUsecaseProvider)
        .call(message);
    result.fold(
      onSuccess: (_) =>
          state = state.copyWith(status: FormStatus.success, clearError: true),
      onFailure: (failure) => state = state.copyWith(
        status: FormStatus.failure,
        error: failure.messageAr,
      ),
    );
  }

  void reset() => state = const ContactUsState();
}

final contactUsControllerProvider =
    NotifierProvider<ContactUsController, ContactUsState>(
      ContactUsController.new,
    );
