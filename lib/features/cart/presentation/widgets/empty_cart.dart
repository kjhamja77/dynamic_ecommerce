import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class EmptyCart extends StatelessWidget {
  final Function(int)? onTabChanged;
  
  const EmptyCart({super.key, this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmptyCartIcon(),
            SizedBox(height: ResponsiveConstants.xlSpacing),
          _buildTitle(context),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          _buildDescription(context),
            SizedBox(height: ResponsiveConstants.xlSpacing),
            _buildStartShoppingButton(context),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            _buildFeatureItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCartIcon() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shopping_cart_outlined,
            size: ResponsiveConstants.xlIconSize,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Text(
      AppLocalizations.of(context)!.yourCartIsEmpty,
      style: AppFonts.getTextStyle(
        fontSize: ResponsiveConstants.titleFontSize,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Text(
      AppLocalizations.of(context)!.cartEmptyDescription,
      style: AppFonts.getTextStyle(
        fontSize: ResponsiveConstants.mdFontSize,
        color: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStartShoppingButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ElevatedButton(
      onPressed: () async {
        await HapticService.buttonClick();
        _navigateToSearchTab(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.xlPadding,
          vertical: ResponsiveConstants.mdPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        ),
      ),
      child: Text(
        AppLocalizations.of(context)!.startShopping,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.mdFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFeatureItems(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _FeatureItem(
          icon: Icons.favorite_border,
          title: AppLocalizations.of(context)!.favorites,
          subtitle: AppLocalizations.of(context)!.saveItemsForLater,
          onTap: () async {
          await HapticService.buttonClick();
          _navigateToFavoritesTab(context);
        },
        ),
        _FeatureItem(
          icon: Icons.local_offer_outlined,
          title: AppLocalizations.of(context)!.deals,
          subtitle: AppLocalizations.of(context)!.findGreatOffers,
          onTap: () async {
          await HapticService.buttonClick();
          _navigateToSearchTab(context);
        },
        ),
      ],
    );
  }

  void _navigateToSearchTab(BuildContext context) {
    // Switch to search tab (index 1)
    onTabChanged?.call(1);
  }

  void _navigateToFavoritesTab(BuildContext context) {
    // Switch to favorites tab (index 2)
    onTabChanged?.call(2);
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: ResponsiveConstants.lgIconSize,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            _buildFeatureTitle(),
            SizedBox(height: ResponsiveConstants.xsSpacing),
            _buildFeatureSubtitle(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTitle() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Text(
          title,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.smFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        );
      },
    );
  }

  Widget _buildFeatureSubtitle() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Text(
          subtitle,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.xsFontSize,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
