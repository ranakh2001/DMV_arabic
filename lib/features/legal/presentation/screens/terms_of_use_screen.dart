import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/legal_providers.dart';
import '../widgets/legal_async_content.dart';
import '../widgets/legal_scaffold.dart';
import '../widgets/legal_section_card.dart';

/// "شروط الاستخدام" — reached from the sign-up screen's terms checkbox
/// and from the Privacy Policy screen. Ends with a Continue action that
/// simply acknowledges the terms and closes the screen; the actual
/// sign-up flow is unaffected by this screen. Content is fetched live from
/// `GET /terms`.
class TermsOfUseScreen extends ConsumerWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(termsProvider);

    return LegalScaffold(
      title: context.t('legal.terms.title'),
      updatedDate: context.t('legal.terms.updated_date'),
      footer: const _ContinueFooter(),
      children: [
        contentAsync.when(
          data: (content) => LegalSectionCard(
            icon: Icons.description_outlined,
            title: content.title,
            body: content.content,
          ),
          loading: () => const LegalLoadingCard(),
          error: (error, _) => LegalErrorCard(
            message: error is Failure
                ? error.messageAr
                : context.t('error.unknown'),
            onRetry: () => ref.invalidate(termsProvider),
          ),
        ),
      ],
    );
  }
}

class _ContinueFooter extends StatelessWidget {
  const _ContinueFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.sp(20),
        context.sp(14),
        context.sp(20),
        context.sp(16),
      ),
      decoration: BoxDecoration(
        color: context.appBackground,
        border: Border(top: BorderSide(color: context.appGlassBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.t('legal.terms.footer_note'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(12),
              color: context.appTextSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: context.sp(12)),
          SizedBox(
            width: double.infinity,
            height: context.sp(50),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                context.t('legal.terms.continue'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
