import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import 'currency_text.dart';

/// Example widget showing how to use currency functionality throughout the app
class CurrencyExample extends StatelessWidget {
  const CurrencyExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Currency Usage Examples:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Example 1: Using CurrencyText widget
            const Text('1. Using CurrencyText widget:'),
            const SizedBox(height: 8),
            const CurrencyText(
              price: 99.99,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Example 2: Using CurrencySymbol widget
            const Text('2. Using CurrencySymbol widget:'),
            const SizedBox(height: 8),
            const Row(
              children: [
                CurrencySymbol(style: TextStyle(fontSize: 16)),
                Text(' 99.99', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            
            // Example 3: Using CurrencyProvider directly
            const Text('3. Using CurrencyProvider directly:'),
            const SizedBox(height: 8),
            Consumer<CurrencyProvider>(
              builder: (context, currencyProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Currency: ${currencyProvider.currency ?? 'Not set'}'),
                    Text('Currency ID: ${currencyProvider.currencyId ?? 'Not set'}'),
                    Text('Symbol: ${currencyProvider.getCurrencySymbol()}'),
                    Text('Formatted Price: ${currencyProvider.formatPrice(149.50)}'),
                    Text('Has Currency: ${currencyProvider.hasCurrency}'),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Example 4: Different price examples
            const Text('4. Different price examples:'),
            const SizedBox(height: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CurrencyText(price: 0.99, style: TextStyle(fontSize: 14)),
                CurrencyText(price: 19.99, style: TextStyle(fontSize: 14)),
                CurrencyText(price: 99.99, style: TextStyle(fontSize: 14)),
                CurrencyText(price: 999.99, style: TextStyle(fontSize: 14)),
                CurrencyText(price: 9999.99, style: TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


