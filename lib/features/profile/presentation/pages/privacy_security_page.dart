import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../presentation/bloc/profile_bloc.dart';
import '../../presentation/bloc/profile_event.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _dataCollectionEnabled = true;
  bool _locationSharing = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
        ),
        title: Text(
          AppLocalizations.of(context)!.privacyAndSecurity,
          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPrivacySection(),
            _buildSecuritySection(),
            SizedBox(height: ResponsiveConstants.xlSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: AppLocalizations.of(context)!.privacySettings,
      icon: Icons.privacy_tip_outlined,
      iconColor: Colors.black,
      children: [
        _buildSwitchTile(
          title: AppLocalizations.of(context)!.dataCollection,
          subtitle: AppLocalizations.of(context)!.allowUsToCollectUsageData,
          value: _dataCollectionEnabled,
          onChanged: (value) {
            setState(() {
              _dataCollectionEnabled = value;
            });
          },
        ),
        _buildSwitchTile(
          title: AppLocalizations.of(context)!.locationSharing,
          subtitle: AppLocalizations.of(context)!.shareYourLocationForBetterService,
          value: _locationSharing,
          onChanged: (value) {
            setState(() {
              _locationSharing = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      title: AppLocalizations.of(context)!.securitySettings,
      icon: Icons.lock_outline,
      iconColor: Colors.black,
      children: [
        _buildActionTile(
          title: AppLocalizations.of(context)!.changePassword,
          subtitle: AppLocalizations.of(context)!.updateYourAccountPassword,
          icon: Icons.key,
          onTap: () async {
            await HapticService.buttonClick();
            _showChangePasswordDialog();
          },
        ),
        _buildActionTile(
          title: AppLocalizations.of(context)!.deleteAccount,
          subtitle: AppLocalizations.of(context)!.permanentlyDeleteYourAccount,
          icon: Icons.delete_forever,
          onTap: () async {
            await HapticService.buttonClick();
            _showDeleteAccountDialog();
          },
        ),
      ],
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
              color: iconColor.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ResponsiveConstants.lgRadius),
                topRight: Radius.circular(ResponsiveConstants.lgRadius),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: ResponsiveConstants.mdIconSize,
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
            activeColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.5),
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
                color: isDark 
                    ? colorScheme.surface 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
              ),
              child: Icon(
                icon,
                color: colorScheme.onSurface.withOpacity(0.7),
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
            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onSurface.withOpacity(0.5),
              size: ResponsiveConstants.smIconSize,
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.changePassword,
          style: AppFonts.getTextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.thisFeatureWillBeImplementedSoon,
          style: AppFonts.getTextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.deleteAccount,
          style: AppFonts.getTextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.thisActionCannotBeUndone,
          style: AppFonts.getTextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: AppFonts.getTextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
              context.read<ProfileBloc>().add(DeleteAccount());
        },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: AppFonts.getTextStyle(
                color: colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
