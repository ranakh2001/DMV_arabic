import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import '../providers/legal_providers.dart';
import '../widgets/legal_async_content.dart';
import '../widgets/legal_scaffold.dart';
import '../widgets/legal_section_card.dart';

/// "سياسة الخصوصية والشروط" — reached from the Settings screen (My Account)
/// and from the sign-up screen's terms checkbox. Content is fetched live
/// from `GET /privacy-policy`. Account deletion lives in the Settings
/// screen, not here — see [DeleteAccountSection].
class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(privacyPolicyProvider);

    return LegalScaffold(
      title: context.t('legal.privacy.title'),
      updatedDate: context.t('legal.privacy.updated_date'),
      children: [
        contentAsync.when(
          data: (content) => LegalSectionCard(
            number: 1,
            title: content.title,
            body: content.content,
          ),
          loading: () => const LegalLoadingCard(),
          error: (error, _) => LegalErrorCard(
            message: error is Failure
                ? error.messageAr
                : context.t('error.unknown'),
            onRetry: () => ref.invalidate(privacyPolicyProvider),
          ),
        ),
        SizedBox(height: context.sp(20)),
        const _ContactUsCard(),
      ],
    );
  }
}

class _ContactUsCard extends StatelessWidget {
  const _ContactUsCard();

  @override
  Widget build(BuildContext context) {
    final email = context.t('legal.contact.email');
    return GlassContainer(
      radius: 20,
      padding: EdgeInsets.all(context.sp(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.t('legal.privacy.contact.title'),
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(16),
              fontWeight: FontWeight.w700,
              color: context.appTextPrimary,
            ),
          ),
          SizedBox(height: context.sp(8)),
          Text(
            context.t('legal.privacy.contact.body'),
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(14),
              color: context.appTextSecondary,
              height: 1.7,
            ),
          ),
          SizedBox(height: context.sp(12)),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _copyEmail(context, email),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.sp(14),
                vertical: context.sp(12),
              ),
              decoration: BoxDecoration(
                color: context.appPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    size: context.sp(18),
                    color: context.appPrimary,
                  ),
                  SizedBox(width: context.sp(10)),
                  Expanded(
                    child: Text(
                      email,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w700,
                        color: context.appPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.copy_rounded,
                    size: context.sp(16),
                    color: context.appPrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyEmail(BuildContext context, String email) async {
    await Clipboard.setData(ClipboardData(text: email));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.t('legal.contact.copied'))));
  }
}
