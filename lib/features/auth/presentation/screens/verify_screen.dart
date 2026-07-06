import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/verify_controller_provider.dart';
import '../widgets/auth_scaffold.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key, required this.contact});

  final String contact;

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(verifyControllerProvider.notifier).verify(
          contact: widget.contact,
          code: _codeCtrl.text.trim(),
        );
  }

  String _formatSeconds(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyControllerProvider);

    return AuthScaffold(
      title: context.t('auth.verify.title'),
      subtitle:
          '${context.t('auth.verify.subtitle')} ${widget.contact}',
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Expiry countdown
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.isExpired ? Icons.timer_off : Icons.timer,
                  size: 18,
                  color: state.isExpired
                      ? context.appError
                      : context.appTextSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  state.isExpired
                      ? context.t('auth.verify.expired')
                      : '${context.t('auth.verify.expires_in')} ${_formatSeconds(state.secondsRemaining)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: state.isExpired
                            ? context.appError
                            : context.appTextSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              enabled: !state.isExpired,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: context.t('field.code'),
                counterText: '',
              ),
              validator: Validators.verificationCode(context),
            ),
            const SizedBox(height: 20),

            if (state.error != null)
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
              onPressed: (state.isSubmitting || state.isExpired) ? null : _submit,
              child: state.isSubmitting
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(context.t('auth.verify.submit')),
            ),
            const SizedBox(height: 12),

            // Resend button
            if (state.maxResendsReached)
              Text(
                context.t('auth.verify.max_resends'),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.appError),
                textAlign: TextAlign.center,
              )
            else if (state.resendCooldownSeconds > 0)
              Text(
                '${context.t('auth.verify.resend_in')} ${_formatSeconds(state.resendCooldownSeconds)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.appTextSecondary),
                textAlign: TextAlign.center,
              )
            else
              TextButton(
                onPressed: () => ref
                    .read(verifyControllerProvider.notifier)
                    .resend(contact: widget.contact),
                child: Text(context.t('auth.verify.resend')),
              ),
          ],
        ),
      ),
    );
  }
}
