import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_controller_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/social_buttons.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'verify_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(loginControllerProvider.notifier).login(
          contact: _contactCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);

    // BR-02: unverified account → navigate to verify
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

    return AuthScaffold(
      title: context.t('auth.login.title'),
      subtitle: context.t('auth.login.subtitle'),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _contactCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.t('field.email_or_phone'),
              ),
              validator: Validators.emailOrPhone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: context.t('field.password'),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: Validators.password,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                ),
                child: Text(context.t('auth.login.forgot')),
              ),
            ),
            if (state.isFailure &&
                state.error != null &&
                !state.error!.startsWith('UNVERIFIED:'))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  state.error!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: context.appError),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: state.isSubmitting ? null : _submit,
              child: state.isSubmitting
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(context.t('auth.login.submit')),
            ),
            const SocialButtons(),
          ],
        ),
      ),
      bottom: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.t('auth.login.no_account')),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const RegisterScreen(),
              ),
            ),
            child: Text(context.t('auth.login.sign_up')),
          ),
        ],
      ),
    );
  }
}
