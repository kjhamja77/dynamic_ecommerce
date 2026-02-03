import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/settings.dart' as domain;
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../orders/core/constants/order_constants.dart';

class ThemeSelector extends StatelessWidget {
  final domain.ThemeMode currentThemeMode;

  const ThemeSelector({
    super.key,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.theme,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.lgFontSize,
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          ...domain.ThemeMode.values.map((themeMode) {
            final isSelected = themeMode == currentThemeMode;
            final themeInfo = _getThemeInfo(themeMode, context);
            
            return Container(
              margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
              child: InkWell(
                onTap: () async {
                  await HapticService.buttonClick();
                  if (!isSelected) {
                    context.read<SettingsBloc>().add(UpdateThemeMode(themeMode));
                  }
                },
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveConstants.mdSpacing),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? OrderConstants.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                    border: Border.all(
                      color: isSelected 
                          ? OrderConstants.primaryColor
                          : (isDark ? colorScheme.outline.withValues(alpha: 0.5) : Colors.grey.shade300),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? OrderConstants.primaryColor.withValues(alpha: isDark ? 0.25 : 0.15)
                              : (isDark ? colorScheme.surface.withValues(alpha: 0.5) : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                        ),
                        child: Icon(
                          themeInfo.icon,
                          color: isSelected 
                              ? OrderConstants.primaryColor
                              : (isDark ? colorScheme.onSurface.withValues(alpha: 0.7) : Colors.grey.shade600),
                          size: ResponsiveConstants.mdIconSize,
                        ),
                      ),
                      SizedBox(width: ResponsiveConstants.mdSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              themeInfo.title,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.mdFontSize,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              themeInfo.description,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.smFontSize,
                                fontWeight: FontWeight.w400,
                                // When selected (orange card), use black text for better visibility
                                // When not selected, use grey/secondary text
                                color: isSelected
                                    ? Colors.black // Black text on orange card for better contrast
                                    : (isDark 
                                        ? colorScheme.onSurface.withValues(alpha: 0.7)
                                        : Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: OrderConstants.primaryColor,
                          size: ResponsiveConstants.mdIconSize,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  _ThemeInfo _getThemeInfo(domain.ThemeMode themeMode, BuildContext context) {
    switch (themeMode) {
      case domain.ThemeMode.light:
        return _ThemeInfo(
          title: AppLocalizations.of(context)!.light,
          description: AppLocalizations.of(context)!.useLightTheme,
          icon: Icons.light_mode,
        );
      case domain.ThemeMode.dark:
        return _ThemeInfo(
          title: AppLocalizations.of(context)!.dark,
          description: AppLocalizations.of(context)!.useDarkTheme,
          icon: Icons.dark_mode,
        );
      case domain.ThemeMode.system:
        return _ThemeInfo(
          title: AppLocalizations.of(context)!.system,
          description: AppLocalizations.of(context)!.followSystemTheme,
          icon: Icons.settings_system_daydream,
        );
    }
  }
}

class _ThemeInfo {
  final String title;
  final String description;
  final IconData icon;

  _ThemeInfo({
    required this.title,
    required this.description,
    required this.icon,
  });
}
