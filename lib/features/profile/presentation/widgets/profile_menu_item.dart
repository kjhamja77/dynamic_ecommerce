import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../home/presentation/constants/home_constants.dart';
import '../../../../core/theme/app_fonts.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.smPadding),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ??
                        (iconColor ?? colorScheme.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? colorScheme.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: ResponsiveConstants.mdSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.mdFontSize,
                          fontWeight: FontWeight.w500,
                          color: textColor ?? colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Text(
                        subtitle,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          color: textColor?.withValues(alpha: 0.7) ?? colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
