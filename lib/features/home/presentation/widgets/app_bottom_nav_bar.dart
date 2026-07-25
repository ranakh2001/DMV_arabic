import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/home_tab_provider.dart';

class _NavItemData {
  const _NavItemData(this.tab, this.icon, this.labelKey);
  final HomeTab tab;
  final IconData icon;
  final String labelKey;
}

/// Visual order matches RTL start→end: Home renders at the right edge,
/// My Account at the left edge — mirroring the source design.
const _kNavItems = [
  _NavItemData(HomeTab.home, Icons.home_rounded, 'nav.home'),
  _NavItemData(HomeTab.simulation, Icons.directions_car_rounded, 'nav.simulation'),
  _NavItemData(HomeTab.stats, Icons.bar_chart_rounded, 'nav.stats'),
  _NavItemData(HomeTab.profile, Icons.person_rounded, 'nav.profile'),
];

/// Floating pill-style bottom navigation bar. Tabs beyond Home are wired to
/// simple placeholder screens (per spec — no additional feature UI here).
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final HomeTab current;
  final ValueChanged<HomeTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.sp(18), 0, context.sp(18), context.sp(18)),
      child: Container(
        height: context.sp(66),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1B3D),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: context.appGlassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (final item in _kNavItems)
              Expanded(
                child: _NavItem(
                  icon: item.icon,
                  label: context.t(item.labelKey),
                  active: item.tab == current,
                  onTap: () => onSelect(item.tab),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Center(
          child: Container(
            width: context.sp(46),
            height: context.sp(46),
            decoration: BoxDecoration(
              color: context.appPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.appPrimary.withAlpha(140),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: context.sp(24)),
          ),
        ),
      );
    }

    final color = context.appTextSecondary;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: context.sp(22)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(11),
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
