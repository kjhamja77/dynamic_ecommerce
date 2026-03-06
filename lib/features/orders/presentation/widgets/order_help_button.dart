import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order.dart';
import '../../core/constants/order_constants.dart';
import 'refund_request_bottom_sheet.dart';

class OrderHelpButton extends StatelessWidget {
  final Order order;

  static const String customerServicePhone = '+964 770 123 4567';
  static const String whatsappNumber = '+9647701234567';

  const OrderHelpButton({super.key, required this.order});

  /// Shows the help options bottom sheet. Use this from order details or FAB.
  static Future<void> showHelpSheet(BuildContext context, Order order) async {
    final colorScheme = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveConstants.xlRadius),
        ),
      ),
      builder: (ctx) => _OrderHelpSheetContent(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final colorScheme = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      onPressed: () async {
        await HapticService.buttonClick();
        showHelpSheet(context, order);
      },
      icon: const Icon(Icons.help_outline),
      label: Text(
        loc.needHelp,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.mdFontSize,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
      ),
      backgroundColor: OrderConstants.primaryColor,
      foregroundColor: colorScheme.onPrimary,
      elevation: 4,
    );
  }

  static Future<void> _launchPhoneStatic(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final Uri phoneUri = Uri(scheme: 'tel', path: customerServicePhone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showErrorStatic(context, loc.couldNotLaunchPhoneDialer);
    }
  }

  static Future<void> _launchWhatsAppStatic(BuildContext context, Order order) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final message = loc.whatsappOrderHelpMessage(order.orderNumber);
      final cleanPhoneNumber = whatsappNumber.replaceAll(RegExp(r'[\s\+\-\(\)]'), '');
      final Uri whatsappUri = Uri.parse(
        'https://wa.me/$cleanPhoneNumber?text=${Uri.encodeComponent(message)}',
      );
      final launched = await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorStatic(context, loc.couldNotOpenWhatsapp);
      }
    }
  }

  static Future<void> _requestReturnStatic(BuildContext context, Order order) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveConstants.xlRadius),
        ),
      ),
      builder: (ctx) => RefundRequestBottomSheet(order: order),
    );
  }

  static void _showErrorStatic(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context) async =>
      _launchPhoneStatic(context);

  Future<void> _launchWhatsApp(BuildContext context) async =>
      _launchWhatsAppStatic(context, order);

  Future<void> _requestReturn(BuildContext context) async =>
      _requestReturnStatic(context, order);

  void _showError(BuildContext context, String message) =>
      _showErrorStatic(context, message);
}

class _OrderHelpSheetContent extends StatelessWidget {
  final Order order;

  const _OrderHelpSheetContent({required this.order});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
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
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        loc.orderNumberWithValue(order.orderNumber),
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.smFontSize,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    await HapticService.buttonClick();
                    Navigator.of(context).pop();
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
              subtitle: OrderHelpButton.customerServicePhone,
              iconColor: OrderConstants.successColor,
              iconBackgroundColor: OrderConstants.successColor.withValues(alpha: 0.1),
              onTap: () async {
                await HapticService.buttonClick();
                Navigator.of(context).pop();
                OrderHelpButton._launchPhoneStatic(context);
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
                Navigator.of(context).pop();
                OrderHelpButton._launchWhatsAppStatic(context, order);
              },
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
          ],
        ),
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
  final VoidCallback? onTap;
  final bool enabled;

  const _HelpOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveOnTap = enabled ? onTap : null;
    final titleColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.5);
    final subtitleColor = enabled
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    final arrowColor = enabled
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return InkWell(
      onTap: effectiveOnTap,
      borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
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
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.xsSpacing / 2),
                  Builder(
                    builder: (context) {
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
                              color: subtitleColor,
                            ),
                          ),
                        );
                      }
                      return Text(
                        subtitle,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.smFontSize,
                          color: subtitleColor,
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
              color: arrowColor,
            ),
          ],
        ),
      ),
    );
  }
}

