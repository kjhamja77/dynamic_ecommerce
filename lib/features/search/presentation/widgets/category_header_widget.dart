import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/search_category.dart';
import '../constants/search_icon_constants.dart';
import '../constants/category_card_theme.dart';
import '../../../../core/theme/app_fonts.dart';

class CategoryHeaderWidget extends StatelessWidget {
  final SearchCategory category;
  final bool hasSubcategories;
  final bool isExpanded;
  final VoidCallback onTap;

  const CategoryHeaderWidget({
    super.key,
    required this.category,
    required this.hasSubcategories,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: CategoryCardTheme.headerBorderRadius,
      splashColor: CategoryCardTheme.rippleColor,
      highlightColor: CategoryCardTheme.hoverColor,
      child: Padding(
        padding: CategoryCardTheme.headerPadding,
        child: Row(
          children: [
            // Category Icon
            _buildCategoryIcon(),
            
            SizedBox(width: ResponsiveConstants.mdSpacing),
            
            // Category Title
            Expanded(
              child: Text(
                category.title,
                style: AppFonts.getTextStyle(fontSize: CategoryCardTheme.categoryTitleStyle.fontSize,
                  fontWeight: CategoryCardTheme.categoryTitleStyle.fontWeight,
                  color: CategoryCardTheme.categoryTitleStyle.color,
                ),
              ),
            ),
            
            // Expand/Collapse or Arrow
            if (hasSubcategories)
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0.0,
                duration: CategoryCardTheme.expansionAnimationDuration,
                curve: CategoryCardTheme.expansionAnimationCurve,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: CategoryCardTheme.expandArrowColor,
                  size: CategoryCardTheme.expandArrowSize,
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: CategoryCardTheme.arrowColor,
                size: CategoryCardTheme.arrowSize,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    // Convert hex color to Color object
    Color iconColor;
    try {
      iconColor = Color(int.parse(category.colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      iconColor = Colors.grey;
    }

    // Get icon data from constants
    IconData iconData = SearchIconConstants.getCategoryIcon(category.iconName);

    return Container(
      padding: CategoryCardTheme.iconPadding,
      decoration: CategoryCardTheme.getIconDecoration(iconColor),
      child: Icon(
        iconData,
        color: iconColor,
        size: ResponsiveConstants.mdIconSize,
      ),
    );
  }
}
