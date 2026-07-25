import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Dark "photo well" housing the question's sign/media icon — kept a fixed
/// dark shade regardless of app theme so it always reads as an image frame.
class QuestionMediaCard extends StatelessWidget {
  const QuestionMediaCard({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: Container(
        decoration: BoxDecoration(
          color: AppColorsDark.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColorsDark.glassBorder),
        ),
        child: Center(
          child: Icon(icon, size: context.sp(72), color: AppColorsDark.primary),
        ),
      ),
    );
  }
}
