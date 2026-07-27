import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_tab_provider.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/home_background.dart';
import 'home_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'simulation_screen.dart';
import 'stats_screen.dart';

/// Root authenticated screen: hosts the bottom navigation bar and swaps
/// between the four main tabs.
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  final _navBarKey = GlobalKey();
  double _navBarHeight = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureNavBar());
  }

  void _measureNavBar() {
    final renderBox = _navBarKey.currentContext?.findRenderObject() as RenderBox?;
    final height = renderBox?.size.height ?? 0;
    if (mounted && height != _navBarHeight) {
      setState(() => _navBarHeight = height);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(homeTabProvider);

    return Scaffold(
      body: Stack(
        children: [
          const HomeBackground(),
          Padding(
            padding: EdgeInsets.only(bottom: _navBarHeight),
            child: IndexedStack(
              index: currentTab.index,
              children: [
                HomeScreen(),
                SimulationScreen(),
                StatsScreen(),
                ProfileScreen(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: AppBottomNavBar(
                key: _navBarKey,
                current: currentTab,
                onSelect: (tab) => ref.read(homeTabProvider.notifier).select(tab),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
