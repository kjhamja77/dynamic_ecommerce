import 'package:flutter/services.dart';

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow clearing
    if (newValue.text.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }

    // Compute how many digits are before the cursor in the new value
    final String newText = newValue.text;
    final int rawCursorIndex = newValue.selection.baseOffset;
    final int digitsBeforeCursor = _countDigits(newText.substring(0, rawCursorIndex));

    // Build the grouped text (4-4-4-4)
    final String digitsOnly = newText.replaceAll(RegExp(r'\D'), '');
    final String formatted = _groupEveryFour(digitsOnly);

    // Place the cursor after the same number of digits in the formatted string
    final int newCursorIndex = _indexAfterDigits(formatted, digitsBeforeCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorIndex),
    );
  }

  String _groupEveryFour(String digits) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  int _countDigits(String s) {
    return s.replaceAll(RegExp(r'\D'), '').length;
  }

  int _indexAfterDigits(String formatted, int digitsCount) {
    if (digitsCount <= 0) return 0;
    int seen = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (_isDigit(formatted.codeUnitAt(i))) {
        seen++;
        if (seen == digitsCount) {
          return i + 1; // cursor after this digit
        }
      }
    }
    return formatted.length;
  }

  bool _isDigit(int charCode) {
    return charCode >= 48 && charCode <= 57;
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow clearing
    if (newValue.text.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }

    final String newText = newValue.text;
    final int rawCursorIndex = newValue.selection.baseOffset;
    final String digitsOnly = newText.replaceAll(RegExp(r'\D'), '');

    // Limit to MMYY (4 digits)
    final String limited = digitsOnly.length > 4 ? digitsOnly.substring(0, 4) : digitsOnly;

    // Compute digits before cursor
    final int digitsBeforeCursor = _countDigits(newText.substring(0, rawCursorIndex));

    // Insert '/'
    final String formatted = _insertSlash(limited);

    // Place cursor after the same number of digits
    final int newCursorIndex = _indexAfterDigits(formatted, digitsBeforeCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorIndex),
    );
  }

  int _countDigits(String s) => s.replaceAll(RegExp(r'\D'), '').length;

  String _insertSlash(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length <= 2) return digits; // still typing month
    return '${digits.substring(0, 2)}/${digits.substring(2)}';
  }

  int _indexAfterDigits(String formatted, int digitsCount) {
    if (digitsCount <= 0) return 0;
    int seen = 0;
    for (int i = 0; i < formatted.length; i++) {
      final int code = formatted.codeUnitAt(i);
      final bool isDigit = code >= 48 && code <= 57;
      if (isDigit) {
        seen++;
        if (seen == digitsCount) return i + 1;
      }
    }
    return formatted.length;
  }
}
