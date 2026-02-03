import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';

class CurrencyText extends StatelessWidget {
  final double price;
  final TextStyle? style;
  final String? fallbackText;

  const CurrencyText({
    super.key,
    required this.price,
    this.style,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        if (currencyProvider.isLoading) {
          return Text(
            fallbackText ?? '...',
            style: style,
          );
        }

        if (!currencyProvider.hasCurrency) {
          return Text(
            fallbackText ?? price.toStringAsFixed(2),
            style: style,
          );
        }

        return Text(
          currencyProvider.formatPrice(price),
          style: style,
        );
      },
    );
  }
}

class CurrencySymbol extends StatelessWidget {
  final TextStyle? style;

  const CurrencySymbol({
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        if (currencyProvider.isLoading || !currencyProvider.hasCurrency) {
          return Text('', style: style);
        }

        return Text(
          currencyProvider.getCurrencySymbol(locale: Localizations.localeOf(context)),
          style: style,
        );
      },
    );
  }
}


