import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import 'plan_feature_row.dart';

/// Pricing card for a single subscription plan. Renders both the plain
/// (monthly) and highlighted/best-value (yearly) variants, so the two plan
/// cards on the subscription screen share one implementation.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.periodSuffix,
    required this.featureLabels,
    required this.buttonLabel,
    required this.onSelect,
    this.badgeLabel,
    this.highlighted = false,
  });

  final String title;
  final String price;
  final String periodSuffix;
  final List<String> featureLabels;
  final String buttonLabel;
  final VoidCallback onSelect;
  final String? badgeLabel;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;
    final hasBadge = badgeLabel != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(top: hasBadge ? context.sp(14) : 0),
          padding: EdgeInsets.fromLTRB(
            context.sp(20),
            context.sp(hasBadge ? 28 : 20),
            context.sp(20),
            context.sp(20),
          ),
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: highlighted ? accent : context.appGlassBorder,
              width: highlighted ? 1.6 : 1,
            ),
            boxShadow: highlighted
                ? [BoxShadow(color: accent.withAlpha(55), blurRadius: 24, offset: const Offset(0, 8))]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(20),
                  fontWeight: FontWeight.w800,
                  color: context.appTextPrimary,
                ),
              ),
              SizedBox(height: context.sp(8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(30),
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                  SizedBox(width: context.sp(6)),
                  Text(
                    periodSuffix,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(13),
                      color: context.appTextSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.sp(18)),
              ...featureLabels.map((label) => PlanFeatureRow(label: label, accentColor: accent)),
              SizedBox(height: context.sp(18)),
              highlighted
                  ? _GradientButton(label: buttonLabel, onTap: onSelect)
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onSelect,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accent,
                          side: BorderSide(color: accent),
                          padding: EdgeInsets.symmetric(vertical: context.sp(15)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          buttonLabel,
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontWeight: FontWeight.w700,
                            fontSize: context.sp(15),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
        if (hasBadge)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: context.sp(16), vertical: context.sp(6)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [context.appPrimary, context.appSecondary]),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  badgeLabel!,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [context.appPrimary, context.appSecondary]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: context.appPrimary.withAlpha(90), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: context.sp(15)),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w700,
                  fontSize: context.sp(15),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
