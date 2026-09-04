import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_controller_provider.dart';
import '../providers/profile_providers.dart';

/// The "حذف الحساب" (Delete Account) action shown at the bottom of the
/// Settings screen, below "تسجيل الخروج" (Logout). Filled (rather than
/// outlined like Logout) with a warning icon, since deletion is permanent
/// and irreversible while logout is not.
class DeleteAccountSection extends ConsumerWidget {
  const DeleteAccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deleteAccountControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: state.isSubmitting
              ? null
              : () => _confirmDelete(context, ref),
          style: FilledButton.styleFrom(
            backgroundColor: context.appError,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: context.sp(14)),
          ),
          icon: state.isSubmitting
              ? SizedBox.square(
                  dimension: context.sp(18),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.warning_amber_rounded),
          label: Text(context.t('profile.delete_account')),
        ),
        SizedBox(height: context.sp(8)),
        Text(
          context.t('profile.delete_account.subtitle'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(12),
            color: context.appTextSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.t('profile.delete_account.confirm_title')),
        content: Text(
          dialogContext.t('profile.delete_account.confirm_message'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.t('common.cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: dialogContext.appError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.t('common.confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final succeeded = await ref
        .read(deleteAccountControllerProvider.notifier)
        .submit();
    if (!context.mounted) return;

    if (succeeded) {
      // Server has already disabled/anonymized the account; clear the local
      // session so the root navigator falls back to the welcome/login flow.
      await ref.read(authControllerProvider.notifier).logout();
      return;
    }

    final error = ref.read(deleteAccountControllerProvider).error;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? context.t('error.unknown'))));
  }
}
