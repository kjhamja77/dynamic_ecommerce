import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';

/// Unified theme constants for category cards across the search feature
/// Ensures consistent styling and follows the app's design system
class CategoryCardTheme {
  // Private constructor to prevent instantiation
  CategoryCardTheme._();

  // Card styling
  static const Color cardBackgroundColor = Colors.white;
  static const Color cardBorderColor = Color(0xFFE5E7EB); // Light gray border
  static const double cardBorderWidth = 1.0;
  static BorderRadius get cardBorderRadius => ResponsiveConstants.mdBorderRadius;
  static EdgeInsets get cardPadding => ResponsiveConstants.mdEdgeInsets;
  static EdgeInsets get cardMargin => EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing);

  // Card shadows (reduced for subtler elevation)
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.015),
      blurRadius: 3,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  // Header styling
  static EdgeInsets get headerPadding => EdgeInsets.symmetric(
    horizontal: ResponsiveConstants.mdPadding,
    vertical: ResponsiveConstants.smPadding,
  );
  static BorderRadius get headerBorderRadius => ResponsiveConstants.smBorderRadius;

  // Icon styling
  static EdgeInsets get iconPadding => ResponsiveConstants.xsEdgeInsets;
  static BorderRadius get iconBorderRadius => ResponsiveConstants.smBorderRadius;
  static double get iconOpacity => 0.1;

  // Text styling
  static TextStyle get categoryTitleStyle => TextStyle(
    fontSize: ResponsiveConstants.mdFontSize,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle get subcategoryTitleStyle => TextStyle(
    fontSize: ResponsiveConstants.smFontSize,
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade700,
  );

  static TextStyle get subcategoryCountStyle => TextStyle(
    fontSize: ResponsiveConstants.xsFontSize,
    fontWeight: FontWeight.w400,
    color: Colors.grey.shade600,
  );

  // Subcategory list styling
  static EdgeInsets get subcategoryItemPadding => EdgeInsets.symmetric(
    horizontal: ResponsiveConstants.lgPadding,
    vertical: ResponsiveConstants.smPadding,
  );

  // Subcategory indicator styling
  static Color get subcategoryIndicatorColor => Colors.grey.shade400;
  static double get subcategoryIndicatorSize => 6.0;

  // Arrow styling
  static Color get arrowColor => Colors.grey.shade400;
  static double get arrowSize => ResponsiveConstants.smIconSize;
  static Color get expandArrowColor => Colors.grey.shade600;
  static double get expandArrowSize => ResponsiveConstants.mdIconSize;

  // Animation styling
  static Duration get expansionAnimationDuration => const Duration(milliseconds: 300);
  static Curve get expansionAnimationCurve => Curves.easeInOut;

  // Hover/Interaction styling
  static Color get hoverColor => Colors.grey.shade100;
  static Color get rippleColor => Colors.grey.shade200;

  // Loading state styling
  static Color get loadingColor => Colors.grey.shade600;
  static double get loadingSize => 12.0;
  static double get loadingStrokeWidth => 1.5;

  // Error state styling
  static Color get errorColor => Colors.red.shade400;
  static Color get errorTextColor => Colors.red.shade600;

  // Empty state styling
  static Color get emptyStateColor => Colors.grey.shade400;
  static Color get emptyStateTextColor => Colors.grey.shade600;

  // Nested category styling
  static EdgeInsets get nestedCategoryMargin => EdgeInsets.only(
    left: ResponsiveConstants.mdPadding,
    bottom: ResponsiveConstants.smSpacing,
  );

  // Level-based colors for nested categories
  static List<Color> get levelColors => [
    Colors.purple.shade600,
    Colors.blue.shade600,
    Colors.green.shade600,
    Colors.orange.shade600,
    Colors.red.shade600,
    Colors.teal.shade600,
  ];

  // Level-based icons for nested categories
  static List<IconData> get levelIcons => [
    Icons.category_outlined,
    Icons.subdirectory_arrow_right,
    Icons.folder_outlined,
    Icons.inventory_2_outlined,
    Icons.label_outline,
    Icons.bookmark_outline,
  ];

  // Helper methods
  static Color getLevelColor(int level) {
    return levelColors[level % levelColors.length];
  }

  static IconData getLevelIcon(int level) {
    return levelIcons[level % levelIcons.length];
  }

  // Card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackgroundColor,
    borderRadius: cardBorderRadius,
    border: Border.all(
      color: cardBorderColor,
      width: cardBorderWidth,
    ),
    boxShadow: cardShadow,
  );

  // Header decoration
  static BoxDecoration get headerDecoration => BoxDecoration(
    borderRadius: headerBorderRadius,
  );

  // Icon decoration
  static BoxDecoration getIconDecoration(Color iconColor) => BoxDecoration(
    color: iconColor.withValues(alpha: iconOpacity),
    borderRadius: iconBorderRadius,
  );

}
