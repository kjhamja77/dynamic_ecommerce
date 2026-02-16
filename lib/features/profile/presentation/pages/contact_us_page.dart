import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/services/haptic_service.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  static const String email = 'info@alkardas.com';
  static const String instagramUrl = 'https://www.instagram.com/bazar__iq/profilecard/?igsh=YnY0Mm1qZmdrZmM2';
  static const String facebookUrl = 'https://www.facebook.com/bazar.iq.fb/';
  static const String phone = '+964 770 123 4567'; // Default - can be updated

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            await HapticService.buttonClick();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          _tr(context, en: 'Contact Us', ar: 'اتصل بنا'),
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surface
                          : Colors.black.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.contact_support_outlined,
                      size: 50,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.lgSpacing),
                  Text(
                    _tr(context, en: 'We\'re Here to Help', ar: 'نحن هنا للمساعدة'),
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.xlFontSize,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                  Text(
                    _tr(
                      context,
                      en: 'Get in touch with us through any of the following channels',
                      ar: 'تواصل معنا من خلال أي من القنوات التالية',
                    ),
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.mdFontSize,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: ResponsiveConstants.xlSpacing),

            // Contact Options
            _ContactCard(
              icon: Icons.email_outlined,
              title: _tr(context, en: 'Email', ar: 'البريد الإلكتروني'),
              subtitle: email,
              iconColor: Colors.red.shade600,
              iconBackgroundColor: isDark
                  ? Colors.red.shade900.withOpacity(0.3)
                  : Colors.red.shade50,
              onTap: () => _launchEmail(context),
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),

            _ContactCard(
              icon: Icons.phone_outlined,
              title: _tr(context, en: 'Phone', ar: 'الهاتف'),
              subtitle: phone,
              iconColor: Colors.green.shade600,
              iconBackgroundColor: isDark
                  ? Colors.green.shade900.withOpacity(0.3)
                  : Colors.green.shade50,
              onTap: () => _launchPhone(context),
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),

            // Social Media Section
            Text(
              _tr(context, en: 'Follow Us', ar: 'تابعنا'),
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.lgFontSize,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),

            _SocialCardWithImage(
              imagePath: 'assets/images/instagram.jpg',
              title: _tr(context, en: 'Instagram', ar: 'إنستغرام'),
              subtitle: '@bazar__iq',
              onTap: () => _launchUrl(context, instagramUrl),
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),

            _SocialCard(
              icon: Icons.facebook,
              title: _tr(context, en: 'Facebook', ar: 'فيسبوك'),
              subtitle: '@bazar.iq.fb',
              color: Colors.blue.shade600,
              onTap: () => _launchUrl(context, facebookUrl),
            ),

            SizedBox(height: ResponsiveConstants.xlSpacing),
          ],
        ),
      ),
    );
  }

  String _tr(BuildContext context, {required String en, required String ar}) {
    return Directionality.of(context) == TextDirection.rtl ? ar : en;
  }

  Future<void> _launchEmail(BuildContext context) async {
    await HapticService.buttonClick();
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${_tr(context, en: 'Contact Support', ar: 'الاتصال بالدعم')}',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showError(context, _tr(context, en: 'Could not launch email', ar: 'لا يمكن فتح البريد الإلكتروني'));
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    await HapticService.buttonClick();
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showError(context, _tr(context, en: 'Could not launch phone dialer', ar: 'لا يمكن فتح تطبيق الهاتف'));
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    await HapticService.buttonClick();
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showError(context, _tr(context, en: 'Could not open link', ar: 'لا يمكن فتح الرابط'));
    }
  }

  void _showError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              ),
              child: Icon(icon, color: iconColor, size: ResponsiveConstants.lgIconSize),
            ),
            SizedBox(width: ResponsiveConstants.mdSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.xsSpacing / 2),
                  // Force phone numbers to be LTR always
                  Builder(
                    builder: (context) {
                      final currentDirection = Directionality.of(context);
                      return Directionality(
                        textDirection: icon == Icons.phone_outlined ? TextDirection.ltr : currentDirection,
                        child: Text(
                          subtitle,
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.smFontSize,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SocialCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDark
                    ? color.withOpacity(0.2)
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              ),
              child: Icon(icon, color: color, size: ResponsiveConstants.lgIconSize),
            ),
            SizedBox(width: ResponsiveConstants.mdSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.xsSpacing / 2),
                  Text(
                    subtitle,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.smFontSize,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              size: 20,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialCardWithImage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SocialCardWithImage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: ResponsiveConstants.mdSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.xsSpacing / 2),
                  Text(
                    subtitle,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.smFontSize,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              size: 20,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}

