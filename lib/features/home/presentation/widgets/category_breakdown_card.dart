import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import '../../../analytics/domain/entities/category_analytics.dart';

/// Glass card listing answer accuracy per question category, each as a
/// labeled progress bar — shown at the bottom of the stats tab.
class CategoryBreakdownCard extends StatelessWidget {
  const CategoryBreakdownCard({super.key, required this.categories});

  final List<CategoryAnalytics> categories;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.t('stats.by_category_title'),
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(16),
              fontWeight: FontWeight.w700,
              color: context.appTextPrimary,
            ),
          ),
          SizedBox(height: context.sp(16)),
          for (var i = 0; i < categories.length; i++) ...[
            _CategoryRow(category: categories[i]),
            if (i != categories.length - 1) SizedBox(height: context.sp(14)),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});

  final CategoryAnalytics category;

  @override
  Widget build(BuildContext context) {
    final name = context.isRtl ? category.nameAr : category.nameEn;
    final ratio = (category.correctRatio / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(13.5),
                  fontWeight: FontWeight.w600,
                  color: context.appTextPrimary,
                ),
              ),
            ),
            SizedBox(width: context.sp(8)),
            Text(
              '${category.correctAnswers}/${category.totalAnswers}',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(12),
                fontWeight: FontWeight.w700,
                color: context.appTextSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: context.sp(7)),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: context.sp(7),
            backgroundColor: context.appTextDisabled.withAlpha(60),
            valueColor: AlwaysStoppedAnimation(context.appPrimary),
          ),
        ),
      ],
    );
  }
}
