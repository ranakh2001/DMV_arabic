import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import '../../../states/domain/entities/us_state.dart';
import '../../../states/presentation/widgets/state_picker_sheet.dart';

/// Glass card showing the user's selected DMV state, backed by `GET /states`.
/// Tapping it opens the shared searchable bottom sheet to change it.
class SelectedStateCard extends StatelessWidget {
  const SelectedStateCard({
    super.key,
    required this.displayName,
    required this.currentStateId,
    required this.onChanged,
  });

  final String displayName;
  final int? currentStateId;
  final ValueChanged<UsState> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openPicker(context),
      child: GlassContainer(
        radius: 20,
        child: Row(
          children: [
            Container(
              width: context.sp(42),
              height: context.sp(42),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.appPrimary.withAlpha(30),
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: context.appPrimary,
                size: context.sp(22),
              ),
            ),
            SizedBox(width: context.sp(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.t('profile.selected_state'),
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(13),
                      color: context.appTextSecondary,
                    ),
                  ),

                  Text(
                    displayName,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(18),
                      fontWeight: FontWeight.w800,
                      color: context.appPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.appTextSecondary,
              size: context.sp(22),
            ),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    showStatePickerSheet(context, currentStateId: currentStateId, onSelected: onChanged);
  }
}
