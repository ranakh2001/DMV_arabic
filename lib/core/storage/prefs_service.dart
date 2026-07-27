import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction over [SharedPreferences] for non-sensitive user data and settings.
///
/// IMPORTANT: Never store tokens or passwords here — use [SecureStorageService].
class PrefsService {
  PrefsService(this._prefs);

  final SharedPreferences _prefs;

  // --- String
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  // --- Bool
  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  // --- Int
  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  // --- Double
  double? getDouble(String key) => _prefs.getDouble(key);
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);

  // --- JSON helpers
  Future<bool> remove(String key) => _prefs.remove(key);

  Future<void> clearUserData() async {
    const userKeys = [
      'user_name',
      'user_email',
      'user_phone',
      'user_state',
      'user_avatar',
    ];
    for (final key in userKeys) {
      await _prefs.remove(key);
    }
  }

  // --- User profile cache (non-sensitive)
  String? get userName => getString('user_name');
  Future<bool> setUserName(String v) => setString('user_name', v);

  String? get userEmail => getString('user_email');
  Future<bool> setUserEmail(String v) => setString('user_email', v);

  String? get userPhone => getString('user_phone');
  Future<bool> setUserPhone(String v) => setString('user_phone', v);

  String? get selectedState => getString('user_state');
  Future<bool> setSelectedState(String v) => setString('user_state', v);

  int? get selectedStateId => getInt('user_state_id');
  Future<bool> setSelectedStateId(int v) => setInt('user_state_id', v);
}
