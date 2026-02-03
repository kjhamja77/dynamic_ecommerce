import 'package:flutter/material.dart';
import '../constants/responsive_constants.dart';
import '../../core/theme/app_fonts.dart';

enum AppSnackBarType { success, error, info }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final Color background = switch (type) {
      AppSnackBarType.success => const Color(0xFF065F46), // darker green
      AppSnackBarType.error => const Color(0xFF991B1B), // darker red
      AppSnackBarType.info => const Color(0xFF111827), // near-black
    };

    final IconData resolvedIcon = icon ?? switch (type) {
      AppSnackBarType.success => Icons.check_circle_outline,
      AppSnackBarType.error => Icons.error_outline,
      AppSnackBarType.info => Icons.info_outline,
    };

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: background,
      elevation: 0,
      duration: duration,
      margin: EdgeInsets.all(ResponsiveConstants.mdPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
      ),
      content: Row(
        children: [
          Icon(resolvedIcon, color: Colors.white, size: ResponsiveConstants.mdIconSize),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Expanded(
            child: Text(
              message,
              style: AppFonts.getTextStyle(color: Colors.white,
                fontSize: ResponsiveConstants.mdFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onAction,
              textColor: Colors.white,
              disabledTextColor: Colors.white70,
            )
          : null,
    );

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) =>
      show(context, message: message, type: AppSnackBarType.success, actionLabel: actionLabel, onAction: onAction);

  static void error(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) =>
      show(context, message: message, type: AppSnackBarType.error, actionLabel: actionLabel, onAction: onAction);

  static void info(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) =>
      show(context, message: message, type: AppSnackBarType.info, actionLabel: actionLabel, onAction: onAction);
}
