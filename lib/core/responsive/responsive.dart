import 'package:flutter/widgets.dart';
import 'breakpoints.dart';

/// Snapshot of responsive metrics for the current [BuildContext].
class Responsive {
  const Responsive._({
    required this.size,
    required this.orientation,
    required this.devicePixelRatio,
    required this.textScaler,
  });

  factory Responsive.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Responsive._(
      size: mq.size,
      orientation: mq.orientation,
      devicePixelRatio: mq.devicePixelRatio,
      textScaler: mq.textScaler,
    );
  }

  final Size size;
  final Orientation orientation;
  final double devicePixelRatio;
  final TextScaler textScaler;

  double get width => size.width;
  double get height => size.height;

  bool get isPhone => width <= Breakpoints.phoneMax;
  bool get isTablet =>
      width > Breakpoints.phoneMax && width <= Breakpoints.tabletMax;
  bool get isDesktop => width > Breakpoints.tabletMax;
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  /// Scales [size] relative to [Breakpoints.referenceWidth], then applies
  /// accessibility text scaling. Arabic body text is clamped to >= 15pt.
  double sp(double size) {
    final scaled = size * (width / Breakpoints.referenceWidth);
    final withA11y = textScaler.scale(scaled);
    return withA11y.clamp(15.0, double.infinity);
  }
}
