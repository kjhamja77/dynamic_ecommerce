import 'package:flutter/material.dart';
import '../constants/responsive_constants.dart';
import '../../core/theme/app_fonts.dart';

class UnifiedSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final EdgeInsetsGeometry? margin;

  const UnifiedSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.color = Colors.black,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: margin,
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: isDark 
            ? colorScheme.surface 
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(ResponsiveConstants.mdRadius), topRight: Radius.circular(ResponsiveConstants.mdRadius)),
      ),
      child: Row(
        children: [
          Icon(
            icon, 
            color: isDark ? colorScheme.onSurface : color, 
            size: 20
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Text(
            title,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.lgFontSize,
              fontWeight: FontWeight.w600,
              color: isDark ? colorScheme.onSurface : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

