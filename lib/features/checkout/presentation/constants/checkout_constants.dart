import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';

class CheckoutConstants {
  // Colors
  static const Color primaryColor = Color(0xFFF36729);
  static const Color backgroundColor = Colors.white;
  static const Color cardBackgroundColor = Colors.white;
  static const Color dividerColor = Color(0xFFE5E7EB);
  static const Color shadowColor = Color(0x0D000000);
  
  // Dimensions
  static double get cardPadding => ResponsiveConstants.mdPadding;
  static double get cardBorderRadius => ResponsiveConstants.mdRadius;
  static double get cardShadowBlur => 10.0;
  static double get cardShadowOffset => 2.0;
  
  // Spacing
  static double get sectionSpacing => ResponsiveConstants.lgSpacing;
  static double get itemSpacing => ResponsiveConstants.mdSpacing;
  static double get smallSpacing => ResponsiveConstants.smSpacing;
  
  // Text Sizes
  static double get titleFontSize => ResponsiveConstants.lgFontSize;
  static double get subtitleFontSize => ResponsiveConstants.mdFontSize;
  static double get bodyFontSize => ResponsiveConstants.mdFontSize;
  static double get captionFontSize => ResponsiveConstants.smFontSize;
  
  // Icon Sizes
  static double get iconSize => ResponsiveConstants.mdIconSize;
  static double get smallIconSize => ResponsiveConstants.smIconSize;
  
  // Business Logic Constants
  static const double freeShippingThreshold = 50.0;
  static const double shippingCost = 9.99;
  static const double taxRate = 0.08;
  static const double discountThreshold = 100.0;
  static const double discountRate = 0.10;
}
