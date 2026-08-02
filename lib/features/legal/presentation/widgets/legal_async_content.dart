import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// Loading placeholder shown while a legal-content GET is in flight.
class LegalLoadingCard extends StatelessWidget {
  const LegalLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 20,
      padding: EdgeInsets.symmetric(vertical: context.sp(48)),
      child: Center(
        child: CircularProgressIndicator(color: context.appPrimary),
      ),
    );
  }
}

/// Error state with a retry action, shown when a legal-content GET fails.
class LegalErrorCard extends StatelessWidget {
  const LegalErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 20,
      padding: EdgeInsets.all(context.sp(20)),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: context.sp(32),
            color: context.appError,
          ),
          SizedBox(height: context.sp(10)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(14),
              color: context.appTextSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: context.sp(14)),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.t('common.retry')),
          ),
        ],
      ),
    );
  }
}
