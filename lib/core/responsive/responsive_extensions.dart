import 'package:flutter/widgets.dart';
import 'responsive.dart';

/// Convenience extensions on [BuildContext] for responsive values.
extension ResponsiveX on BuildContext {
  Responsive get responsive => Responsive.of(this);

  double get w => responsive.width;
  double get h => responsive.height;
  bool get isTablet => responsive.isTablet;
  bool get isDesktop => responsive.isDesktop;
  bool get isLandscape => responsive.isLandscape;

  /// Scales [size] (pt) to the current screen width, respecting a11y scaling.
  /// Arabic body text floor: 15pt.
  double sp(double size) => responsive.sp(size);
}
