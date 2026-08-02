import 'package:flutter/widgets.dart';

/// One answer choice. Content may be text, an icon standing in for an
/// image-based answer (e.g. a traffic sign), or both.
class AnswerOption {
  const AnswerOption({required this.id, this.textEn, this.textAr, this.icon})
    : assert(
        textEn != null || icon != null,
        'An option needs text and/or an icon.',
      );

  final String id;
  final String? textEn;
  final String? textAr;
  final IconData? icon;

  String label(bool isAr) =>
      (isAr ? (textAr ?? textEn) : (textEn ?? textAr)) ?? '';
}
