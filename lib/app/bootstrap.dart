import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/dio_providers.dart';
import '../core/storage/storage_providers.dart';
import '../features/auth/presentation/providers/auth_controller_provider.dart';

/// Initializes all async dependencies before the widget tree mounts.
/// Returns a [ProviderContainer] with overrides pre-populated.
Future<ProviderContainer> bootstrap() async {
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Wire the AuthInterceptor now that the container (and auth controller) exist.
  attachAuthInterceptor(
    container,
    container.read(dioProvider),
    () async {
      await container.read(authControllerProvider.notifier).logout();
    },
  );

  // Restore session from secure storage.
  await container.read(authControllerProvider.notifier).bootstrap();

  return container;
}
