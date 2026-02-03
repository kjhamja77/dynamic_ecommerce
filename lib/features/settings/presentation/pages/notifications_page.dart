import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_state.dart';
import '../bloc/settings_event.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../orders/core/constants/order_constants.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final settings = state is SettingsLoaded
              ? state.settings
              : state is SettingsUpdated
                  ? state.settings
                  : null;

          final bool enabled = settings?.pushNotificationsEnabled ?? false;

          return SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              OrderConstants.primaryColor.withValues(alpha: 0.15),
                              OrderConstants.primaryColorLight.withValues(alpha: 0.08),
                            ]
                          : [
                              OrderConstants.primaryColor.withValues(alpha: 0.05),
                              OrderConstants.primaryColorLight.withValues(alpha: 0.02),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    color: isDark ? colorScheme.surface : null,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : OrderConstants.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isDark
                          ? colorScheme.outline.withOpacity(0.2)
                          : OrderConstants.primaryColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                  child: Column(
                    children: [
                      Lottie.asset(
                        'assets/animations/Notifications.json',
                        height: 260,
                        repeat: true,
                        frameRate: FrameRate.max,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          final theme = Theme.of(context);
                          final colorScheme = theme.colorScheme;
                          final isDark = theme.brightness == Brightness.dark;
                          
                          return Container(
                            height: 260,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? colorScheme.surface
                                  : OrderConstants.primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? colorScheme.outline.withOpacity(0.2)
                                    : OrderConstants.primaryColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  size: 80,
                                  color: OrderConstants.primaryColor,
                                ),
                                SizedBox(height: ResponsiveConstants.smSpacing),
                                Text(
                                  AppLocalizations.of(context)!.notifications,
                                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: OrderConstants.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: ResponsiveConstants.mdSpacing),
                      Text(
                        AppLocalizations.of(context)!.stayInTheLoop,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Text(
                        AppLocalizations.of(context)!.notificationsDescription,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          color: colorScheme.onSurface.withOpacity(0.7),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveConstants.lgSpacing),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? colorScheme.outline.withOpacity(0.2)
                          : OrderConstants.primaryColor.withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : OrderConstants.primaryColor.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                      decoration: BoxDecoration(
                        color: isDark
                            ? OrderConstants.primaryColor.withValues(alpha: 0.2)
                            : OrderConstants.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                      ),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: OrderConstants.primaryColor,
                        size: ResponsiveConstants.mdIconSize,
                      ),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.enableNotifications,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.receivePushNotifications,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    trailing: Switch(
                      value: enabled,
                      onChanged: (value) {
                        // Persist immediately by updating whole settings via bloc pipeline
                        context.read<SettingsBloc>().add(UpdatePushNotifications(value));
                      },
                      activeColor: OrderConstants.primaryColor,
                      activeTrackColor: OrderConstants.primaryColorLight,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
