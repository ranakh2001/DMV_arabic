import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import 'language_toggle_chip.dart';

/// Shared chrome for the legal screens (Privacy Policy, Terms of Use):
/// a header with a back button, centered title and language toggle, a
/// "last updated" line, then a scrollable, width-capped body — optionally
/// topped off with a sticky [footer] (used by the Terms screen's Continue
/// button).
class LegalScaffold extends ConsumerWidget {
  const LegalScaffold({
    super.key,
    required this.title,
    this.updatedDate,
    this.metaText,
    required this.children,
    this.footer,
  }) : assert(
         updatedDate != null || metaText != null,
         'Provide either updatedDate or metaText.',
       );

  final String title;

  /// Rendered as "Last updated: {updatedDate}". Ignored when [metaText] is set.
  final String? updatedDate;

  /// A pre-formatted subtitle line, used instead of the "last updated" text
  /// when the "last updated" phrasing doesn't fit (e.g. About Us's version).
  final String? metaText;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.sp(12),
                context.sp(10),
                context.sp(16),
                context.sp(6),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: context.appTextPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: context.sp(18),
                        fontWeight: FontWeight.w800,
                        color: context.appTextPrimary,
                      ),
                    ),
                  ),
                  LanguageToggleChip(
                    isArabic: isArabic,
                    onChanged: (toArabic) => ref
                        .read(localeProvider.notifier)
                        .setLocale(Locale(toArabic ? 'ar' : 'en')),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.isDesktop || context.isTablet
                        ? 560
                        : double.infinity,
                  ),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      context.sp(20),
                      context.sp(8),
                      context.sp(20),
                      context.sp(24),
                    ),
                    children: [
                      Text(
                        metaText ??
                            context.ts('legal.last_updated', {
                              'date': updatedDate!,
                            }),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: context.sp(13),
                          color: context.appTextSecondary,
                        ),
                      ),
                      SizedBox(height: context.sp(20)),
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
            ?footer,
          ],
        ),
      ),
    );
  }
}
