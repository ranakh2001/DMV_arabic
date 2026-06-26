import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/verify_controller_provider.dart';

/// Google + Apple social sign-in buttons.
class SocialButtons extends ConsumerWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final social = ref.watch(socialLoginControllerProvider);

    return Column(
      children: [
        Divider(
          height: 32,
          color: context.appTextDisabled,
        ),
        Text(
          context.t('common.or'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: context.appTextSecondary),
        ),
        const SizedBox(height: 16),
        _SocialButton(
          label: context.t('auth.social.google'),
          icon: Icons.g_mobiledata,
          onPressed: social.isSubmitting
              ? null
              : () => ref.read(socialLoginControllerProvider.notifier).loginWithGoogle(),
        ),
        const SizedBox(height: 12),
        _SocialButton(
          label: context.t('auth.social.apple'),
          icon: Icons.apple,
          onPressed: social.isSubmitting
              ? null
              : () => ref.read(socialLoginControllerProvider.notifier).loginWithApple(),
        ),
        if (social.isFailure && social.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              social.error!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.appError),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon, this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
