import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class StyleRecommendationsSection extends StatelessWidget {
  final String productCategory;

  const StyleRecommendationsSection({
    super.key,
    this.productCategory = 'clothing',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Text(
            AppLocalizations.of(context)!.styleItWith,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.lgFontSize,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          
          SizedBox(height: ResponsiveConstants.smSpacing),
          
          Text(
            AppLocalizations.of(context)!.completeYourLookWithTheseComplementaryPieces,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Style suggestions
          Column(
            children: [
              _styleCard(
                AppLocalizations.of(context)!.accessories,
                AppLocalizations.of(context)!.addATouchOfElegance,
                [
                  _StyleItem(AppLocalizations.of(context)!.classicWatch, 149.90, Icons.watch),
                  _StyleItem(AppLocalizations.of(context)!.leatherBelt, 39.90, Icons.more_horiz),
                  _StyleItem(AppLocalizations.of(context)!.silverNecklace, 79.90, Icons.diamond),
                ],
                Colors.purple.shade50,
                Colors.purple.shade600,
              ),
              
              SizedBox(height: ResponsiveConstants.mdSpacing),
              
              _styleCard(
                AppLocalizations.of(context)!.footwear,
                AppLocalizations.of(context)!.stepUpYourStyleGame,
                [
                  _StyleItem(AppLocalizations.of(context)!.whiteSneakers, 89.90, Icons.directions_walk),
                  _StyleItem(AppLocalizations.of(context)!.blackBoots, 119.90, Icons.hiking),
                  _StyleItem(AppLocalizations.of(context)!.casualLoafers, 79.90, Icons.boy),
                ],
                Colors.blue.shade50,
                Colors.blue.shade600,
              ),
              
              SizedBox(height: ResponsiveConstants.mdSpacing),
              
              _styleCard(
                AppLocalizations.of(context)!.outerwear,
                AppLocalizations.of(context)!.layerUpForAnyWeather,
                [
                  _StyleItem('Denim Jacket', 69.90, Icons.checkroom),
                  _StyleItem('Wool Coat', 159.90, Icons.ac_unit),
                  _StyleItem('Light Cardigan', 49.90, Icons.layers),
                ],
                Colors.orange.shade50,
                Colors.orange.shade600,
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Styling tips
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade50, Colors.grey.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ResponsiveConstants.smPadding),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                      ),
                      child: Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                        size: ResponsiveConstants.mdIconSize,
                      ),
                    ),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    Text(
                      'Styling Tips',
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveConstants.mdSpacing),
                
                _tipItem('Mix textures for visual interest'),
                _tipItem('Layer different lengths for depth'),
                _tipItem('Add one statement piece as a focal point'),
                _tipItem('Consider the occasion and comfort'),
                
                SizedBox(height: ResponsiveConstants.smSpacing),
                
                GestureDetector(
                  onTap: () async {
          await HapticService.buttonClick();
          _showPersonalStylist(context);
        },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveConstants.smPadding,
                      vertical: ResponsiveConstants.xsPadding,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.white,
                          size: ResponsiveConstants.smIconSize,
                        ),
                        SizedBox(width: ResponsiveConstants.xsSpacing),
                        Text(
                          'Get Personal Styling Advice',
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _styleCard(
    String category, 
    String subtitle, 
    List<_StyleItem> items, 
    Color backgroundColor, 
    Color accentColor,
  ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: accentColor,
                  size: ResponsiveConstants.mdIconSize,
                ),
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.mdSpacing),
          
          // Items list
          ...items.map((item) => Container(
            margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
            padding: EdgeInsets.all(ResponsiveConstants.smPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                  ),
                  child: Icon(
                    item.icon,
                    color: Colors.grey.shade600,
                    size: ResponsiveConstants.smIconSize,
                  ),
                ),
                SizedBox(width: ResponsiveConstants.smSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Consumer<CurrencyProvider>(
                        builder: (context, currencyProvider, child) {
                          return Text(
                            currencyProvider.formatPrice(item.price, locale: Localizations.localeOf(context)),
                            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                              color: accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.add_shopping_cart,
                  color: Colors.grey.shade400,
                  size: ResponsiveConstants.smIconSize,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _tipItem(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.xsSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Expanded(
            child: Text(
              tip,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'accessories':
        return Icons.watch;
      case 'footwear':
        return Icons.directions_walk;
      case 'outerwear':
        return Icons.checkroom;
      default:
        return Icons.style;
    }
  }

  void _showPersonalStylist(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveConstants.lgRadius),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
        height: 0.6.sh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),
            
            Text(
              'Personal Styling Service',
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.lgFontSize,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _serviceFeature('1-on-1 virtual consultation', Icons.video_call),
                  _serviceFeature('Personalized style recommendations', Icons.palette),
                  _serviceFeature('Wardrobe analysis & tips', Icons.checkroom),
                  _serviceFeature('Styling for special occasions', Icons.event),
                  
                  SizedBox(height: ResponsiveConstants.lgSpacing),
                  
                  Container(
                    padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Special Offer',
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        Text(
                          'First consultation FREE for new customers',
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
          await HapticService.buttonClick();
          Navigator.pop(context);
                  // Handle booking personal stylist
        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.mdPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                  ),
                ),
                child: Text(
                  'Book Free Consultation',
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceFeature(String title, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.smPadding),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: ResponsiveConstants.mdIconSize,
            ),
          ),
          SizedBox(width: ResponsiveConstants.mdSpacing),
          Expanded(
            child: Text(
              title,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleItem {
  final String name;
  final double price;
  final IconData icon;

  _StyleItem(this.name, this.price, this.icon);
}
