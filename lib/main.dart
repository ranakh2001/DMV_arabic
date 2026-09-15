import 'dart:io';
import 'package:dmv/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/bootstrap.dart';
import 'app/di/payment_service_provider.dart';
import 'core/payment/apple_iap_bootstrap.dart';
import 'features/payment/data/services/stripe_sdk_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Platform-exclusive payment provider (App Store Guideline 3.1.1):
  // iOS → Apple In-App Purchase only; the Stripe SDK is never initialised.
  // Android (and anything else) → Stripe, exactly as before.
  if (Platform.isIOS) {
    await initializeAppleIap();
  } else {
    await initializeStripeSdk();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final container = await bootstrap();

  // iOS: subscribe to StoreKit's purchase stream before the first frame, as
  // Apple recommends, so transactions interrupted in a previous session are
  // verified and recorded even if the paywall is never opened.
  if (Platform.isIOS) {
    container.read(paymentServiceProvider);
  }

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
