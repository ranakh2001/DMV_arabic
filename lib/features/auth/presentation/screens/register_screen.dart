import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../legal/presentation/screens/privacy_policy_screen.dart';
import '../../../legal/presentation/screens/terms_of_use_screen.dart';
import '../providers/auth_controller_provider.dart';
import 'login_screen.dart';
import 'verify_screen.dart';

// ── US States ─────────────────────────────────────────────────────────────────

const _usStates = [
  ('Alabama', 'ألاباما'),
  ('Alaska', 'ألاسكا'),
  ('Arizona', 'أريزونا'),
  ('Arkansas', 'أركنساس'),
  ('California', 'كاليفورنيا'),
  ('Colorado', 'كولورادو'),
  ('Connecticut', 'كونيتيكت'),
  ('Delaware', 'ديلاوير'),
  ('Florida', 'فلوريدا'),
  ('Georgia', 'جورجيا'),
  ('Hawaii', 'هاواي'),
  ('Idaho', 'أيداهو'),
  ('Illinois', 'إلينوي'),
  ('Indiana', 'إنديانا'),
  ('Iowa', 'آيوا'),
  ('Kansas', 'كانساس'),
  ('Kentucky', 'كنتاكي'),
  ('Louisiana', 'لويزيانا'),
  ('Maine', 'مين'),
  ('Maryland', 'ماريلاند'),
  ('Massachusetts', 'ماساتشوستس'),
  ('Michigan', 'ميشيغان'),
  ('Minnesota', 'مينيسوتا'),
  ('Mississippi', 'ميسيسيبي'),
  ('Missouri', 'ميسوري'),
  ('Montana', 'مونتانا'),
  ('Nebraska', 'نيبراسكا'),
  ('Nevada', 'نيفادا'),
  ('New Hampshire', 'نيو هامبشير'),
  ('New Jersey', 'نيوجيرسي'),
  ('New Mexico', 'نيو مكسيكو'),
  ('New York', 'نيويورك'),
  ('North Carolina', 'كارولينا الشمالية'),
  ('North Dakota', 'داكوتا الشمالية'),
  ('Ohio', 'أوهايو'),
  ('Oklahoma', 'أوكلاهوما'),
  ('Oregon', 'أوريغون'),
  ('Pennsylvania', 'بنسلفانيا'),
  ('Rhode Island', 'رود آيلاند'),
  ('South Carolina', 'كارولينا الجنوبية'),
  ('South Dakota', 'داكوتا الجنوبية'),
  ('Tennessee', 'تينيسي'),
  ('Texas', 'تكساس'),
  ('Utah', 'يوتا'),
  ('Vermont', 'فيرمونت'),
  ('Virginia', 'فيرجينيا'),
  ('Washington', 'واشنطن'),
  ('West Virginia', 'فيرجينيا الغربية'),
  ('Wisconsin', 'ويسكونسن'),
  ('Wyoming', 'وايومنغ'),
];

// ── Password strength ──────────────────────────────────────────────────────────

int _passwordStrength(String password) {
  if (password.isEmpty) return 0;
  int score = 0;
  if (password.length >= 8) score++;
  if (password.contains(RegExp(r'[A-Z]'))) score++;
  if (password.contains(RegExp(r'[0-9]'))) score++;
  if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
  return score;
}

Color _strengthColor(int strength) {
  switch (strength) {
    case 1:
      return const Color(0xFFE53935);
    case 2:
      return const Color(0xFFF57C00);
    case 3:
      return const Color(0xFF4A9CD9);
    case 4:
      return const Color(0xFF4CAF50);
    default:
      return Colors.transparent;
  }
}

