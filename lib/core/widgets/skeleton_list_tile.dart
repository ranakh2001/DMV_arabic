import 'package:flutter/material.dart';
import '../responsive/responsive_extensions.dart';
import '../theme/app_colors.dart';
import 'shimmer_box.dart';

/// Skeleton for one glass list row (exam/plan/history tile shape: leading
/// circle, two text lines, optional trailing chip) — shown while the real
/// row data is loading.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.sp(14)),
      decoration: BoxDecoration(
        color: context.appGlassTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appGlassBorder),
      ),
      child: Row(
        children: [
          ShimmerBox(
            width: context.sp(42),
            height: context.sp(42),
            radius: context.sp(21),
          ),
          SizedBox(width: context.sp(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: double.infinity,
                  height: context.sp(14),
                  radius: 6,
                ),
                SizedBox(height: context.sp(8)),
                ShimmerBox(
                  width: context.sp(90),
                  height: context.sp(11),
                  radius: 6,
                ),
              ],
            ),
          ),
          SizedBox(width: context.sp(12)),
          ShimmerBox(
            width: context.sp(56),
            height: context.sp(28),
            radius: context.sp(14),
          ),
        ],
      ),
    );
  }
}

/// A column of [count] [SkeletonListTile]s, shimmering together — drop-in
/// replacement for a bare [CircularProgressIndicator] on any list-shaped
/// loading state (exam list, plan list, history list).
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            const SkeletonListTile(),
            if (i != count - 1) SizedBox(height: context.sp(10)),
          ],
        ],
      ),
    );
  }
}
