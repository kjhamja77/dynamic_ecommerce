import '../../domain/entities/shipping_address.dart';
import '../../domain/entities/payment_method.dart';

class CheckoutDemoData {
  /// Demo shipping addresses
  static List<ShippingAddress> get shippingAddresses => [
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
    const ShippingAddress(
      id: '3',
      firstName: 'Mike',
      lastName: 'Johnson',
      streetAddress: '789 Pine Rd',
      city: 'Chicago',
      state: 'IL',
      zipCode: '60601',
      country: 'USA',
      phone: '+1-555-0789',
      isDefault: false,
    ),
  ];

  /// Demo payment methods
  static List<PaymentMethod> get paymentMethods => [
    const PaymentMethod(
      id: '1',
      type: PaymentType.creditCard,
      name: 'John Doe',
      lastFourDigits: '4242',
      cardBrand: 'Visa',
      isDefault: true,
    ),
    const PaymentMethod(
      id: '2',
      type: PaymentType.creditCard,
      name: 'John Doe',
      lastFourDigits: '5555',
      cardBrand: 'Mastercard',
      isDefault: false,
    ),
    const PaymentMethod(
      id: '3',
      type: PaymentType.paypal,
      name: 'john.doe@email.com',
      isDefault: false,
    ),
  ];

  /// Get default shipping address
  static ShippingAddress? get defaultShippingAddress {
    try {
      return shippingAddresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return shippingAddresses.isNotEmpty ? shippingAddresses.first : null;
    }
  }

  /// Get default payment method
  static PaymentMethod? get defaultPaymentMethod {
    try {
      return paymentMethods.firstWhere((method) => method.isDefault);
    } catch (e) {
      return paymentMethods.isNotEmpty ? paymentMethods.first : null;
    }
  }
}
