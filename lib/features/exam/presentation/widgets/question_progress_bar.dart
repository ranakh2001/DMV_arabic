import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

const _activeDotSize = 26.0;
const _inactiveDotSize = 8.0;
const _dotGap = 6.0;

/// Horizontally scrollable dot trail showing answered/unanswered questions,
/// with the current question rendered as a numbered bubble that stays in
/// view, plus a "current/total" label.
class QuestionProgressBar extends StatefulWidget {
  const QuestionProgressBar({
    super.key,
    required this.total,
    required this.currentIndex,
    required this.answeredIndexes,
    this.correctness = const {},
  });

  final int total;
  final int currentIndex;
  final Set<int> answeredIndexes;

  /// Per-question-index correctness, for flows that grade each answer as
  /// it's picked. An index missing here (but present in [answeredIndexes])
  /// falls back to the plain "answered" green — flows with no live grading
  /// (correctness only known after submit) can simply omit this.
  final Map<int, bool> correctness;

  @override
  State<QuestionProgressBar> createState() => _QuestionProgressBarState();
}

class _QuestionProgressBarState extends State<QuestionProgressBar> {
  final _scrollController = ScrollController();
  static const _dotExtent = 16.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
  }

  @override
  void didUpdateWidget(covariant QuestionProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) _scrollToCurrent();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrent() {
    if (!_scrollController.hasClients) return;
    final dotExtent = context.sp(_dotExtent);
    final target = (widget.currentIndex * dotExtent) - context.sp(90);
    _scrollController.animateTo(
      target.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dotsRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.total; i++) ...[
          _Dot(
            active: i == widget.currentIndex,
            answered: widget.answeredIndexes.contains(i),
            isCorrect: widget.correctness[i],
            number: i + 1,
          ),
          if (i != widget.total - 1) SizedBox(width: context.sp(_dotGap)),
        ],
      ],
    );

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: context.sp(28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Exactly one dot is active (larger) at a time; the rest
                // are the smaller inactive size, joined by gaps. Mirrors
                // `_Dot`'s actual rendered sizes so this never
                // underestimates the row's real width (which would let it
                // overflow the Center branch below).
                final contentWidth =
                    context.sp(_activeDotSize) +
                    (widget.total - 1) *
                        (context.sp(_inactiveDotSize) + context.sp(_dotGap));
                if (contentWidth <= constraints.maxWidth) {
                  return Center(child: dotsRow);
                }
                return SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: dotsRow,
                );
              },
            ),
          ),
        ),
        SizedBox(width: context.sp(10)),
        Text(
          '${widget.currentIndex + 1} / ${widget.total}',
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(13),
            fontWeight: FontWeight.w700,
            color: context.appTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.active,
    required this.answered,
    this.isCorrect,
    required this.number,
  });

  final bool active;
  final bool answered;

  /// Null when correctness isn't tracked for this flow, or the question
  /// hasn't been graded yet.
  final bool? isCorrect;
  final int number;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        width: context.sp(_activeDotSize),
        height: context.sp(_activeDotSize),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.appPrimary,
        ),
        child: Text(
          '$number',
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(11),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
    }
    final Color color;
    if (!answered) {
      color = context.appTextDisabled.withAlpha(90);
    } else if (isCorrect == null) {
      color = context.appSuccess;
    } else {
      color = isCorrect! ? context.appSuccess : context.appError;
    }
    return Container(
      width: context.sp(_inactiveDotSize),
      height: context.sp(_inactiveDotSize),
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
