import '../../domain/entities/checkout_item.dart';
import '../../domain/entities/checkout_summary.dart';
import '../constants/checkout_constants.dart';

class CheckoutUtils {
  /// Calculate checkout summary based on items
  static CheckoutSummary calculateSummary(List<CheckoutItem> items) {
    final subtotal = items.fold<double>(
      0.0, 
      (sum, item) => sum + (item.cartItem.totalPrice * (item.isSelected ? 1 : 0))
    );
    
    final shipping = subtotal > CheckoutConstants.freeShippingThreshold 
        ? 0.0 
        : CheckoutConstants.shippingCost;
    
    final tax = subtotal * CheckoutConstants.taxRate;
    
    final discount = subtotal > CheckoutConstants.discountThreshold 
        ? subtotal * CheckoutConstants.discountRate 
        : 0.0;
    
    final total = subtotal + shipping + tax - discount;

    // Number of distinct line items (products), not sum of quantities
    final totalItems = items.where((item) => item.isSelected).length;

    return CheckoutSummary(
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      discount: discount,
      total: total,
      totalItems: totalItems,
    );
  }

  /// Format currency for display (deprecated here; prefer CurrencyProvider)
  static String formatCurrency(double amount) {
    // Deprecated hardcoded symbol removed. Use CurrencyProvider in widgets.
    return amount.toStringAsFixed(2);
  }

  /// Get shipping status text
  static String getShippingStatusText(double subtotal) {
    if (subtotal >= CheckoutConstants.freeShippingThreshold) {
      return 'Free Shipping';
    }
    return 'Standard Shipping';
  }

  /// Check if free shipping applies
  static bool isFreeShipping(double subtotal) {
    return subtotal >= CheckoutConstants.freeShippingThreshold;
  }

  /// Check if discount applies
  static bool isDiscountEligible(double subtotal) {
    return subtotal >= CheckoutConstants.discountThreshold;
  }
}
