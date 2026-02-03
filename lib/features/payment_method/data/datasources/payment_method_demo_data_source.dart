import '../models/payment_method_model.dart';
import '../../domain/entities/payment_method.dart';

class PaymentMethodDemoDataSource {
  static List<PaymentMethodModel> getDemoPaymentMethods() {
    return [
      // Cash payment method
      PaymentMethodModel(
        id: 'cash_001',
        name: 'Cash',
        cardNumber: null,
        expiryDate: null,
        cardHolderName: null,
        cvvCode: null,
        type: PaymentMethodType.cash,
        isDefault: true,
        createdAt: DateTime.now(),
        lastUsed: null,
      ),
      
      // Zain Cash payment method
      PaymentMethodModel(
        id: 'zain_cash_001',
        name: 'Zain Cash',
        cardNumber: null,
        expiryDate: null,
        cardHolderName: null,
        cvvCode: null,
        type: PaymentMethodType.zainCash,
        isDefault: false,
        createdAt: DateTime.now(),
        lastUsed: null,
      ),
      
      // Al Qaseh payment method
      PaymentMethodModel(
        id: 'al_qaseh_001',
        name: 'Al Qaseh',
        cardNumber: null,
        expiryDate: null,
        cardHolderName: null,
        cvvCode: null,
        type: PaymentMethodType.alQaseh,
        isDefault: false,
        createdAt: DateTime.now(),
        lastUsed: null,
      ),
      
      // Qi Card payment method
      PaymentMethodModel(
        id: 'qi_card_001',
        name: 'Qi Card',
        cardNumber: null,
        expiryDate: null,
        cardHolderName: null,
        cvvCode: null,
        type: PaymentMethodType.qiCard,
        isDefault: false,
        createdAt: DateTime.now(),
        lastUsed: null,
      ),
      
      // Credit Card example (for reference)
      PaymentMethodModel(
        id: 'credit_card_001',
        name: 'Visa Card',
        cardNumber: '4111111111111111',
        expiryDate: '12/25',
        cardHolderName: 'John Doe',
        cvvCode: '123',
        type: PaymentMethodType.creditCard,
        isDefault: false,
        createdAt: DateTime.now(),
        lastUsed: null,
      ),
    ];
  }
}
