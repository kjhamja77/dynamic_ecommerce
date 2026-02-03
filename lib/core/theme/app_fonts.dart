import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_localization_service.dart';

class AppFonts {
  static final AppLocalizationService _localizationService = AppLocalizationService();
  
  /// Create TextStyle with appropriate Google Font
  static TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    TextDecorationStyle? decorationStyle,
    Color? decorationColor,
    double? decorationThickness,
    FontStyle? fontStyle,
    List<FontFeature>? fontFeatures,
    List<Shadow>? shadows,
    Paint? foreground,
  }) {
    if (_localizationService.isRTL) {
      return GoogleFonts.almarai(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        decoration: decoration,
        decorationStyle: decorationStyle,
        decorationColor: decorationColor,
        decorationThickness: decorationThickness,
        fontStyle: fontStyle,
        fontFeatures: fontFeatures,
        shadows: shadows,
        foreground: foreground,
      );
    } else {
      return GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        decoration: decoration,
        decorationStyle: decorationStyle,
        decorationColor: decorationColor,
        decorationThickness: decorationThickness,
        fontStyle: fontStyle,
        fontFeatures: fontFeatures,
        shadows: shadows,
        foreground: foreground,
      );
    }
  }
  
}

/// Common text styles with automatic font selection
class AppFontStyles {
  static TextStyle get headlineLarge => AppFonts.getTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle get headlineMedium => AppFonts.getTextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle get headlineSmall => AppFonts.getTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get titleLarge => AppFonts.getTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get titleMedium => AppFonts.getTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get titleSmall => AppFonts.getTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get bodyLarge => AppFonts.getTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static TextStyle get bodyMedium => AppFonts.getTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  
  static TextStyle get bodySmall => AppFonts.getTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  
  static TextStyle get labelLarge => AppFonts.getTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get labelMedium => AppFonts.getTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get labelSmall => AppFonts.getTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}
