import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';

class HomeConstants {
  // Tab Lists
  static const List<String> outerTabs = [
    'Logo',
    'Search', 
    'Favorites',
    'Cart',
    'Profile'
  ];

  static const List<IconData> outerTabIcons = [
    Icons.home,
    Icons.search,
    Icons.favorite,
    Icons.shopping_cart,
    Icons.person,
  ];

  // Dynamic inner tabs will be loaded from API
  static List<String> innerTabs = [];

  // UI Constants - Now using ResponsiveConstants
  static double get defaultPadding => ResponsiveConstants.mdPadding;
  static double get smallPadding => ResponsiveConstants.smPadding;
  static double get largePadding => ResponsiveConstants.lgPadding;
  static double get iconSize => ResponsiveConstants.mdIconSize;
  static double get borderRadius => ResponsiveConstants.mdRadius;
  static double get elevation => ResponsiveConstants.xsElevation;
  static double get indicatorWeight => ResponsiveConstants.tabIndicatorWeight;
  
  // Text Sizes - Now using ResponsiveConstants
  static double get titleFontSize => ResponsiveConstants.titleFontSize;
  static double get subtitleFontSize => ResponsiveConstants.lgFontSize;
  static double get tabFontSize => ResponsiveConstants.lgFontSize;
  static double get innerTabFontSize => ResponsiveConstants.mdFontSize;
  
  // Colors
  static const Color primaryColor = Color(0xFFF36729);
  static const Color backgroundColor = Colors.white;
  
  // Animation Duration
  static const Duration tabAnimationDuration = Duration(milliseconds: 200);
}
