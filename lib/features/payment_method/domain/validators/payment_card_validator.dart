import '../../domain/entities/payment_method.dart';

class PaymentCardValidator {
  const PaymentCardValidator();

  bool isValidCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(' ', '');
    if (digits.length < 13 || digits.length > 19) return false;
    return _luhnCheck(digits);
  }

  bool _luhnCheck(String digits) {
    int sum = 0;
    bool alternate = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.tryParse(digits[i]) ?? 0;
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  bool isValidExpiry(String mmYY) {
    if (mmYY.length != 5 && mmYY.length != 4) return false; // supports 1225 or 12/25
    String monthStr;
    String yearStr;
    if (mmYY.contains('/')) {
      final parts = mmYY.split('/');
      if (parts.length != 2) return false;
      monthStr = parts[0];
      yearStr = parts[1];
    } else {
      monthStr = mmYY.substring(0, 2);
      yearStr = mmYY.substring(2);
    }
    final month = int.tryParse(monthStr) ?? -1;
    final year = int.tryParse(yearStr) ?? -1;
    if (month < 1 || month > 12) return false;
    // Normalize to 2000-based year for 2-digit input
    final fullYear = year + (year < 100 ? 2000 : 0);
    final now = DateTime.now();
    // Expire at end of month
    final lastDay = DateTime(fullYear, month + 1, 0);
    return lastDay.isAfter(DateTime(now.year, now.month, now.day - 1));
  }

  bool isValidCvv(String cvv, PaymentMethodType type) {
    final digits = cvv.replaceAll(' ', '');
    if (digits.isEmpty) return false;
    // Amex often 4, others 3
    if (type == PaymentMethodType.creditCard) {
      return digits.length == 3 || digits.length == 4;
    }
    return digits.length >= 3 && digits.length <= 4;
  }
}
