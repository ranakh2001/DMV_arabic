import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Overlays a blank branded screen when the app is inactive or paused so that
/// the OS app-switcher snapshot does not reveal sensitive content.
///
/// Usage: wrap [MaterialApp] or a root scaffold with this observer.
class AppShield extends StatefulWidget {
  const AppShield({super.key, required this.child});

  final Widget child;

  @override
  State<AppShield> createState() => _AppShieldState();
}

class _AppShieldState extends State<AppShield> with WidgetsBindingObserver {
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Obscure while inactive or paused so the switcher snapshot is blank.
    // TODO(security): On Android, also set FLAG_SECURE via a platform channel.
    setState(() {
      _obscured = state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        KeyedSubtree(key: const ValueKey('app_shield_child'), child: widget.child),
        if (_obscured) const _Shield(key: ValueKey('app_shield_overlay')),
      ],
    );
  }
}

class _Shield extends StatelessWidget {
  const _Shield({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? AppColorsDark.background : AppColorsLight.background,
      child: Center(
        child: Text(
          AppConstants.appName,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColorsDark.primary : AppColorsLight.primary,
          ),
        ),
      ),
    );
  }
}
