import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_controller_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/social_buttons.dart';
import 'verify_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(registerControllerProvider.notifier).register(
          name: _nameCtrl.text.trim(),
          contact: _contactCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);

    ref.listen(registerControllerProvider, (_, next) {
      if (next.isSuccess) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => VerifyScreen(contact: _contactCtrl.text.trim()),
          ),
        );
      }
    });

    return AuthScaffold(
      title: context.t('auth.register.title'),
      subtitle: context.t('auth.register.subtitle'),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: context.t('field.name')),
              validator: Validators.name,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  labelText: context.t('field.email_or_phone')),
              validator: Validators.emailOrPhone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                  labelText: context.t('field.confirm_password')),
              validator: (v) =>
                  Validators.confirmPassword(v, _passwordCtrl.text),
            ),
            const SizedBox(height: 20),
            if (state.isFailure && state.error != null)
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
                  : Text(context.t('auth.register.submit')),
            ),
            const SocialButtons(),
          ],
        ),
      ),
      bottom: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.t('auth.register.have_account')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t('auth.register.sign_in')),
          ),
        ],
      ),
    );
  }
}
