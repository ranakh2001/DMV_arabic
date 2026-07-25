import 'package:flutter/material.dart';
import '../responsive/responsive_extensions.dart';
import '../theme/app_colors.dart';

/// A row of selectable pill chips (wraps to multiple lines on narrow
/// screens) — e.g. the "request type" picker on the Contact Us screen.
/// Generic over [T] so selection survives a locale change (the chip is
/// keyed by value, not by its translated label).
class SelectableChipGroup<T> extends StatelessWidget {
  const SelectableChipGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<(T value, String label)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.sp(8),
      runSpacing: context.sp(8),
      children: options.map((option) {
        final selected = option.$1 == value;
        return InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () => onChanged(option.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: context.sp(16), vertical: context.sp(10)),
            decoration: BoxDecoration(
              color: selected ? context.appPrimary.withAlpha(30) : context.appGlassTint,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: selected ? context.appPrimary : context.appGlassBorder),
            ),
            child: Text(
              option.$2,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(13),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? context.appPrimary : context.appTextSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
