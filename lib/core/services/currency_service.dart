import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Get the current user's currency code (e.g., 'IQD', 'USD', etc.)
  Future<String?> getCurrency() async {
    try {
      return await _storage.read(key: AppConstants.currencyKey);
    } catch (e) {
      return null;
    }
  }

  /// Get the current user's currency ID
  Future<int?> getCurrencyId() async {
    try {
      final currencyIdString = await _storage.read(key: AppConstants.currencyIdKey);
      if (currencyIdString != null) {
        return int.tryParse(currencyIdString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Set the user's currency
  Future<void> setCurrency(String currency) async {
    await _storage.write(key: AppConstants.currencyKey, value: currency);
  }

  /// Set the user's currency ID
  Future<void> setCurrencyId(int currencyId) async {
    await _storage.write(key: AppConstants.currencyIdKey, value: currencyId.toString());
  }

  /// Clear currency data (used during logout)
  Future<void> clearCurrency() async {
    await _storage.delete(key: AppConstants.currencyKey);
    await _storage.delete(key: AppConstants.currencyIdKey);
  }

  /// Check if currency data is available
  Future<bool> hasCurrency() async {
    final currency = await getCurrency();
    return currency != null && currency.isNotEmpty;
  }

  /// Get currency symbol based on currency code and locale
  String getCurrencySymbol(String currencyCode, {Locale? locale}) {
    final isArabic = locale?.languageCode == 'ar';
    
    switch (currencyCode.toUpperCase()) {
      case 'IQD':
        return isArabic ? 'د.ع' : 'IQD';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'SAR':
        return isArabic ? 'ر.س' : 'SAR';
      case 'AED':
        return isArabic ? 'د.إ' : 'AED';
      case 'KWD':
        return isArabic ? 'د.ك' : 'KWD';
      case 'QAR':
        return isArabic ? 'ر.ق' : 'QAR';
      case 'BHD':
        return isArabic ? 'د.ب' : 'BHD';
      case 'OMR':
        return isArabic ? 'ر.ع' : 'OMR';
      default:
        return currencyCode;
    }
  }

  /// Format price with currency symbol based on locale
  String formatPrice(double price, {String? currencyCode, Locale? locale}) {
    // Format price and remove trailing zeros
    String priceString;
    // Always format to 2 decimal places first, then remove trailing zeros
    // This handles floating point precision issues
    priceString = price.toStringAsFixed(2);
    // Remove trailing zeros and decimal point if not needed (e.g., "56350.00" -> "56350")
    priceString = priceString.replaceAll(RegExp(r'\.0+$'), '');
    
    if (currencyCode != null) {
      final symbol = getCurrencySymbol(currencyCode, locale: locale);
      
      // Check if locale is Arabic or RTL language
      final isRTL = locale?.languageCode == 'ar' || 
                    locale?.languageCode == 'fa' || 
                    locale?.languageCode == 'ur' ||
                    locale?.languageCode == 'he';
      
      if (isRTL) {
        // RTL format: currency price (e.g., "€ 25.99" or "د.ع 100")
        return '$symbol $priceString';
      } else {
        // LTR format: price currency (e.g., "25.99 €" or "100 IQD")
        return '$priceString $symbol';
      }
    }
    return priceString;
  }

  /// Get formatted price using stored currency
  Future<String> getFormattedPrice(double price) async {
    final currency = await getCurrency();
    return formatPrice(price, currencyCode: currency);
  }
}

