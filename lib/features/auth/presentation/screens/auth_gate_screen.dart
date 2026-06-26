import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_controller_provider.dart';

/// Authenticated-area placeholder. Shows the user's name and a logout button.
/// Replace with the real home screen in a subsequent feature module.
class AuthGateScreen extends ConsumerWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userName = authState.user?.name ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('app.name')),
        actions: [
          IconButton(
            tooltip: context.t('auth.logout'),
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 72,
              color: context.appSuccess,
            ),
            const SizedBox(height: 20),
            Text(
              context.t('home.greeting'),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (userName.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                userName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.appPrimary,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              context.t('home.welcome'),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.appTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t('auth.logout')),
        content: Text(context.t('auth.logout.confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.t('common.cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.t('auth.logout')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}
