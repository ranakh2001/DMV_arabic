import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/exceptions.dart';

/// Keys used in secure storage (tokens only — never user data or passwords).
abstract final class SecureKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiry = 'token_expiry';
}

/// Abstraction over [FlutterSecureStorage] for token management.
///
/// iOS: Keychain with [IOSAccessibility.first_unlock_this_device] (no iCloud sync).
/// Android: EncryptedSharedPreferences backed by Android Keystore.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: SecureKeys.accessToken, value: accessToken),
        _storage.write(key: SecureKeys.refreshToken, value: refreshToken),
        _storage.write(
          key: SecureKeys.tokenExpiry,
          value: expiry.toIso8601String(),
        ),
      ]);
    } catch (e) {
      throw const StorageException('Failed to save tokens');
    }
  }

  Future<String?> readAccessToken() async {
    try {
      return await _storage.read(key: SecureKeys.accessToken);
    } catch (e) {
      throw const StorageException('Failed to read access token');
    }
  }

  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: SecureKeys.refreshToken);
    } catch (e) {
      throw const StorageException('Failed to read refresh token');
    }
  }

  Future<DateTime?> readTokenExpiry() async {
    try {
      final raw = await _storage.read(key: SecureKeys.tokenExpiry);
      return raw == null ? null : DateTime.tryParse(raw);
    } catch (e) {
      throw const StorageException('Failed to read token expiry');
    }
  }

  Future<bool> hasValidToken() async {
    try {
      final token = await readAccessToken();
      if (token == null) return false;
      final expiry = await readTokenExpiry();
      if (expiry == null) return false;
      return DateTime.now().isBefore(expiry);
    } catch (_) {
      return false;
    }
  }

  /// Wipes all stored tokens. Called on logout or auth corruption.
  Future<void> clearAll() async {
    try {
      await Future.wait([
        _storage.delete(key: SecureKeys.accessToken),
        _storage.delete(key: SecureKeys.refreshToken),
        _storage.delete(key: SecureKeys.tokenExpiry),
      ]);
    } catch (e) {
      throw const StorageException('Failed to clear secure storage');
    }
  }
}