// ── Main Screen ───────────────────────────────────────────────────────────────

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _termsAccepted = false;
  String? _selectedState;
  int _pwStrength = 0;

  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() {
      final s = _passwordStrength(_passwordCtrl.text);
      if (s != _pwStrength) setState(() => _pwStrength = s);
    });
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t('auth.register.agree_terms') +
                context.t('auth.register.terms_use'),
            style: const TextStyle(fontFamily: 'Almarai'),
          ),
          backgroundColor: const Color(0xFF4A9CD9),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await ref
        .read(registerControllerProvider.notifier)
        .register(
          name: _nameCtrl.text.trim(),
          contact: _contactCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    ref.listen(registerControllerProvider, (_, next) {
      if (next.isSuccess) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => VerifyScreen(contact: _contactCtrl.text.trim()),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ────────────────────────────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF0D1E3A), const Color(0xFF060912)]
                    : [const Color(0xFF1A3462), const Color(0xFF0A1628)],
              ),
            ),
          ),

          // ── Decorative blobs ───────────────────────────────────────────
          Positioned(
            top: -70,
            right: -70,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1565C0).withAlpha(50),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A9CD9).withAlpha(25),
              ),
            ),
          ),

          // ── Main content ───────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  children: [
                    // ── Header ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        children: [
                          _CircleNavButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                          Spacer(),
                          Text(
                            context.t('auth.register.title'),
                            style: const TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),

                    // ── Scrollable form ────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              context.t('auth.register.welcome_title'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Almarai',
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              context.t('auth.register.welcome_subtitle'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Almarai',
                                fontSize: 14,
                                color: Colors.white.withAlpha(155),
                                height: 1.65,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // ── Form ────────────────────────────────
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Full name
                                  _AuthFieldLabel(context.t('field.name')),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _nameCtrl,
                                    textInputAction: TextInputAction.next,
                                    style: _fieldTextStyle,
                                    decoration: _buildFieldDeco(
                                      context: context,
                                      hint: context.t('field.name_hint'),
                                      prefixIcon: const Icon(
                                        Icons.person_outline_rounded,
                                        color: Color(0xFF4A9CD9),
                                        size: 20,
                                      ),
                                    ),
                                    validator: Validators.name(context),
                                  ),

                                  const SizedBox(height: 20),

                                  // Phone
                                  _AuthFieldLabel(context.t('field.phone')),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _contactCtrl,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    style: _fieldTextStyle,
                                    decoration: _buildFieldDeco(
                                      context: context,
                                      hint: context.t('field.phone_hint'),
                                      prefixIcon: const Icon(
                                        Icons.phone_rounded,
                                        color: Color(0xFF4A9CD9),
                                        size: 20,
                                      ),
                                    ),
                                    validator: Validators.emailOrPhone(context),
                                  ),

                                  const SizedBox(height: 20),

                                  // Password
                                  _AuthFieldLabel(context.t('field.password')),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _passwordCtrl,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    style: _fieldTextStyle,
                                    decoration: _buildPasswordDeco(
                                      context: context,
                                      obscure: _obscurePassword,
                                      onToggle: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                    validator: Validators.password(context),
                                  ),

                                  // Strength bar
                                  if (_passwordCtrl.text.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    _PasswordStrengthBar(
                                      strength: _pwStrength,
                                      label: context.t(
                                        'password.strength.label',
                                      ),
                                      strengthLabel: _pwStrength == 0
                                          ? ''
                                          : _pwStrength == 1
                                          ? context.t('password.strength.weak')
                                          : _pwStrength == 2
                                          ? context.t('password.strength.fair')
                                          : _pwStrength == 3
                                          ? context.t('password.strength.good')
                                          : context.t(
                                              'password.strength.strong',
                                            ),
                                    ),
                                  ],

                                  const SizedBox(height: 20),

                                  // Confirm password
                                  _AuthFieldLabel(
                                    context.t('field.confirm_password'),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _confirmCtrl,
                                    obscureText: _obscureConfirm,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    style: _fieldTextStyle,
                                    decoration: _buildFieldDeco(
                                      context: context,
                                      hint: context.t(
                                        'field.confirm_password_hint',
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.shield_outlined,
                                        color: Color(0xFF4A9CD9),
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: const Color(0xFF4A9CD9),
                                          size: 20,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureConfirm =
                                              !_obscureConfirm,
                                        ),
                                      ),
                                    ),
                                    validator: Validators.confirmPassword(
                                      context,
                                      _passwordCtrl.text,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // State
                                  _AuthFieldLabel(context.t('field.state')),
                                  const SizedBox(height: 8),
                                  _StateDropdownField(
                                    context: context,
                                    selectedState: _selectedState,
                                    isDark: isDark,
                                    isRtl: isRtl,
                                    onTap: () => _showStatePicker(
                                      context,
                                      isRtl,
                                      isDark,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Terms checkbox
                                  _TermsRow(
                                    context: context,
                                    accepted: _termsAccepted,
                                    onChanged: (v) => setState(
                                      () => _termsAccepted = v ?? false,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Error message
                                  if (state.isFailure && state.error != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 14,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: context.appError.withAlpha(30),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: context.appError.withAlpha(
                                              100,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          state.error!,
                                          style: TextStyle(
                                            fontFamily: 'Almarai',
                                            fontSize: 13,
                                            color: context.appError,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),

                                  // Submit button with glow
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF4A9CD9,
                                          ).withAlpha(95),
                                          blurRadius: 24,
                                          spreadRadius: -2,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: SizedBox(
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: state.isSubmitting
                                            ? null
                                            : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF4A9CD9,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: state.isSubmitting
                                            ? const SizedBox.square(
                                                dimension: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : Text(
                                                context.t(
                                                  'auth.register.submit',
                                                ),
                                                style: const TextStyle(
                                                  fontFamily: 'Almarai',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Have account link ──────────────────────
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context.t('auth.register.have_account'),
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: 14,
                                    color: Colors.white.withAlpha(140),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    context.t('auth.register.sign_in'),
                                    style: const TextStyle(
                                      fontFamily: 'Almarai',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4A9CD9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatePicker(BuildContext context, bool isRtl, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatePickerSheet(
        isDark: isDark,
        isRtl: isRtl,
        currentValue: _selectedState,
        onSelected: (val) {
          Navigator.pop(context);
          setState(() => _selectedState = val);
        },
      ),
    );
  }
}

// ── Field helpers ──────────────────────────────────────────────────────────────

const _fieldTextStyle = TextStyle(
  fontFamily: 'Almarai',
  color: Colors.white,
  fontSize: 15,
);

InputDecoration _buildFieldDeco({
  required BuildContext context,
  required String hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontFamily: 'Almarai',
      color: Colors.white.withAlpha(70),
      fontSize: 14,
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: const Color(0xFF060912).withAlpha(200),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: const Color(0xFF4A9CD9).withAlpha(60)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: const Color(0xFF4A9CD9).withAlpha(60)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF4A9CD9), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: context.appError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: context.appError, width: 1.5),
    ),
    errorStyle: const TextStyle(fontFamily: 'Almarai', fontSize: 12),
  );
}

InputDecoration _buildPasswordDeco({
  required BuildContext context,
  required bool obscure,
  required VoidCallback onToggle,
}) {
  return _buildFieldDeco(
    context: context,
    hint: '••••••••',
    prefixIcon: const Icon(
      Icons.lock_outline_rounded,
      color: Color(0xFF4A9CD9),
      size: 20,
    ),
    suffixIcon: IconButton(
      icon: Icon(
        obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
        color: const Color(0xFF4A9CD9),
        size: 20,
      ),
      onPressed: onToggle,
    ),
  );
}

// ── Field label ────────────────────────────────────────────────────────────────

class _AuthFieldLabel extends StatelessWidget {
  const _AuthFieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Almarai',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white.withAlpha(200),
      ),
    );
  }
}

// ── Circle nav button ──────────────────────────────────────────────────────────

class _CircleNavButton extends StatelessWidget {
  const _CircleNavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF4A9CD9).withAlpha(25),
          border: Border.all(
            color: const Color(0xFF4A9CD9).withAlpha(80),
            width: 1.2,
          ),
        ),
        child: Icon(icon, color: const Color(0xFF4A9CD9), size: 20),
      ),
    );
  }
}

