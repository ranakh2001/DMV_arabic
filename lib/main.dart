import 'dart:io';
import 'package:dmv/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'app/app.dart';
import 'app/bootstrap.dart';
import 'core/config/stripe_config.dart';
import 'core/payment/apple_iap_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = StripeConfig.publishableKey;
  Stripe.merchantIdentifier = StripeConfig.appleMerchantIdentifier;
  await Stripe.instance.applySettings();

  if (Platform.isIOS) {
    await initializeAppleIap();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final container = await bootstrap();
  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
