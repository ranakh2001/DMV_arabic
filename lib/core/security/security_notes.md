# Security Threat Model — DMV بالعربي

## Implemented (v1)

| Control | Implementation |
|---------|----------------|
| Token storage | `flutter_secure_storage` → iOS Keychain (`first_unlock_this_device`, no iCloud sync) / Android EncryptedSharedPreferences (Keystore) |
| Sensitive vs. non-sensitive split | Tokens → secure storage only. User profile / settings → `shared_preferences`. Passwords never stored client-side. |
| HTTPS enforcement | `ApiConstants.baseUrl` asserted to start with `https://` at startup; Dio uses default TLS validation (no `badCertificateCallback` override) |
| App-switcher privacy | `AppShield` (`WidgetsBindingObserver`) overlays branded screen on `inactive`/`paused` lifecycle states |
| Token logging redaction | `LoggingInterceptor` redacts `Authorization` header and any field containing `token` or `password` |
| Token refresh | `AuthInterceptor` retries once on 401 with new access token; on failure, wipes storage and routes to login |
| Logout | `SecureStorageService.clearAll()` + auth state reset; no orphaned tokens |
| Storage corruption | Caught → treated as unauthenticated; storage wiped; Arabic error surfaced; no crash |
| Client-side validation | `Validators` guards UX; server is always authoritative |
| Password policy | Minimum 8 chars (client UI only); bcrypt hashing is server-side |

## v2 TODO (Not Implemented)

- **TLS Certificate Pinning**: Pin the API certificate or public key using `dio` + custom `HttpClient` with `SecurityContext`. Protects against MITM even on compromised CAs.
- **Android `FLAG_SECURE`**: Call `window.setFlags(FLAG_SECURE)` via a platform channel to prevent screenshots and app-switcher capture at the OS level (complements `AppShield`).
- **Biometric Re-authentication**: Prompt for fingerprint/Face ID before displaying sensitive data or confirming destructive actions. Use `local_auth`.
- **Jailbreak / Root Detection**: Integrate `flutter_jailbreak_detection` or a custom check; warn user or restrict features on compromised devices.
- **Session Replay Prevention**: Audit third-party SDKs (analytics, crash reporting) for automatic screen capture; disable or anonymise sensitive views.
- **Account Deletion**: Full data purge — both `secure_storage` and `shared_preferences` wipe, plus server-side DELETE request.
