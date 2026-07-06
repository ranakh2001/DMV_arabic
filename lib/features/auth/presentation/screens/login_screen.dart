import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_controller_provider.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'verify_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
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
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(loginControllerProvider.notifier)
        .login(contact: _contactCtrl.text.trim(), password: _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(loginControllerProvider, (_, next) {
      if (next.isFailure && (next.error?.startsWith('UNVERIFIED:') ?? false)) {
        final contact = next.error!.replaceFirst('UNVERIFIED:', '');
        ref.read(loginControllerProvider.notifier).reset();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VerifyScreen(contact: contact),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────────────
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

          // ── Decorative blobs ─────────────────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
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
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A9CD9).withAlpha(25),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  children: [
                    // ── Top bar with back button ───────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,

                        children: [
                          _CircleNavButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                    ),

                    // ── Scrollable body ────────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title
                            Text(
                              context.t('auth.login.title'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Almarai',
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              context.t('auth.login.subtitle'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Almarai',
                                fontSize: 14,
                                color: Colors.white.withAlpha(155),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 36),

                            // ── Glass form card ───────────────────────────
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 22,
                                  sigmaY: 22,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF0B1830).withAlpha(155)
                                        : Colors.white.withAlpha(20),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF4A9CD9,
                                      ).withAlpha(90),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(60),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: const Color(
                                          0xFF4A9CD9,
                                        ).withAlpha(18),
                                        blurRadius: 26,
                                        spreadRadius: -4,
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Phone field
                                        _AuthFieldLabel(
                                          context.t('field.phone'),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _contactCtrl,
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.next,
                                          style: const TextStyle(
                                            fontFamily: 'Almarai',
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
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

                                        // Password field
                                        _AuthFieldLabel(
                                          context.t('field.password'),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _passwordCtrl,
                                          obscureText: _obscurePassword,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (_) => _submit(),
                                          style: const TextStyle(
                                            fontFamily: 'Almarai',
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
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

                                        const SizedBox(height: 12),

                                        // Forgot password
                                        Align(
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: GestureDetector(
                                            onTap: () => Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) =>
                                                    const ForgotPasswordScreen(),
                                              ),
                                            ),
                                            child: Text(
                                              context.t('auth.login.forgot'),
                                              style: const TextStyle(
                                                fontFamily: 'Almarai',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF4A9CD9),
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        // Error message
                                        if (state.isFailure &&
                                            state.error != null &&
                                            !state.error!.startsWith(
                                              'UNVERIFIED:',
                                            ))
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: context.appError
                                                    .withAlpha(30),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: context.appError
                                                      .withAlpha(100),
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

                                        // Login button with glow
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
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
                                                  borderRadius:
                                                      BorderRadius.circular(16),
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
                                                        'auth.login.submit',
                                                      ),
                                                      style: const TextStyle(
                                                        fontFamily: 'Almarai',
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ── No account link ───────────────────────────
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context.t('auth.login.no_account'),
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
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    context.t('auth.login.sign_up'),
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
}

// ── Shared field builder helpers ───────────────────────────────────────────────

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

// ── Shared field label ─────────────────────────────────────────────────────────

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

// ── Circular nav button ────────────────────────────────────────────────────────

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
