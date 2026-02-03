import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';

class DealsAndOffersSection extends StatelessWidget {
  final bool hasActiveDiscount;
  final double discountPercentage;
  final DateTime? dealEndTime;

  const DealsAndOffersSection({
    super.key,
    this.hasActiveDiscount = false,
    this.discountPercentage = 0.0,
    this.dealEndTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with deal icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveConstants.smPadding),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: ResponsiveConstants.mdIconSize,
                ),
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasActiveDiscount ? AppLocalizations.of(context)!.limitedTimeDeal : AppLocalizations.of(context)!.specialOffers,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade700,
                      ),
                    ),
                    if (hasActiveDiscount)
                      Text(
                        'Save ${discountPercentage.toInt()}% on this item',
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          color: Colors.red.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.mdSpacing),
          
          // Deal countdown (if applicable)
          if (dealEndTime != null) ...[
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.smPadding),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: ResponsiveConstants.smIconSize,
                  ),
                  SizedBox(width: ResponsiveConstants.xsSpacing),
                  Text(
                    'Ends in 23h 45m',
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),
          ],
          
          // Available offers
          _offerItem(
            icon: Icons.card_giftcard,
            title: 'Buy 2 Get 1 Free',
            subtitle: AppLocalizations.of(context)!.onSelectedItems,
            badge: AppLocalizations.of(context)!.popular,
            badgeColor: Colors.purple,
          ),
          
          _offerItem(
            icon: Icons.loyalty,
            title: 'Earn 2x Points',
            subtitle: AppLocalizations.of(context)!.doubleRewardsOnThisPurchase,
            badge: AppLocalizations.of(context)!.bonus,
            badgeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _offerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      padding: EdgeInsets.all(ResponsiveConstants.smPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
            ),
            child: Icon(
              icon,
              color: badgeColor,
              size: ResponsiveConstants.smIconSize,
            ),
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
                    SizedBox(width: ResponsiveConstants.xsSpacing),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveConstants.xsPadding,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                      ),
                      child: Text(
                        badge,
                        style: AppFonts.getTextStyle(fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
            size: ResponsiveConstants.smIconSize,
          ),
        ],
      ),
    );
  }


}