// ── Password strength bar ──────────────────────────────────────────────────────

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({
    required this.strength,
    required this.label,
    required this.strengthLabel,
  });

  final int strength;
  final String label;
  final String strengthLabel;

  @override
  Widget build(BuildContext context) {
    final color = _strengthColor(strength);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(4, (i) {
            final active = i < strength;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                height: 4,
                decoration: BoxDecoration(
                  color: active ? color : Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 12,
                color: Colors.white.withAlpha(140),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              strengthLabel,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── State dropdown field ───────────────────────────────────────────────────────

class _StateDropdownField extends StatelessWidget {
  const _StateDropdownField({
    required this.context,
    required this.selectedState,
    required this.isDark,
    required this.isRtl,
    required this.onTap,
  });

  final BuildContext context;
  final String? selectedState;
  final bool isDark;
  final bool isRtl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext _) {
    final hasValue = selectedState != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF060912).withAlpha(200),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue
                ? const Color(0xFF4A9CD9)
                : const Color(0xFF4A9CD9).withAlpha(60),
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: isRtl
              ? [
                  const Icon(
                    Icons.map_outlined,
                    color: Color(0xFF4A9CD9),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedState ?? context.t('field.state_hint'),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 14,
                        color: hasValue
                            ? Colors.white
                            : Colors.white.withAlpha(70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF4A9CD9),
                    size: 22,
                  ),
                ]
              : [
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF4A9CD9),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedState ?? context.t('field.state_hint'),
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 14,
                        color: hasValue
                            ? Colors.white
                            : Colors.white.withAlpha(70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.map_outlined,
                    color: Color(0xFF4A9CD9),
                    size: 20,
                  ),
                ],
        ),
      ),
    );
  }
}

