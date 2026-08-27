import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../auth/presentation/providers/auth_controller_provider.dart'
    show FormStatus;
import '../../../states/presentation/providers/states_providers.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_profile_photo_usecase.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSource(ref.watch(dioProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) =>
      ProfileRepositoryImpl(remote: ref.watch(profileRemoteDataSourceProvider)),
);

final getProfileUsecaseProvider = Provider(
  (ref) => GetProfileUsecase(ref.watch(profileRepositoryProvider)),
);

final updateProfileUsecaseProvider = Provider(
  (ref) => UpdateProfileUsecase(ref.watch(profileRepositoryProvider)),
);

final uploadProfilePhotoUsecaseProvider = Provider(
  (ref) => UploadProfilePhotoUsecase(ref.watch(profileRepositoryProvider)),
);

final changePasswordUsecaseProvider = Provider(
  (ref) => ChangePasswordUsecase(ref.watch(profileRepositoryProvider)),
);

final deleteAccountUsecaseProvider = Provider(
  (ref) => DeleteAccountUsecase(ref.watch(profileRepositoryProvider)),
);

enum ProfileLoadStatus { initial, loading, loaded, failed }

class ProfileState {
  const ProfileState({
    this.loadStatus = ProfileLoadStatus.initial,
    this.profile,
    this.loadError,
    this.updateStatus = FormStatus.idle,
    this.updateError,
  });

  final ProfileLoadStatus loadStatus;
  final UserProfile? profile;
  final String? loadError;
  final FormStatus updateStatus;
  final String? updateError;

  bool get isUpdating => updateStatus == FormStatus.submitting;

  ProfileState copyWith({
    ProfileLoadStatus? loadStatus,
    UserProfile? profile,
    String? loadError,
    FormStatus? updateStatus,
    String? updateError,
    bool clearUpdateError = false,
  }) => ProfileState(
    loadStatus: loadStatus ?? this.loadStatus,
    profile: profile ?? this.profile,
    loadError: loadError ?? this.loadError,
    updateStatus: updateStatus ?? this.updateStatus,
    updateError: clearUpdateError ? null : (updateError ?? this.updateError),
  );
}

class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> load() async {
    state = state.copyWith(loadStatus: ProfileLoadStatus.loading);
    final result = await ref.read(getProfileUsecaseProvider).call();
    result.fold(
      onSuccess: (profile) {
        state = state.copyWith(
          loadStatus: ProfileLoadStatus.loaded,
          profile: profile,
        );
        unawaited(_syncSelectedState(profile.stateId));
      },
      onFailure: (failure) => state = state.copyWith(
        loadStatus: ProfileLoadStatus.failed,
        loadError: failure.messageAr,
      ),
    );
  }

  /// Keeps [PrefsService.selectedStateId]/[PrefsService.selectedState] in
  /// sync with whatever the backend has, so screens gated on the cached
  /// prefs value (Simulation, Practice) stay correct after any profile
  /// refresh — not just at session bootstrap.
  Future<void> _syncSelectedState(int? stateId) async {
    if (stateId == null) return;
    final prefs = ref.read(prefsServiceProvider);
    await prefs.setSelectedStateId(stateId);
    final states = await ref.read(statesProvider.future);
    for (final state in states) {
      if (state.id == stateId) {
        await prefs.setSelectedState(state.nameAr);
        break;
      }
    }
  }

  /// Updates a single field (or set of fields) on the server and merges the
  /// server's response back into local state.
  Future<bool> update(Map<String, dynamic> fields) async {
    state = state.copyWith(
      updateStatus: FormStatus.submitting,
      clearUpdateError: true,
    );
    final result = await ref.read(updateProfileUsecaseProvider).call(fields);
    var succeeded = false;
    result.fold(
      onSuccess: (profile) {
        succeeded = true;
        state = state.copyWith(
          updateStatus: FormStatus.success,
          profile: profile,
        );
      },
      onFailure: (failure) => state = state.copyWith(
        updateStatus: FormStatus.failure,
        updateError: failure.messageAr,
      ),
    );
    return succeeded;
  }

  /// Uploads [photo] as the new profile picture and merges the server's
  /// response (with the updated `profile_photo_url`) back into local state.
  Future<bool> uploadPhoto(File photo) async {
    state = state.copyWith(
      updateStatus: FormStatus.submitting,
      clearUpdateError: true,
    );
    final result = await ref.read(uploadProfilePhotoUsecaseProvider).call(photo);
    var succeeded = false;
    result.fold(
      onSuccess: (profile) {
        succeeded = true;
        state = state.copyWith(
          updateStatus: FormStatus.success,
          profile: profile,
        );
      },
      onFailure: (failure) => state = state.copyWith(
        updateStatus: FormStatus.failure,
        updateError: failure.messageAr,
      ),
    );
    return succeeded;
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

class ChangePasswordState {
  const ChangePasswordState({this.status = FormStatus.idle, this.error});

  final FormStatus status;
  final String? error;

  bool get isSubmitting => status == FormStatus.submitting;
  bool get isSuccess => status == FormStatus.success;
  bool get isFailure => status == FormStatus.failure;

  ChangePasswordState copyWith({
    FormStatus? status,
    String? error,
    bool clearError = false,
  }) => ChangePasswordState(
    status: status ?? this.status,
    error: clearError ? null : (error ?? this.error),
  );
}

class ChangePasswordController extends Notifier<ChangePasswordState> {
  @override
  ChangePasswordState build() => const ChangePasswordState();

  Future<void> submit({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref
        .read(changePasswordUsecaseProvider)
        .call(currentPassword: currentPassword, newPassword: newPassword);
    result.fold(
      onSuccess: (_) =>
          state = state.copyWith(status: FormStatus.success, clearError: true),
      onFailure: (failure) => state = state.copyWith(
        status: FormStatus.failure,
        error: failure.messageAr,
      ),
    );
  }

  void reset() => state = const ChangePasswordState();
}

final changePasswordControllerProvider =
    NotifierProvider<ChangePasswordController, ChangePasswordState>(
      ChangePasswordController.new,
    );

class DeleteAccountState {
  const DeleteAccountState({this.status = FormStatus.idle, this.error});

  final FormStatus status;
  final String? error;

  bool get isSubmitting => status == FormStatus.submitting;

  DeleteAccountState copyWith({
    FormStatus? status,
    String? error,
    bool clearError = false,
  }) => DeleteAccountState(
    status: status ?? this.status,
    error: clearError ? null : (error ?? this.error),
  );
}

class DeleteAccountController extends Notifier<DeleteAccountState> {
  @override
  DeleteAccountState build() => const DeleteAccountState();

  /// Returns `true` on success. Callers are responsible for logging the
  /// user out afterwards — the account is disabled server-side, but the
  /// local session/tokens still need to be cleared.
  Future<bool> submit() async {
    state = state.copyWith(status: FormStatus.submitting, clearError: true);
    final result = await ref.read(deleteAccountUsecaseProvider).call();
    var succeeded = false;
    result.fold(
      onSuccess: (_) {
        succeeded = true;
        state = state.copyWith(status: FormStatus.success, clearError: true);
      },
      onFailure: (failure) => state = state.copyWith(
        status: FormStatus.failure,
        error: failure.messageAr,
      ),
    );
    return succeeded;
  }
}

final deleteAccountControllerProvider =
    NotifierProvider<DeleteAccountController, DeleteAccountState>(
      DeleteAccountController.new,
    );
