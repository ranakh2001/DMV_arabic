import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import '../../domain/entities/exam_result_detail.dart';

/// Score summary + per-question review for one graded attempt. Shared by
/// the post-submit [ExamResultScreen] and the history result bottom sheet
/// so both render an attempt's `GET .../results` payload identically.
class ExamResultContent extends StatelessWidget {
  const ExamResultContent({super.key, required this.result});

  final ExamResultDetail result;

  @override
  Widget build(BuildContext context) {
    final statusColor = result.passed ? context.appSuccess : context.appError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassContainer(
          radius: 20,
          child: Column(
            children: [
              Container(
                width: context.sp(64),
                height: context.sp(64),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withAlpha(36),
                ),
                child: Icon(
                  result.passed
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: statusColor,
                  size: context.sp(34),
                ),
              ),
              SizedBox(height: context.sp(12)),
              Text(
                context.t(
                  result.passed ? 'exam.result.passed' : 'exam.result.failed',
                ),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(18),
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
              SizedBox(height: context.sp(4)),
              Text(
                result.exam.titleAr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(13),
                  color: context.appTextSecondary,
                ),
              ),
              SizedBox(height: context.sp(18)),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.percent_rounded,
                      label: context.t('exam.result.score_label'),
                      value: '${result.score}%',
                      color: context.appPrimary,
                    ),
                  ),
                  SizedBox(width: context.sp(10)),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.check_rounded,
                      label: context.t('exam.result.correct_label'),
                      value: '${result.correctAnswers}',
                      color: context.appSuccess,
                    ),
                  ),
                  SizedBox(width: context.sp(10)),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.close_rounded,
                      label: context.t('exam.result.incorrect_label'),
                      value: '${result.incorrectAnswers}',
                      color: context.appError,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.sp(14)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: context.sp(15),
                    color: context.appTextSecondary,
                  ),
                  SizedBox(width: context.sp(6)),
                  Text(
                    context.ts('exam.result.time_label_value', {
                      'time': result.timeTaken,
                    }),
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(12),
                      color: context.appTextSecondary,
                    ),
                  ),
                  SizedBox(width: context.sp(14)),
                  Icon(
                    Icons.flag_rounded,
                    size: context.sp(15),
                    color: context.appTextSecondary,
                  ),
                  SizedBox(width: context.sp(6)),
                  Text(
                    context.ts('simulation.min_pass_value', {
                      'count': '${result.exam.passingScore}',
                    }),
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(12),
                      color: context.appTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (result.answers.isNotEmpty) ...[
          SizedBox(height: context.sp(20)),
          Text(
            context.t('exam.result.review_title'),
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(15),
              fontWeight: FontWeight.w700,
              color: context.appTextPrimary,
            ),
          ),
          SizedBox(height: context.sp(12)),
          for (var i = 0; i < result.answers.length; i++) ...[
            _AnswerReviewCard(index: i + 1, answer: result.answers[i]),
            if (i != result.answers.length - 1)
              SizedBox(height: context.sp(10)),
          ],
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: context.sp(10)),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: context.sp(18)),
          SizedBox(height: context.sp(6)),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(15),
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: context.sp(2)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(10.5),
              color: context.appTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerReviewCard extends StatelessWidget {
  const _AnswerReviewCard({required this.index, required this.answer});

  final int index;
  final ExamResultAnswer answer;

  @override
  Widget build(BuildContext context) {
    final statusColor = answer.isCorrect
        ? context.appSuccess
        : context.appError;

    return Container(
      padding: EdgeInsets.all(context.sp(14)),
      decoration: BoxDecoration(
        color: context.appGlassTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withAlpha(90)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: context.sp(24),
                height: context.sp(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withAlpha(36),
                ),
                child: Icon(
                  answer.isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  color: statusColor,
                  size: context.sp(15),
                ),
              ),
              SizedBox(width: context.sp(10)),
              Expanded(
                child: Text(
                  '$index. ${answer.questionTextAr}',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(13.5),
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          if (answer.imageFullUrl != null) ...[
            SizedBox(height: context.sp(10)),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1.8,
                child: Image.network(
                  answer.imageFullUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ],
          SizedBox(height: context.sp(10)),
          Wrap(
            spacing: context.sp(8),
            runSpacing: context.sp(8),
            children: [
              _AnswerChip(
                label: context.t('exam.result.your_answer'),
                value:
                    answer.selectedAnswer?.toUpperCase() ??
                    context.t('exam.result.no_answer'),
                color: statusColor,
              ),
              if (!answer.isCorrect)
                _AnswerChip(
                  label: context.t('exam.result.correct_answer'),
                  value: answer.correctAnswer.toUpperCase(),
                  color: context.appSuccess,
                ),
            ],
          ),
          if (answer.explanationAr.isNotEmpty) ...[
            SizedBox(height: context.sp(10)),
            Text(
              answer.explanationAr,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(12.5),
                color: context.appTextSecondary,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  const _AnswerChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(10),
        vertical: context.sp(6),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: context.sp(11.5),
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
