import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../subscription/domain/entities/subscription_plan.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../state/payment_state.dart';

export '../state/payment_state.dart';

/// Drives the (mock) checkout step: simulates network latency, then
/// activates the subscription locally. No payment gateway is called yet.
class PaymentController extends Notifier<PaymentState> {
  @override
  PaymentState build() => const PaymentState();

  Future<void> pay({required SubscriptionPlan plan, required bool autoRenew}) async {
    state = state.copyWith(status: PaymentStatus.processing);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    ref.read(subscriptionProvider.notifier)
      ..activate(plan)
      ..setAutoRenew(autoRenew);
    state = state.copyWith(status: PaymentStatus.idle);
  }
}

final paymentControllerProvider =
    NotifierProvider<PaymentController, PaymentState>(PaymentController.new);
