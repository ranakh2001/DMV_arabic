import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/legal_checklist_item.dart';
import '../widgets/legal_highlight_banner.dart';
import '../widgets/legal_scaffold.dart';
import '../widgets/legal_section_card.dart';

/// "شروط الاستخدام" — reached from the sign-up screen's terms checkbox
/// and from the Privacy Policy screen. Ends with a Continue action that
/// simply acknowledges the terms and closes the screen; the actual
/// sign-up flow is unaffected by this screen.
class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalScaffold(
      title: context.t('legal.terms.title'),
      updatedDate: context.t('legal.terms.updated_date'),
      footer: const _ContinueFooter(),
      children: [
        LegalSectionCard(
          icon: Icons.front_hand_outlined,
          title: context.t('legal.terms.s1.title'),
          body: context.t('legal.terms.s1.body'),
        ),
        SizedBox(height: context.sp(14)),
        LegalSectionCard(
          icon: Icons.description_outlined,
          title: context.t('legal.terms.s2.title'),
          body: context.t('legal.terms.s2.body'),
        ),
        SizedBox(height: context.sp(14)),
        LegalHighlightBanner(icon: Icons.shield_outlined, text: context.t('legal.terms.highlight')),
        SizedBox(height: context.sp(14)),
        LegalSectionCard(
          icon: Icons.person_outline_rounded,
          title: context.t('legal.terms.s3.title'),
          children: [
            LegalChecklistItem(text: context.t('legal.terms.s3.item1')),
            LegalChecklistItem(text: context.t('legal.terms.s3.item2')),
            LegalChecklistItem(text: context.t('legal.terms.s3.item3')),
          ],
        ),
        SizedBox(height: context.sp(14)),
        LegalSectionCard(
          icon: Icons.warning_amber_rounded,
          title: context.t('legal.terms.s4.title'),
          body: context.t('legal.terms.s4.body'),
        ),
        SizedBox(height: context.sp(14)),
        LegalSectionCard(
          icon: Icons.update_rounded,
          title: context.t('legal.terms.s5.title'),
          body: context.t('legal.terms.s5.body'),
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
      padding: EdgeInsets.fromLTRB(context.sp(20), context.sp(14), context.sp(20), context.sp(16)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
