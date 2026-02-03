import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/checkout_item.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/shipping_address.dart';
import '../../domain/entities/payment_method.dart';

abstract class CheckoutLocalDataSource {
  Future<List<CheckoutItem>> getCheckoutItems();
  Future<CheckoutSummary> getCheckoutSummary();
  Future<List<ShippingAddress>> getShippingAddresses();
  Future<List<PaymentMethod>> getPaymentMethods();
  Future<void> updateCheckoutItem(String itemId, bool isSelected);
  Future<void> removeCheckoutItem(String itemId);
  Future<void> addShippingAddress(ShippingAddress address);
  Future<void> updateShippingAddress(ShippingAddress address);
  Future<void> removeShippingAddress(String addressId);
  Future<void> addPaymentMethod(PaymentMethod method);
  Future<void> updatePaymentMethod(PaymentMethod method);
  Future<void> removePaymentMethod(String methodId);
}

class CheckoutLocalDataSourceImpl implements CheckoutLocalDataSource {
  final SharedPreferences sharedPreferences;

  CheckoutLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<CheckoutItem>> getCheckoutItems() async {
    // Return empty list - checkout items are initialized from cart items
    return [];
  }

  @override
  Future<CheckoutSummary> getCheckoutSummary() async {
    // Return empty summary - summary is calculated from cart items
    return const CheckoutSummary(
      subtotal: 0.0,
      shipping: 0.0,
      tax: 0.0,
      discount: 0.0,
      total: 0.0,
      totalItems: 0,
    );
  }

  @override
  Future<List<ShippingAddress>> getShippingAddresses() async {
    // For demo purposes, return sample addresses
    return [
      const ShippingAddress(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        streetAddress: '123 Main St',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        country: 'USA',
        phone: '+1-555-0123',
        isDefault: true,
      ),
      const ShippingAddress(
        id: '2',
        firstName: 'Jane',
        lastName: 'Smith',
        streetAddress: '456 Oak Ave',
        city: 'Los Angeles',
        state: 'CA',
        zipCode: '90210',
        country: 'USA',
        phone: '+1-555-0456',
        isDefault: false,
      ),
    ];
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods() async {
    // For demo purposes, return sample payment methods
    return [
      const PaymentMethod(
        id: '1',
        type: PaymentType.creditCard,
        name: 'Visa ending in 1234',
        lastFourDigits: '1234',
        cardBrand: 'Visa',
        isDefault: true,
      ),
      const PaymentMethod(
        id: '2',
        type: PaymentType.paypal,
        name: 'PayPal',
        lastFourDigits: null,
        cardBrand: null,
        isDefault: false,
      ),
      const PaymentMethod(
        id: '3',
        type: PaymentType.applePay,
        name: 'Apple Pay',
        lastFourDigits: null,
        cardBrand: null,
        isDefault: false,
      ),
      const PaymentMethod(
        id: '4',
        type: PaymentType.alQaseh,
        name: 'Al Qaseh',
        lastFourDigits: null,
        cardBrand: null,
        isDefault: false,
      ),
    ];
  }

  @override
  Future<void> updateCheckoutItem(String itemId, bool isSelected) async {
    // Implementation for updating checkout item
  }

  @override
  Future<void> removeCheckoutItem(String itemId) async {
    // Implementation for removing checkout item
  }

  @override
  Future<void> addShippingAddress(ShippingAddress address) async {
    // Implementation for adding shipping address
  }

  @override
  Future<void> updateShippingAddress(ShippingAddress address) async {
    // Implementation for updating shipping address
  }

  @override
  Future<void> removeShippingAddress(String addressId) async {
    // Implementation for removing shipping address
  }

  @override
  Future<void> addPaymentMethod(PaymentMethod method) async {
    // Implementation for adding payment method
  }

  @override
  Future<void> updatePaymentMethod(PaymentMethod method) async {
    // Implementation for updating payment method
  }

  @override
  Future<void> removePaymentMethod(String methodId) async {
    // Implementation for removing payment method
  }
}
