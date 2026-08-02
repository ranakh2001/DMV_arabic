import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';

/// Shared "edit a single text field" dialog used by every editable row on
/// the profile screen (name, email, phone). Returns the new value, or null
/// if the user cancelled/left it unchanged.
Future<String?> showEditFieldDialog(
  BuildContext context, {
  required String label,
  required String initialValue,
  FormFieldValidator<String>? validator,
  TextInputType? keyboardType,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _EditFieldDialog(
      label: label,
      initialValue: initialValue,
      validator: validator,
      keyboardType: keyboardType,
    ),
  );
}

class _EditFieldDialog extends StatefulWidget {
  const _EditFieldDialog({
    required this.label,
    required this.initialValue,
    required this.validator,
    required this.keyboardType,
  });

  final String label;
  final String initialValue;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;

  @override
  State<_EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<_EditFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        context.ts('profile.edit_field_title', {'field': widget.label}),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          decoration: InputDecoration(labelText: widget.label),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t('common.cancel')),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.of(context).pop(_controller.text.trim());
          },
          child: Text(context.t('common.save')),
        ),
      ],
    );
  }
}
