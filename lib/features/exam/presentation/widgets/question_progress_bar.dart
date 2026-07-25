import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Horizontally scrollable dot trail showing answered/unanswered questions,
/// with the current question rendered as a numbered bubble that stays in
/// view, plus a "current/total" label.
class QuestionProgressBar extends StatefulWidget {
  const QuestionProgressBar({
    super.key,
    required this.total,
    required this.currentIndex,
    required this.answeredIndexes,
  });

  final int total;
  final int currentIndex;
  final Set<int> answeredIndexes;

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
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: context.sp(28),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < widget.total; i++) ...[
                    _Dot(active: i == widget.currentIndex, answered: widget.answeredIndexes.contains(i), number: i + 1),
                    if (i != widget.total - 1) SizedBox(width: context.sp(6)),
                  ],
                ],
              ),
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
  const _Dot({required this.active, required this.answered, required this.number});

  final bool active;
  final bool answered;
  final int number;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        width: context.sp(26),
        height: context.sp(26),
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: context.appPrimary),
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
    return Container(
      width: context.sp(8),
      height: context.sp(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: answered ? context.appSuccess : context.appTextDisabled.withAlpha(90),
      ),
    );
  }
}
