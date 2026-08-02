import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// A themed [Shimmer] wrapper for a single skeleton block — the base unit
/// every skeleton layout in [skeleton_list_tile.dart]/[skeleton_card.dart]
/// is built from. Colors are drawn from the app's glass palette so it reads
/// consistently in both light and dark themes.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.width, this.height, this.radius = 8});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.appGlassTint,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Wraps [child] (a tree of [ShimmerBox]es) in the shimmer sweep animation.
/// Apply once per skeleton layout, not per box.
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = context.appGlassTint;
    final highlight = context.appSurface;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: child,
    );
  }
}
