import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/services/app_localization_service.dart';

/// Primary brand color
const Color _primaryColor = Color(0xFFF36729);

/// Light theme colors
class LightThemeColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color secondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE0E0E0);
}

/// Dark theme colors
class DarkThemeColors {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color secondary = Color(0xFF9E9E9E);
  static const Color border = Color(0xFF2C2C2C);
  static const Color divider = Color(0xFF2C2C2C);
}

/// Build light theme
ThemeData buildLightTheme() {
  final localizationService = AppLocalizationService();
  
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _primaryColor,
      surface: LightThemeColors.surface,
      background: LightThemeColors.background,
      error: const Color(0xFFB00020),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: LightThemeColors.onSurface,
      onBackground: LightThemeColors.onBackground,
      onError: Colors.white,
    ),
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: LightThemeColors.background,
    textTheme: localizationService.isRTL 
        ? GoogleFonts.almaraiTextTheme(ThemeData.light().textTheme)
        : GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: LightThemeColors.background,
      foregroundColor: LightThemeColors.onBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: LightThemeColors.onBackground),
      titleTextStyle: AppFonts.getTextStyle(
        color: LightThemeColors.onBackground,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      toolbarTextStyle: AppFonts.getTextStyle(
        color: LightThemeColors.onBackground,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    cardTheme: CardThemeData(
      color: LightThemeColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: LightThemeColors.border, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: LightThemeColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: AppFonts.getTextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: LightThemeColors.onBackground,
      ),
      contentTextStyle: AppFonts.getTextStyle(
        fontSize: 14,
        color: LightThemeColors.onSurface,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: LightThemeColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      showDragHandle: true,
      dragHandleColor: LightThemeColors.secondary,
      dragHandleSize: const Size(36, 4),
    ),
    dividerTheme: DividerThemeData(
      color: LightThemeColors.divider,
      thickness: 1,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.white;
        }
        return Colors.grey.shade300;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryColor;
        }
        return Colors.grey.shade300;
      }),
      trackOutlineColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryColor.withValues(alpha: 0.4);
        }
        return Colors.grey.shade400;
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LightThemeColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: LightThemeColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: LightThemeColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
    ),
  );
}

/// Build dark theme
ThemeData buildDarkTheme() {
  final localizationService = AppLocalizationService();
  
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      secondary: _primaryColor,
      surface: DarkThemeColors.surface,
      background: DarkThemeColors.background,
      error: const Color(0xFFCF6679),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: DarkThemeColors.onSurface,
      onBackground: DarkThemeColors.onBackground,
      onError: Colors.black,
    ),
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: DarkThemeColors.background,
    textTheme: localizationService.isRTL 
        ? GoogleFonts.almaraiTextTheme(ThemeData.dark().textTheme)
        : GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: DarkThemeColors.background,
      foregroundColor: DarkThemeColors.onBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: DarkThemeColors.onBackground),
      titleTextStyle: AppFonts.getTextStyle(
        color: DarkThemeColors.onBackground,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      toolbarTextStyle: AppFonts.getTextStyle(
        color: DarkThemeColors.onBackground,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    cardTheme: CardThemeData(
      color: DarkThemeColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: DarkThemeColors.border, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: DarkThemeColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: AppFonts.getTextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: DarkThemeColors.onBackground,
      ),
      contentTextStyle: AppFonts.getTextStyle(
        fontSize: 14,
        color: DarkThemeColors.onSurface,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: DarkThemeColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      showDragHandle: true,
      dragHandleColor: DarkThemeColors.secondary,
      dragHandleSize: const Size(36, 4),
    ),
    dividerTheme: DividerThemeData(
      color: DarkThemeColors.divider,
      thickness: 1,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.white;
        }
        return Colors.grey.shade700;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryColor;
        }
        return Colors.grey.shade800;
      }),
      trackOutlineColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryColor.withValues(alpha: 0.4);
        }
        return Colors.grey.shade700;
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkThemeColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: DarkThemeColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: DarkThemeColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
    ),
  );
}

/// Legacy function for backward compatibility - returns light theme
@Deprecated('Use buildLightTheme() or buildDarkTheme() instead')
ThemeData buildAppTheme() {
  return buildLightTheme();
}


