import '../../../states/domain/entities/us_state.dart';
import 'user_progress.dart';
import 'user_subscription.dart';

/// Domain entity for the current user's profile. Contains no data-layer types.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    this.email,
    required this.phoneNumber,
    this.profilePhotoUrl,
    this.stateId,
    this.freeQuestionsUsed = 0,
    this.subscriptionType,
    this.progress,
    this.subscription,
    this.selectedState,
  });

  final String id;
  final String fullName;
  final String? email;
  final String phoneNumber;
  final String? profilePhotoUrl;
  final int? stateId;

  /// How many of the free-trial practice questions this user has answered,
  /// server-authoritative (`data.free_questions_used` on `/users/profile`).
  final int freeQuestionsUsed;

  /// Display label for the active package (`data.subscription_type`), e.g.
  /// "Basic Package". `null` when the user has no subscription.
  final String? subscriptionType;

  final UserProgress? progress;
  final UserSubscription? subscription;

  /// Full state object (`data.selected_state`); [stateId] stays the
  /// lightweight id used for prefs sync and state-picker gating.
  final UsState? selectedState;

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePhotoUrl,
    int? stateId,
    int? freeQuestionsUsed,
    String? subscriptionType,
    UserProgress? progress,
    UserSubscription? subscription,
    UsState? selectedState,
  }) => UserProfile(
    id: id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    stateId: stateId ?? this.stateId,
    freeQuestionsUsed: freeQuestionsUsed ?? this.freeQuestionsUsed,
    subscriptionType: subscriptionType ?? this.subscriptionType,
    progress: progress ?? this.progress,
    subscription: subscription ?? this.subscription,
    selectedState: selectedState ?? this.selectedState,
  );
}
