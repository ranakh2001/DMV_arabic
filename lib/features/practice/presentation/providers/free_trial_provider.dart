import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../questions/domain/entities/answer_check_result.dart';

/// How many of the free-trial practice questions the user has answered,
/// against the (configurable) free quota. Persisted in shared_preferences
/// only — this is progress/preference data, not a token.
///
/// The counter itself is server-authoritative: the client never increments
/// it locally, it only mirrors the `subscription.*` block returned by
/// `POST /questions/{id}/check-answer`. The persisted copy exists purely so
/// a fresh app launch can decide the quota is already spent without an API
/// call — see `startFreeTrial`.
class FreeTrialState {
  const FreeTrialState({required this.used, required this.max});

  final int used;
  final int max;

  int get remaining => (max - used).clamp(0, max);
  bool get isExhausted => used >= max;

  FreeTrialState copyWith({int? used, int? max}) =>
      FreeTrialState(used: used ?? this.used, max: max ?? this.max);
}

/// Tracks free-trial quota usage. Unrelated to `SubscriptionState`'s
/// (in-memory, mock) trial counter, which belongs to the separate Simulation
/// flow — see the Practice-vs-Simulation split noted on `PracticeController`.
class FreeTrialController extends Notifier<FreeTrialState> {
  @override
  FreeTrialState build() {
    final prefs = ref.watch(prefsServiceProvider);
    return FreeTrialState(
      used: prefs.freeQuestionsUsed,
      max: prefs.freeQuestionsLimit ?? AppConstants.freeQuotaDefault,
    );
  }

  /// Mirrors the quota fields from a `check-answer` response. Subscribed
  /// users (BR-03) report null usage fields — the gate never applies to
  /// them, so local counters are left untouched.
  Future<void> syncFromCheckAnswer(AnswerCheckResult result) async {
    if (result.hasActiveSubscription) return;
    final used = result.freeQuestionsUsed;
    if (used == null) return;
    final limit = result.freeQuestionsLimit ?? state.max;

    state = FreeTrialState(used: used, max: limit);
    final prefs = ref.read(prefsServiceProvider);
    await prefs.setFreeQuestionsUsed(used);
    await prefs.setFreeQuestionsLimit(limit);
  }
}

final freeTrialProvider = NotifierProvider<FreeTrialController, FreeTrialState>(
  FreeTrialController.new,
);
