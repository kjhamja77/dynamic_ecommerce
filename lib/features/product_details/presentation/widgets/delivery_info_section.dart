import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';

class DeliveryInfoSection extends StatelessWidget {
  final bool isFreeDeliveryEligible;
  final String estimatedDelivery;
  final double orderTotal;

  const DeliveryInfoSection({
    super.key,
    this.isFreeDeliveryEligible = true,
    this.estimatedDelivery = 'Tomorrow',
    this.orderTotal = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: Colors.green.shade700,
                  size: ResponsiveConstants.mdIconSize,
                ),
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFreeDeliveryEligible ? AppLocalizations.of(context)!.freeDelivery : AppLocalizations.of(context)!.fastDelivery,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      'Estimated: $estimatedDelivery',
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (!isFreeDeliveryEligible) ...[
            SizedBox(height: ResponsiveConstants.smSpacing),
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.smPadding),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade600,
                    size: ResponsiveConstants.smIconSize,
                  ),
                  SizedBox(width: ResponsiveConstants.xsSpacing),
                  Expanded(
                    child: Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, child) {
                        final remainingAmount = 29.90 - orderTotal;
                        return Text(
                          'Add ${currencyProvider.formatPrice(remainingAmount, locale: Localizations.localeOf(context))} more for FREE delivery',
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: ResponsiveConstants.mdSpacing),
          
          // Delivery options
          _deliveryOption(
            icon: Icons.schedule,
            title: AppLocalizations.of(context)!.standardDelivery,
            subtitle: '2-4 business days',
            price: isFreeDeliveryEligible ? AppLocalizations.of(context)!.free : 2.90,
            isRecommended: true,
            context: context,
          ),
          
          _deliveryOption(
            icon: Icons.flash_on,
            title: AppLocalizations.of(context)!.expressDelivery,
            subtitle: 'Same day (order before 3 PM)',
            price: 4.90,
            isRecommended: false,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _deliveryOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required dynamic price, // Can be String (for "Free") or double
    required bool isRecommended,
    required BuildContext context,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      padding: EdgeInsets.all(ResponsiveConstants.smPadding),
      decoration: BoxDecoration(
        color: isRecommended ? Colors.green.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        border: Border.all(
          color: isRecommended ? Colors.green.shade300 : Colors.grey.shade300,
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isRecommended ? Colors.green.shade700 : Colors.grey.shade600,
            size: ResponsiveConstants.smIconSize,
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (isRecommended) ...[
                      SizedBox(width: ResponsiveConstants.xsSpacing),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveConstants.xsPadding,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.recommended,
                          style: AppFonts.getTextStyle(fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Consumer<CurrencyProvider>(
            builder: (context, currencyProvider, child) {
              final priceText = price is String ? price : currencyProvider.formatPrice(price as double, locale: Localizations.localeOf(context));
              return Text(
                priceText,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                  fontWeight: FontWeight.w600,
                  color: price == AppLocalizations.of(context)!.free ? Colors.green.shade700 : Colors.black,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
