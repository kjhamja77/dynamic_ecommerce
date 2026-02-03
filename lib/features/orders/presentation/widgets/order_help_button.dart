import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order.dart';
import '../../core/constants/order_constants.dart';

class OrderHelpButton extends StatelessWidget {
  final Order order;

  static const String customerServicePhone = '+964 770 123 4567';
  static const String whatsappNumber = '+9647701234567';

  const OrderHelpButton({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return FloatingActionButton.extended(
      onPressed: () async {
        await HapticService.buttonClick();
        _showHelpOptions(context);
      },
      icon: const Icon(Icons.help_outline),
      label: Text(
        loc.needHelp,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.mdFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: OrderConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    );
  }

  void _showHelpOptions(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveConstants.xlRadius),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: OrderConstants.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.support_agent,
                      color: OrderConstants.primaryColor,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: ResponsiveConstants.mdSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.howCanWeHelp,
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.lgFontSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          loc.orderNumberWithValue(order.orderNumber),
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.smFontSize,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      await HapticService.buttonClick();
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),

              SizedBox(height: ResponsiveConstants.lgSpacing),
              const Divider(height: 1),
              SizedBox(height: ResponsiveConstants.smSpacing),

              _HelpOption(
                icon: Icons.phone_outlined,
                title: loc.callCustomerService,
                subtitle: customerServicePhone,
                iconColor: OrderConstants.successColor,
                iconBackgroundColor: OrderConstants.successColor.withValues(alpha: 0.1),
                onTap: () async {
                  await HapticService.buttonClick();
                  Navigator.of(ctx).pop();
                  _launchPhone(context);
                },
              ),

              SizedBox(height: ResponsiveConstants.smSpacing),

              _HelpOption(
                icon: Icons.chat_bubble_outline,
                title: loc.whatsappSupport,
                subtitle: loc.chatWithUsInstantly,
                iconColor: OrderConstants.successColor,
                iconBackgroundColor: OrderConstants.successColor.withValues(alpha: 0.1),
                onTap: () async {
                  await HapticService.buttonClick();
                  Navigator.of(ctx).pop();
                  _launchWhatsApp(context);
                },
              ),

              SizedBox(height: ResponsiveConstants.smSpacing),

              _HelpOption(
                icon: Icons.assignment_return_outlined,
                title: loc.requestReturn,
                subtitle: loc.returnThisOrder,
                iconColor: OrderConstants.primaryColor,
                iconBackgroundColor: OrderConstants.primaryColor.withValues(alpha: 0.1),
                onTap: () async {
                  await HapticService.buttonClick();
                  Navigator.of(ctx).pop();
                  _requestReturn(context);
                },
              ),

              SizedBox(height: ResponsiveConstants.lgSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final Uri phoneUri = Uri(scheme: 'tel', path: customerServicePhone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showError(context, loc.couldNotLaunchPhoneDialer);
    }
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final message = loc.whatsappOrderHelpMessage(order.orderNumber);
      // Remove + and any spaces from phone number for WhatsApp URL
      final cleanPhoneNumber = whatsappNumber.replaceAll(RegExp(r'[\s\+\-\(\)]'), '');
      final Uri whatsappUri = Uri.parse(
        'https://wa.me/$cleanPhoneNumber?text=${Uri.encodeComponent(message)}',
      );
      
      debugPrint('📱 Launching WhatsApp: $whatsappUri');
      
      // Try to launch directly
      final launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        debugPrint('⚠️ WhatsApp launch returned false, trying platformDefault');
        // Fallback to platformDefault if externalApplication fails
        await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
      }
      
      debugPrint('✅ WhatsApp launched successfully');
    } catch (e) {
      debugPrint('❌ Error launching WhatsApp: $e');
      if (context.mounted) {
        _showError(context, loc.couldNotOpenWhatsapp);
      }
    }
  }

  Future<void> _requestReturn(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final message = loc.whatsappReturnMessage(order.orderNumber);
      // Remove + and any spaces from phone number for WhatsApp URL
      final cleanPhoneNumber = whatsappNumber.replaceAll(RegExp(r'[\s\+\-\(\)]'), '');
      final Uri whatsappUri = Uri.parse(
        'https://wa.me/$cleanPhoneNumber?text=${Uri.encodeComponent(message)}',
      );
      
      debugPrint('📱 Launching WhatsApp (Return): $whatsappUri');
      
      // Try to launch directly
      final launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        debugPrint('⚠️ WhatsApp launch returned false, trying platformDefault');
        // Fallback to platformDefault if externalApplication fails
        await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
      }
      
      debugPrint('✅ WhatsApp launched successfully');
    } catch (e) {
      debugPrint('❌ Error launching WhatsApp: $e');
      if (context.mounted) {
        _showError(context, loc.couldNotOpenWhatsapp);
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HelpOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback onTap;

  const _HelpOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
              ),
              child: Icon(icon, color: iconColor, size: 24),
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
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.xsSpacing / 2),
                  // Force phone numbers to be LTR
                  Builder(
                    builder: (context) {
                      // Check if subtitle looks like a phone number (contains + or starts with digits)
                      final isPhoneNumber = icon == Icons.phone_outlined || 
                                          subtitle.trim().startsWith('+') ||
                                          (RegExp(r'^[\d\+\-\(\)\s]+$').hasMatch(subtitle.trim()) && subtitle.trim().length >= 7);
                      if (isPhoneNumber) {
                        return Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            subtitle,
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.smFontSize,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        );
                      }
                      return Text(
                        subtitle,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.smFontSize,
                          color: Colors.grey.shade600,
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
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

