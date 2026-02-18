import 'package:flutter/material.dart';
import '../services/currency_service.dart';
import '../services/app_localization_service.dart';

class CurrencyProvider extends ChangeNotifier {
  final CurrencyService _currencyService = CurrencyService();
  
  String? _currency;
  int? _currencyId;
  bool _isLoading = false;

  String? get currency => _currency;
  int? get currencyId => _currencyId;
  bool get isLoading => _isLoading;

  /// Initialize currency data from storage
  Future<void> initializeCurrency() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currency = await _currencyService.getCurrency();
      _currencyId = await _currencyService.getCurrencyId();
      
      // Set default currency if none exists
      if (_currency == null || _currency!.isEmpty) {
        await updateCurrency('IQD', 1); // Default to Iraqi Dinar
        debugPrint('💰 CurrencyProvider: Set default currency to IQD');
      } else {
        debugPrint('💰 CurrencyProvider: Loaded currency: $_currency');
      }
    } catch (e) {
      debugPrint('Error initializing currency: $e');
      // Set default currency on error
      _currency = 'IQD';
      _currencyId = 1;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update currency data
  Future<void> updateCurrency(String currency, int currencyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _currencyService.setCurrency(currency);
      await _currencyService.setCurrencyId(currencyId);
      
      _currency = currency;
      _currencyId = currencyId;
    } catch (e) {
      debugPrint('Error updating currency: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear currency data
  Future<void> clearCurrency() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _currencyService.clearCurrency();
      _currency = null;
      _currencyId = null;
    } catch (e) {
      debugPrint('Error clearing currency: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get currency symbol
  String getCurrencySymbol({Locale? locale}) {
    if (_currency == null) return '';
    // If no locale provided, use current app locale
    final effectiveLocale = locale ?? AppLocalizationService().currentLocale;
    return _currencyService.getCurrencySymbol(_currency!, locale: effectiveLocale);
  }

  /// Format price with current currency
  ///
  /// When [roundToInteger] is true, the value will be rounded to the
  /// nearest whole unit and displayed without any fractional part.
  /// This is useful for UI elements like filter sliders where clean,
  /// whole-number ranges are preferred.
  String formatPrice(
    double price, {
    Locale? locale,
    bool roundToInteger = false,
  }) {
    // Use default currency if none is set
    final currencyCode = _currency ?? 'IQD'; // Default to Iraqi Dinar
    
    // If no locale provided, use current app locale
    final effectiveLocale = locale ?? AppLocalizationService().currentLocale;
    
    return _currencyService.formatPrice(
      price,
      currencyCode: currencyCode,
      locale: effectiveLocale,
      roundToInteger: roundToInteger,
    );
  }

  /// Check if currency is available
  bool get hasCurrency => _currency != null && _currency!.isNotEmpty;
}

