import 'package:flutter/material.dart';

/// Constants for auth-related colors
class AuthColorConstants {
  // Private constructor to prevent instantiation
  AuthColorConstants._();

  // Primary Colors - Matching home screen theme
  static const Color primaryColor = Color(0xFFF36729);
  static const Color primaryColorLight = Color(0xFFF89A63); // lighter variant
  
  // Background Colors
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  
  // Text Colors
  static const Color primaryTextColor = Colors.black;
  static const Color secondaryTextColor = Color(0xFF424242);
  static const Color hintTextColor = Color(0xFF757575);
  
  // Border Colors
  static const Color primaryBorderColor = primaryColor;
  static const Color secondaryBorderColor = Color(0xFFE0E0E0);
  
  // Interactive Colors
  static const Color linkColor = primaryColor;
  static const Color activeColor = primaryColor;
  
  // Helper methods for opacity variants
  static Color get primaryColorWithOpacity10 => primaryColor.withValues(alpha: 0.1);
  static Color get primaryColorWithOpacity20 => primaryColor.withValues(alpha: 0.2);
  static Color get primaryColorWithOpacity50 => primaryColor.withValues(alpha: 0.5);
}
