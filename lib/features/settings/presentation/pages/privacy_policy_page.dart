import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.privacyPolicy,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(context, AppLocalizations.of(context)!.privacyPolicy),
              _sectionBody(context,
                  'We value your privacy. This policy explains what data we collect, why we collect it, and how we use it. We only collect the minimum data required to run our services and improve your experience.'),
              SizedBox(height: ResponsiveConstants.mdSpacing),
              _sectionTitle(context, 'Data we collect'),
              _sectionBody(context,
                  '- Account information (name, email, phone)\n- Usage data (app interactions, device info)\n- Optional analytics and crash reports (if enabled in Settings)'),
              SizedBox(height: ResponsiveConstants.mdSpacing),
              _sectionTitle(context, 'How we use your data'),
              _sectionBody(context,
                  '- To provide core features (orders, notifications)\n- To improve performance and reliability\n- To communicate important updates about your account'),
              SizedBox(height: ResponsiveConstants.mdSpacing),
              _sectionTitle(context, 'Your controls'),
              _sectionBody(context,
                  'From Settings you can disable analytics and notifications at any time. You may also request deletion of your account and data through the Profile section.'),
              SizedBox(height: ResponsiveConstants.lgSpacing),
              Text(
                'Last updated: Jan 1, 2025',
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.smFontSize,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: AppFonts.getTextStyle(
        fontSize: ResponsiveConstants.lgFontSize,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _sectionBody(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: AppFonts.getTextStyle(
        fontSize: ResponsiveConstants.mdFontSize,
        color: colorScheme.onSurface.withValues(alpha: 0.8),
        height: 1.6,
      ),
    );
  }
}






