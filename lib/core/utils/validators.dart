/// Client-side validators. Server is always authoritative; these guard UX only.
class Validators {
  Validators._();

  static final _emailRe = RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$');

  /// US phone in E.164 format (+1XXXXXXXXXX) or 10-digit local.
  static final _phoneRe = RegExp(r'^(\+1)?\d{10}$');

  static final _codeRe = RegExp(r'^\d{6}$');

  /// Returns Arabic error string, or null when valid.
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'البريد الإلكتروني مطلوب.';
    if (!_emailRe.hasMatch(v.trim())) return 'صيغة البريد الإلكتروني غير صحيحة.';
    return null;
  }

  /// Validates US phone (E.164 +1 or 10-digit).
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'رقم الهاتف مطلوب.';
    final stripped = v.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_phoneRe.hasMatch(stripped)) return 'أدخل رقم هاتف أمريكي صحيح.';
    return null;
  }

  /// Accepts email OR US phone.
  static String? emailOrPhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'البريد الإلكتروني أو رقم الهاتف مطلوب.';
    final trimmed = v.trim();
    if (trimmed.contains('@')) return email(trimmed);
    return phone(trimmed);
  }

  /// Minimum 8 characters (server does bcrypt hashing — never hash client-side).
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة.';
    if (v.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل.';
    return null;
  }

  /// Confirms passwords match.
  static String? confirmPassword(String? v, String password) {
    if (v == null || v.isEmpty) return 'تأكيد كلمة المرور مطلوب.';
    if (v != password) return 'كلمتا المرور غير متطابقتين.';
    return null;
  }

  /// Six-digit verification code.
  static String? verificationCode(String? v) {
    if (v == null || v.trim().isEmpty) return 'رمز التحقق مطلوب.';
    if (!_codeRe.hasMatch(v.trim())) return 'رمز التحقق يتكون من 6 أرقام.';
    return null;
  }

  /// Non-empty name.
  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'الاسم مطلوب.';
    return null;
  }
}
