import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_method_model.dart';

abstract class PaymentMethodLocalDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel paymentMethod);
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethodModel paymentMethod);
  Future<bool> deletePaymentMethod(String id);
  Future<PaymentMethodModel> setDefaultPaymentMethod(String id);
}

class PaymentMethodLocalDataSourceImpl implements PaymentMethodLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _paymentMethodsKey = 'payment_methods';

  PaymentMethodLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final jsonString = sharedPreferences.getString(_paymentMethodsKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final methods = jsonList
            .map((json) => PaymentMethodModel.fromJson(json))
            .toList();
        
        // Filter out demo payment methods
        final demoIds = ['cash_001', 'zain_cash_001', 'al_qaseh_001', 'qi_card_001', 'credit_card_001'];
        final filteredMethods = methods.where((method) => !demoIds.contains(method.id)).toList();
        
        // If demo methods were removed, save the filtered list
        if (filteredMethods.length != methods.length) {
          await _savePaymentMethods(filteredMethods);
        }
        
        return filteredMethods;
      }
      
      // Return empty list if no payment methods exist
      return [];
    } catch (e) {
      // If there's an error, return empty list to prevent crashes
      // Log error for debugging purposes
      return [];
    }
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel paymentMethod) async {
    final methods = await getPaymentMethods();
    
    // If this is the first payment method, make it default
    if (methods.isEmpty) {
      final newMethod = PaymentMethodModel.fromEntity(paymentMethod.copyWith(isDefault: true));
      methods.add(newMethod);
    } else {
      methods.add(paymentMethod);
    }
    
    await _savePaymentMethods(methods);
    return paymentMethod;
  }

  @override
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethodModel paymentMethod) async {
    final methods = await getPaymentMethods();
    final index = methods.indexWhere((method) => method.id == paymentMethod.id);
    
    if (index != -1) {
      methods[index] = paymentMethod;
      await _savePaymentMethods(methods);
    }
    
    return paymentMethod;
  }

  @override
  Future<bool> deletePaymentMethod(String id) async {
    final methods = await getPaymentMethods();
    final wasDefault = methods.any((method) => method.id == id && method.isDefault);
    
    methods.removeWhere((method) => method.id == id);
    
    // If we deleted the default method and there are other methods, set the first one as default
    if (wasDefault && methods.isNotEmpty) {
      methods[0] = PaymentMethodModel.fromEntity(methods[0].copyWith(isDefault: true));
    }
    
    await _savePaymentMethods(methods);
    return true;
  }

  @override
  Future<PaymentMethodModel> setDefaultPaymentMethod(String id) async {
    final methods = await getPaymentMethods();
    
    // Remove default from all methods
    for (int i = 0; i < methods.length; i++) {
      methods[i] = PaymentMethodModel.fromEntity(methods[i].copyWith(isDefault: false));
    }
    
    // Set the specified method as default
    final index = methods.indexWhere((method) => method.id == id);
    if (index != -1) {
      methods[index] = PaymentMethodModel.fromEntity(methods[index].copyWith(isDefault: true));
      await _savePaymentMethods(methods);
      return methods[index];
    }
    
    throw Exception('Payment method not found');
  }

  Future<void> _savePaymentMethods(List<PaymentMethodModel> methods) async {
    final jsonList = methods.map((method) => method.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await sharedPreferences.setString(_paymentMethodsKey, jsonString);
  }
}
