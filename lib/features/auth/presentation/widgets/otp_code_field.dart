import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// Six-digit code entry used by the account-verification and
/// forgot-password-verify steps. Always laid out left-to-right (digits read
/// the same way regardless of the app's text direction).
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.enabled = true,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<OtpCodeField> createState() => OtpCodeFieldState();
}

class OtpCodeFieldState extends State<OtpCodeField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _notify() => widget.onChanged(_controllers.map((c) => c.text).join());

  /// Clears every cell and returns focus to the first one.
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          widget.length,
          (i) => _OtpCell(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            enabled: widget.enabled,
            onFilled: () {
              _notify();
              if (i < widget.length - 1) {
                _focusNodes[i + 1].requestFocus();
              } else {
                _focusNodes[i].unfocus();
              }
            },
            onEmpty: () {
              _notify();
              if (i > 0) {
                _controllers[i - 1].clear();
                _focusNodes[i - 1].requestFocus();
              }
            },
          ),
        ),
      ),
    );
  }
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onFilled,
    required this.onEmpty,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onFilled;
  final VoidCallback onEmpty;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 58,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontFamily: 'Almarai',
          color: context.appTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _BackspaceOnEmptyFormatter(onEmpty),
        ],
        decoration: InputDecoration(
          counterText: '',
          hintText: '-',
          hintStyle: TextStyle(
            color: context.appTextSecondary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (val) {
          if (val.isNotEmpty) onFilled();
        },
      ),
    );
  }
}

class _BackspaceOnEmptyFormatter extends TextInputFormatter {
  const _BackspaceOnEmptyFormatter(this.onDelete);
  final VoidCallback onDelete;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text.isEmpty && newValue.text.isEmpty) {
      onDelete();
    }
    return newValue;
  }
}
