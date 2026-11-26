import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormat {
  static String convertToIdr(dynamic number, {int decimalDigit = 0}) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }
}

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Only allow digits
    String cleaned = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final value = double.tryParse(cleaned);
    if (value == null) return oldValue;

    final formatter = NumberFormat.decimalPattern('id');
    final formatted = formatter.format(value.toInt());

    int baseOffset = newValue.selection.baseOffset;
    int digitsBeforeCursor = 0;
    for (int i = 0; i < baseOffset; i++) {
      if (i < newValue.text.length &&
          RegExp(r'[0-9]').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    int newSelectionIndex = 0;
    int digitCount = 0;
    while (newSelectionIndex < formatted.length &&
        digitCount < digitsBeforeCursor) {
      if (RegExp(r'[0-9]').hasMatch(formatted[newSelectionIndex])) {
        digitCount++;
      }
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
