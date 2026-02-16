import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/language_selector.dart';
import '../widgets/theme_selector.dart';
import 'notifications_page.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../orders/core/constants/order_constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final String _appVersion = AppConstants.appVersion;

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.background,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: AppFonts.getTextStyle(
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                  ),
                ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SettingsLoaded || state is SettingsUpdated) {
            final settings = state is SettingsLoaded 
                ? state.settings 
                : (state as SettingsUpdated).settings;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: AppLocalizations.of(context)!.languageRegion,
                    icon: Icons.language,
                    iconColor: OrderConstants.primaryColor,
                    children: [
                      Builder(
                        builder: (context) {
                          final colorScheme = Theme.of(context).colorScheme;
                          return Container(
                            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: LanguageSelector(
                              currentLanguage: settings.language,
                              onLanguageChanged: () {
                                // Reload settings to reflect language change
                                context.read<SettingsBloc>().add(LoadSettings());
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  _buildSection(
                    title: AppLocalizations.of(context)!.appearance,
                    icon: Icons.palette_outlined,
                    iconColor: OrderConstants.primaryColor,
                    children: [
                      Container(
                        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                        child: ThemeSelector(currentThemeMode: settings.themeMode),
                      ),
                    ],
                  ),

                  _buildSection(
                    title: AppLocalizations.of(context)!.appSettings,
                    icon: Icons.settings_outlined,
                    iconColor: OrderConstants.primaryColor,
                    children: [
                      _buildSwitchTile(
                        title: AppLocalizations.of(context)!.autoUpdate,
                        subtitle: AppLocalizations.of(context)!.automaticallyUpdateTheApp,
                        value: settings.autoUpdateEnabled,
                        onChanged: (value) => context.read<SettingsBloc>().add(UpdateAutoUpdate(value)),
                      ),
                      _buildSwitchTile(
                        title: AppLocalizations.of(context)!.locationServices,
                        subtitle: AppLocalizations.of(context)!.allowAppToAccessLocation,
                        value: settings.locationServicesEnabled,
                        onChanged: (value) => context.read<SettingsBloc>().add(UpdateLocationServices(value)),
                      ),
                      _buildActionTile(
                        title: AppLocalizations.of(context)!.notifications,
                        subtitle: AppLocalizations.of(context)!.receivePushNotifications,
                        icon: Icons.notifications_active_outlined,
                        onTap: () async {
          await HapticService.buttonClick();
          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NotificationsPage()),
                          );
        },
                      ),
                    ],
                  ),

                  _buildSection(
                    title: AppLocalizations.of(context)!.about,
                    icon: Icons.info_outline,
                    iconColor: OrderConstants.primaryColor,
                    children: [
                      _buildActionTile(
                        title: AppLocalizations.of(context)!.appVersion,
                        subtitle: _appVersion,
                        icon: Icons.info,
                        showArrow: false,
                        onTap: () async {
                          await HapticService.buttonClick();
                          // TODO: Show app version details
                        },
                      ),
                      _buildActionTile(
                        title: AppLocalizations.of(context)!.privacyPolicy,
                        subtitle: AppLocalizations.of(context)!.readOurPrivacyPolicy,
                        icon: Icons.privacy_tip,
                        onTap: () async {
                          await HapticService.buttonClick();
                          Navigator.of(context).pushNamed('/privacy');
                        },
                      ),
                      _buildActionTile(
                        title: AppLocalizations.of(context)!.termsOfService,
                        subtitle: AppLocalizations.of(context)!.readOurTermsOfService,
                        icon: Icons.description,
                        onTap: () async {
                          await HapticService.buttonClick();
                          Navigator.of(context).pushNamed('/terms');
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveConstants.xlSpacing),
                ],
              ),
            );
          }

          final colorScheme = Theme.of(context).colorScheme;
          return Center(
            child: Text(
              AppLocalizations.of(context)!.somethingWentWrong,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  iconColor.withValues(alpha: isDark ? 0.1 : 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ResponsiveConstants.lgRadius),
                topRight: Radius.circular(ResponsiveConstants.lgRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                  ),
                  child: Icon(icon, color: iconColor, size: ResponsiveConstants.mdIconSize),
                ),
                SizedBox(width: ResponsiveConstants.smSpacing),
                Text(
                  title,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                Text(
                  subtitle,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                    color: colorScheme.onSurface.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: OrderConstants.primaryColor,
            activeTrackColor: OrderConstants.primaryColorLight,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.smPadding),
              decoration: BoxDecoration(
                color: OrderConstants.primaryColor.withValues(
                  alpha: isDark ? 0.2 : 0.1,
                ),
                borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
              ),
              child: Icon(
                icon,
                color: OrderConstants.primaryColor,
                size: ResponsiveConstants.smIconSize,
              ),
            ),
            SizedBox(width: ResponsiveConstants.mdSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.xsSpacing),
                  Text(
                    subtitle,
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                color: OrderConstants.primaryColor.withValues(alpha: 0.6),
                size: ResponsiveConstants.smIconSize,
              ),
          ],
        ),
      ),
    );
  }
}
