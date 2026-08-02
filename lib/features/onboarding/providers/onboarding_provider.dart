import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/storage_providers.dart';

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.read(prefsServiceProvider).getBool(AppConstants.onboardingDoneKey) ??
      false;

  Future<void> complete() async {
    state = true;
    await ref
        .read(prefsServiceProvider)
        .setBool(AppConstants.onboardingDoneKey, true);
  }
}

final onboardingDoneProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);
