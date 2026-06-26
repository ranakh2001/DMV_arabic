import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_service.dart';
import 'prefs_service.dart';

/// Riverpod provider for [FlutterSecureStorage].
/// Configured with platform-specific security options:
/// - iOS: Keychain, no iCloud sync.
/// - Android: EncryptedSharedPreferences via Keystore.
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  ),
);

/// Provider for [SecureStorageService]. Override during bootstrap once the
/// [FlutterSecureStorage] instance is ready.
final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(ref.watch(flutterSecureStorageProvider)),
);

/// Provider for [SharedPreferences]. Must be overridden in bootstrap.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not initialized'),
);

/// Provider for [PrefsService].
final prefsServiceProvider = Provider<PrefsService>(
  (ref) => PrefsService(ref.watch(sharedPreferencesProvider)),
);
