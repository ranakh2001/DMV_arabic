import 'package:flutter/material.dart';
import '../responsive/responsive_extensions.dart';
import 'shimmer_box.dart';

/// A single large skeleton block (plan card / question card / stat card
/// shape) — drop-in replacement for a bare [CircularProgressIndicator] on
/// any card-shaped loading state.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 140, this.radius = 18});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ShimmerBox(
        width: double.infinity,
        height: context.sp(height),
        radius: context.sp(radius),
      ),
    );
  }
}

/// [count] [SkeletonCard]s stacked with the app's standard card spacing.
class SkeletonCardList extends StatelessWidget {
  const SkeletonCardList({super.key, this.count = 2, this.height = 140});

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          SkeletonCard(height: height),
          if (i != count - 1) SizedBox(height: context.sp(20)),
        ],
      ],
    );
  }
}
