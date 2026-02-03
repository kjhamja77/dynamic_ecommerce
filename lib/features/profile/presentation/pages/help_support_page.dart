import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/widgets/unified_section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton(
        tooltip: AppLocalizations.of(context)!.chatWithUs,
        onPressed: () async {
          await HapticService.buttonClick();
          // TODO: Implement chat functionality
        },
        backgroundColor: Colors.black, 
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white,),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
        ),
        title: Text(
          AppLocalizations.of(context)!.helpAndSupport,
          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(context),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            _buildSearchBox(context),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            _buildQuickActions(context),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            _buildFaqSection(context),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            _buildContactSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 25,
            offset: const Offset(0, 15),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.support_agent,
              size: 52,
              color: Colors.white,
            ),
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Text(
            AppLocalizations.of(context)!.howCanWeHelpYou,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize + 2,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          Text(
            AppLocalizations.of(context)!.weAreHereToHelp,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.mdPadding,
              vertical: ResponsiveConstants.smPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: Colors.white70,
                  size: 18,
                ),
                SizedBox(width: ResponsiveConstants.smSpacing),
                Text(
                  AppLocalizations.of(context)!.twentyFourSevenSupportAvailable,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.mdPadding,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.smPadding),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.search, color: Colors.black87, size: 20),
          ),
          SizedBox(width: ResponsiveConstants.mdSpacing),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.searchHelpArticlesAndFaqs,
              style: AppFonts.getTextStyle(color: Colors.grey.shade600,
                fontSize: ResponsiveConstants.mdFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnifiedSectionHeader(
          title: AppLocalizations.of(context)!.quickActions,
          icon: Icons.flash_on,
          color: Colors.orange,
        ),
        SizedBox(height: ResponsiveConstants.smSpacing),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width >= 1200
              ? 4
              : MediaQuery.of(context).size.width >= 900
                  ? 3
                  : 2,
          crossAxisSpacing: ResponsiveConstants.mdSpacing,
          mainAxisSpacing: ResponsiveConstants.mdSpacing,
          childAspectRatio: MediaQuery.of(context).size.width >= 900 ? 1.4 : 1.1,
          children: [
            _quickActionCard(
              context,
              icon: Icons.local_shipping_outlined,
              label: AppLocalizations.of(context)!.trackOrder,
              subtitle: AppLocalizations.of(context)!.checkYourOrderStatus,
              color: Colors.green.shade600,
              onTap: () {},
            ),
            _quickActionCard(
              context,
              icon: Icons.assignment_return_outlined,
              label: AppLocalizations.of(context)!.returns,
              subtitle: AppLocalizations.of(context)!.requestAReturn,
              color: Colors.orange.shade600,
              onTap: () {},
            ),
            _quickActionCard(
              context,
              icon: Icons.payment_outlined,
              label: AppLocalizations.of(context)!.payments,
              subtitle: AppLocalizations.of(context)!.paymentIssues,
              color: Colors.blue.shade600,
              onTap: () {},
            ),
            _quickActionCard(
              context,
              icon: Icons.account_circle_outlined,
              label: AppLocalizations.of(context)!.account,
              subtitle: AppLocalizations.of(context)!.accountSettings,
              color: Colors.purple.shade600,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickActionCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.lgPadding,
          vertical: ResponsiveConstants.mdPadding,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Text(
              label,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveConstants.xsSpacing),
            Text(
              subtitle,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnifiedSectionHeader(
          title: AppLocalizations.of(context)!.frequentlyAskedQuestions,
          icon: Icons.question_answer,
          color: Colors.indigo,
        ),
        SizedBox(height: ResponsiveConstants.smSpacing),
        _faqItem(
          context,
          AppLocalizations.of(context)!.howDoITrackMyOrder,
          AppLocalizations.of(context)!.trackOrderAnswer,
        ),
        _faqItem(
          context,
          AppLocalizations.of(context)!.howDoIRequestAReturn,
          AppLocalizations.of(context)!.returnAnswer,
        ),
        _faqItem(
          context,
          AppLocalizations.of(context)!.howCanIChangeMyAddress,
          AppLocalizations.of(context)!.addressAnswer,
        ),
        _faqItem(
          context,
          AppLocalizations.of(context)!.whatPaymentMethodsDoYouAccept,
          AppLocalizations.of(context)!.paymentMethodsAnswer,
        ),
      ],
    );
  }

  Widget _faqItem(BuildContext context, String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedBackgroundColor: Colors.white,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          tilePadding: EdgeInsets.symmetric(
            horizontal: ResponsiveConstants.mdPadding,
            vertical: ResponsiveConstants.smPadding,
          ),
          childrenPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveConstants.mdPadding,
            vertical: ResponsiveConstants.smPadding,
          ),
          iconColor: Colors.indigo.shade600,
          collapsedIconColor: Colors.indigo.shade400,
          title: Text(
            question,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnifiedSectionHeader(
          title: AppLocalizations.of(context)!.contactSupport,
          icon: Icons.contact_support,
          color: Colors.teal,
        ),
        SizedBox(height: ResponsiveConstants.smSpacing),
        _contactTile(
          icon: Icons.chat_bubble_outline,
          title: AppLocalizations.of(context)!.liveChat,
          subtitle: AppLocalizations.of(context)!.chatWithOurSupportTeam,
          color: Colors.green.shade600,
          onTap: () {},
        ),
        _contactTile(
          icon: Icons.email_outlined,
          title: AppLocalizations.of(context)!.emailSupport,
          subtitle: 'support@example.com',
          color: Colors.blue.shade600,
          onTap: () async {
          await HapticService.buttonClick();
          _sendEmail();
        },
        ),
        _contactTile(
          icon: Icons.phone_outlined,
          title: AppLocalizations.of(context)!.phoneSupport,
          subtitle: '+1 (555) 123-4567',
          color: Colors.orange.shade600,
          onTap: () async {
          await HapticService.buttonClick();
          _makePhoneCall();
        },
          showDivider: false,
        ),
      ],
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: ResponsiveConstants.xsSpacing),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListTile(
            onTap: onTap,
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            title: Text(
              title,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                color: Colors.grey.shade700,
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.all(ResponsiveConstants.smPadding),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600, size: 16),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: ResponsiveConstants.mdSpacing,
            endIndent: ResponsiveConstants.mdSpacing,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@example.com',
      query: 'subject=Support Request&body=Hello, I need help with...',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+15551234567',
    );
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
