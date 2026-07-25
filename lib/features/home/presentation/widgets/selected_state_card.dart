import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

const _kUsStates = [
  ('Alabama', 'ألاباما'),
  ('Alaska', 'ألاسكا'),
  ('Arizona', 'أريزونا'),
  ('Arkansas', 'أركنساس'),
  ('California', 'كاليفورنيا'),
  ('Colorado', 'كولورادو'),
  ('Connecticut', 'كونيتيكت'),
  ('Delaware', 'ديلاوير'),
  ('Florida', 'فلوريدا'),
  ('Georgia', 'جورجيا'),
  ('Hawaii', 'هاواي'),
  ('Idaho', 'أيداهو'),
  ('Illinois', 'إلينوي'),
  ('Indiana', 'إنديانا'),
  ('Iowa', 'آيوا'),
  ('Kansas', 'كانساس'),
  ('Kentucky', 'كنتاكي'),
  ('Louisiana', 'لويزيانا'),
  ('Maine', 'مين'),
  ('Maryland', 'ماريلاند'),
  ('Massachusetts', 'ماساتشوستس'),
  ('Michigan', 'ميشيغان'),
  ('Minnesota', 'مينيسوتا'),
  ('Mississippi', 'ميسيسيبي'),
  ('Missouri', 'ميسوري'),
  ('Montana', 'مونتانا'),
  ('Nebraska', 'نيبراسكا'),
  ('Nevada', 'نيفادا'),
  ('New Hampshire', 'نيو هامبشير'),
  ('New Jersey', 'نيوجيرسي'),
  ('New Mexico', 'نيو مكسيكو'),
  ('New York', 'نيويورك'),
  ('North Carolina', 'كارولينا الشمالية'),
  ('North Dakota', 'داكوتا الشمالية'),
  ('Ohio', 'أوهايو'),
  ('Oklahoma', 'أوكلاهوما'),
  ('Oregon', 'أوريغون'),
  ('Pennsylvania', 'بنسلفانيا'),
  ('Rhode Island', 'رود آيلاند'),
  ('South Carolina', 'كارولينا الجنوبية'),
  ('South Dakota', 'داكوتا الجنوبية'),
  ('Tennessee', 'تينيسي'),
  ('Texas', 'تكساس'),
  ('Utah', 'يوتا'),
  ('Vermont', 'فيرمونت'),
  ('Virginia', 'فيرجينيا'),
  ('Washington', 'واشنطن'),
  ('West Virginia', 'فيرجينيا الغربية'),
  ('Wisconsin', 'ويسكونسن'),
  ('Wyoming', 'وايومنغ'),
];

/// Glass card showing the user's selected DMV state. Tapping it opens a
/// searchable bottom sheet to change it — fully self-contained, no
/// navigation to another screen.
class SelectedStateCard extends StatelessWidget {
  const SelectedStateCard({
    super.key,
    required this.selectedState,
    required this.onChanged,
  });

  final String selectedState;
  final ValueChanged<String> onChanged;

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
              child: Icon(Icons.location_on_rounded, color: context.appPrimary, size: context.sp(22)),
            ),
            SizedBox(width: context.sp(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                  SizedBox(height: context.sp(4)),
                  Text(
                    selectedState,
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
            Icon(Icons.chevron_left_rounded, color: context.appTextSecondary, size: context.sp(22)),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatePickerSheet(
        isAr: isAr,
        currentValue: selectedState,
        onSelected: onChanged,
      ),
    );
  }
}

class _StatePickerSheet extends StatefulWidget {
  const _StatePickerSheet({
    required this.isAr,
    required this.currentValue,
    required this.onSelected,
  });

  final bool isAr;
  final String currentValue;
  final ValueChanged<String> onSelected;

  @override
  State<_StatePickerSheet> createState() => _StatePickerSheetState();
}

class _StatePickerSheetState extends State<_StatePickerSheet> {
  final _searchCtrl = TextEditingController();
  List<(String, String)> _filtered = _kUsStates;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _filtered = _kUsStates
          .where((s) => s.$1.toLowerCase().contains(lower) || s.$2.contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.appBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: context.appGlassBorder),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appPrimary.withAlpha(120),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: context.sp(16)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
                child: Text(
                  context.t('profile.select_state_sheet_title'),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(17),
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                  ),
                ),
              ),
              SizedBox(height: context.sp(12)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(fontFamily: 'Almarai', color: context.appTextPrimary),
                  decoration: InputDecoration(
                    hintText: context.t('onboarding.slide3.search'),
                    prefixIcon: Icon(Icons.search_rounded, color: context.appPrimary),
                  ),
                ),
              ),
              SizedBox(height: context.sp(8)),
              Divider(height: 1, color: context.appGlassBorder),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) {
                    final state = _filtered[i];
                    final displayName = widget.isAr ? state.$2 : state.$1;
                    final isSelected = widget.currentValue == displayName;

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onSelected(displayName);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.sp(24),
                          vertical: context.sp(15),
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? context.appPrimary.withAlpha(30) : Colors.transparent,
                          border: Border(bottom: BorderSide(color: context.appGlassBorder)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: context.sp(16),
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                  color: isSelected ? context.appPrimary : context.appTextPrimary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_rounded, color: context.appPrimary, size: context.sp(20)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: context.sp(4)),
            ],
          ),
        );
      },
    );
  }
}
