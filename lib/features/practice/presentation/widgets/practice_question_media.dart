import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Prominent image well shown above the question text when the question is
/// image-based (`question_type == "image"`).
class PracticeQuestionMedia extends StatelessWidget {
  const PracticeQuestionMedia({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColorsDark.background,
            border: Border.all(color: AppColorsDark.glassBorder),
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: AppColorsDark.primary,
                  strokeWidth: 2,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: context.sp(48),
                color: AppColorsDark.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
