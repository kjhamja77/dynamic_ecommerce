import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class EmptyFavoritesWidget extends StatelessWidget {
  final Function(int)? onTabChanged;

  const EmptyFavoritesWidget({super.key, this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heart Icon
            Builder(
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
                    Icons.favorite_border,
                    size: 60,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                );
              },
            ),
            
            SizedBox(height: ResponsiveConstants.lgSpacing),
            
            // Title
            Builder(
              builder: (context) {
                final colorScheme = Theme.of(context).colorScheme;
                
                return Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.favoritesIsEmpty,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.xlFontSize,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: ResponsiveConstants.mdSpacing),
                    
                    // Description
                    Text(
                      AppLocalizations.of(context)!.favoritesEmptyDescription,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.mdFontSize,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
            
            SizedBox(height: ResponsiveConstants.xlSpacing),
            
            // Action Button
            Builder(
              builder: (context) {
                final colorScheme = Theme.of(context).colorScheme;
                
                return ElevatedButton(
                  onPressed: () async {
                    await HapticService.buttonClick();
                    // Switch to search tab (index 1)
                    onTabChanged?.call(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveConstants.xlPadding,
                      vertical: ResponsiveConstants.mdPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.startShopping,
                    style: AppFonts.getTextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveConstants.mdFontSize,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
