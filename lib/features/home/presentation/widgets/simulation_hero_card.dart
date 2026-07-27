import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// Glass card at the top of the simulation tab: a car icon in a glowing
/// circle above the "ready to try the test?" prompt.
class SimulationHeroCard extends StatelessWidget {
  const SimulationHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 20,
      padding: EdgeInsets.symmetric(vertical: context.sp(28), horizontal: context.sp(20)),
      child: Column(
        children: [
          Container(
            width: context.sp(78),
            height: context.sp(78),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.appPrimary.withAlpha(30),
              boxShadow: [
                BoxShadow(color: context.appPrimary.withAlpha(60), blurRadius: 24, spreadRadius: -4),
              ],
            ),
            child: Icon(Icons.directions_car_filled_rounded, color: context.appPrimary, size: context.sp(38)),
          ),
          SizedBox(height: context.sp(18)),
          Text(
            context.t('simulation.ready_question'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(17),
              fontWeight: FontWeight.w700,
              color: context.appTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