// ── Terms row ──────────────────────────────────────────────────────────────────

class _TermsRow extends StatelessWidget {
  const _TermsRow({
    required this.context,
    required this.accepted,
    required this.onChanged,
  });

  final BuildContext context;
  final bool accepted;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext _) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: accepted,
            onChanged: onChanged,
            activeColor: const Color(0xFF4A9CD9),
            checkColor: Colors.white,
            side: BorderSide(
              color: const Color(0xFF4A9CD9).withAlpha(150),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            children: [
              Text(
                context.t('auth.register.agree_terms'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 13,
                  color: Colors.white.withAlpha(155),
                  height: 1.6,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const TermsOfUseScreen()),
                ),
                child: Text(
                  context.t('auth.register.terms_use'),
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 13,
                    color: Color(0xFF4A9CD9),
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
              ),
              Text(
                context.t('auth.register.and_privacy'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 13,
                  color: Colors.white.withAlpha(155),
                  height: 1.6,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyPolicyScreen(showDeleteAccount: false),
                  ),
                ),
                child: Text(
                  context.t('auth.register.privacy_policy'),
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 13,
                    color: Color(0xFF4A9CD9),
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
              ),
              Text(
                context.t('auth.register.terms_suffix'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 13,
                  color: Colors.white.withAlpha(155),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── State picker bottom sheet ──────────────────────────────────────────────────

class _StatePickerSheet extends StatefulWidget {
  const _StatePickerSheet({
    required this.isDark,
    required this.isRtl,
    required this.currentValue,
    required this.onSelected,
  });

  final bool isDark;
  final bool isRtl;
  final String? currentValue;
  final ValueChanged<String> onSelected;

  @override
  State<_StatePickerSheet> createState() => _StatePickerSheetState();
}

class _StatePickerSheetState extends State<_StatePickerSheet> {
  final _searchCtrl = TextEditingController();
  List<(String, String)> _filtered = _usStates;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _filtered = _usStates
          .where((s) => s.$1.toLowerCase().contains(lower) || s.$2.contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF0D1E3A) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0D1B3E);
    final dividerColor = widget.isDark ? Colors.white12 : Colors.black12;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollCtrl) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: const Color(0xFF4A9CD9).withAlpha(60),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A9CD9).withAlpha(120),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearch,
                      textDirection: widget.isRtl
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        color: textColor,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.isRtl ? 'ابحث...' : 'Search...',
                        hintStyle: TextStyle(
                          fontFamily: 'Almarai',
                          color: textColor.withAlpha(100),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF4A9CD9),
                        ),
                        filled: true,
                        fillColor: widget.isDark
                            ? const Color(0xFF0A2050)
                            : const Color(0xFFF0F4F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: dividerColor, height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollCtrl,
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final entry = _filtered[i];
                        final name = widget.isRtl ? entry.$2 : entry.$1;
                        final isSelected = widget.currentValue == name;

                        return InkWell(
                          onTap: () => widget.onSelected(name),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4A9CD9).withAlpha(30)
                                  : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(color: dividerColor),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontFamily: 'Almarai',
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? const Color(0xFF4A9CD9)
                                          : textColor,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_rounded,
                                    color: Color(0xFF4A9CD9),
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
