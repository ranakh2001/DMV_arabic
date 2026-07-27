import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/utils/validators.dart';

/// Card entry fields shown when the card payment method is selected.
/// Purely local, mock input — nothing here is sent anywhere.
class CardDetailsForm extends StatelessWidget {
  const CardDetailsForm({
    super.key,
    required this.holderController,
    required this.numberController,
    required this.expiryController,
    required this.cvvController,
  });

  final TextEditingController holderController;
  final TextEditingController numberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: holderController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: context.t('payment.card.holder_name')),
          validator: Validators.cardHolderName(context),
        ),
        SizedBox(height: context.sp(16)),
        TextFormField(
          controller: numberController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CardNumberFormatter()],
          decoration: InputDecoration(labelText: context.t('payment.card.number'), hintText: '0000 0000 0000 0000'),
          validator: Validators.cardNumber(context),
        ),
        SizedBox(height: context.sp(16)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: expiryController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, _ExpiryDateFormatter()],
                decoration: InputDecoration(labelText: context.t('payment.card.expiry'), hintText: 'MM/YY'),
                validator: Validators.cardExpiry(context),
              ),
            ),
            SizedBox(width: context.sp(14)),
            Expanded(
              child: TextFormField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                obscureText: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                decoration: InputDecoration(labelText: context.t('payment.card.cvv'), hintText: '•••'),
                validator: Validators.cardCvv(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Inserts a space every 4 digits: `4111 1111 1111 1111`.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.substring(0, newValue.text.length.clamp(0, 16));
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Inserts a slash after the month: `MM/YY`.
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.substring(0, newValue.text.length.clamp(0, 4));
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
