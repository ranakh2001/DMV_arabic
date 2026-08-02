import 'package:flutter/material.dart';
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

/// "من نحن" — reached from the Profile tab. Content is fetched live from
/// `GET /about`.
class AboutUsScreen extends ConsumerWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aboutAsync = ref.watch(aboutUsProvider);

    return LegalScaffold(
      title: context.t('legal.about.title'),
      metaText: aboutAsync.maybeWhen(
        data: (info) =>
            context.ts('legal.about.version', {'version': info.version}),
        orElse: () => context.t('common.loading'),
      ),
      children: [
        aboutAsync.when(
          data: (info) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassContainer(
                radius: 20,
                padding: EdgeInsets.symmetric(
                  vertical: context.sp(28),
                  horizontal: context.sp(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: context.sp(72),
                      height: context.sp(72),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.appPrimary.withAlpha(30),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: context.sp(34),
                        color: context.appPrimary,
                      ),
                    ),
                    SizedBox(height: context.sp(14)),
                    Text(
                      info.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: context.sp(20),
                        fontWeight: FontWeight.w800,
                        color: context.appTextPrimary,
                      ),
                    ),
                    SizedBox(height: context.sp(8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.sp(12),
                        vertical: context.sp(6),
                      ),
                      decoration: BoxDecoration(
                        color: context.appPrimary.withAlpha(20),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        context.ts('legal.about.version', {
                          'version': info.version,
                        }),
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: context.sp(12),
                          fontWeight: FontWeight.w700,
                          color: context.appPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.sp(14)),
              LegalSectionCard(
                icon: Icons.description_outlined,
                title: context.t('legal.about.description_title'),
                body: info.description,
              ),
            ],
          ),
          loading: () => const LegalLoadingCard(),
          error: (error, _) => LegalErrorCard(
            message: error is Failure
                ? error.messageAr
                : context.t('error.unknown'),
            onRetry: () => ref.invalidate(aboutUsProvider),
          ),
        ),
      ],
    );
  }
}
