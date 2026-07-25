import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The four tabs shown on the main bottom navigation bar.
/// Order matches their visual position in an RTL layout: [home] renders at
/// the start (right edge) and [profile] renders at the end (left edge).
enum HomeTab { home, simulation, stats, profile }

/// Tracks which bottom-nav tab is currently active.
class HomeTabNotifier extends Notifier<HomeTab> {
  @override
  HomeTab build() => HomeTab.home;

  void select(HomeTab tab) => state = tab;
}

final homeTabProvider = NotifierProvider<HomeTabNotifier, HomeTab>(
  HomeTabNotifier.new,
);
