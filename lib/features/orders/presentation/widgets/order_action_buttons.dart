import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/order.dart';
import '../bloc/orders_bloc.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';

class OrderActionButtons extends StatelessWidget {
  final Order order;

  const OrderActionButtons({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    // Derive button behaviour from backend order_status value instead of local enum.
    final String rawStatus = (order.orderStatus ?? '').trim();
    final String statusKey = rawStatus.toLowerCase();
    final bool isInProgress =
        statusKey == 'processing' || statusKey == 'in progress' || statusKey == 'in_progress';
    final bool canBeCancelledByStatus = statusKey == 'pending' ||
        statusKey == 'confirmed' ||
        statusKey == 'paid' ||
        statusKey == 'processing' ||
        statusKey == 'in progress' ||
        statusKey == 'in_progress';

    return Padding(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      child: Column(
        children: [
          if (order.trackingPage != null && order.trackingPage!.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await HapticService.buttonClick();
                  await _openTrackingPage(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.onSurface),
                  padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.mdPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                  ),
                ),
                child: Text(
                  loc.trackYourOrder,
                  style: AppFonts.getTextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
          ],
          if (canBeCancelledByStatus && !isInProgress) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await HapticService.buttonClick();
                  _showCancelOrderDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.error),
                  padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.mdPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                  ),
                ),
                child: Text(
                  loc.cancelOrder,
                  style: AppFonts.getTextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await HapticService.buttonClick();
                if (isInProgress) {
                  _showCancelOrderDialog(context);
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.mdPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                ),
              ),
              child: Text(
                isInProgress ? loc.cancelOrder : loc.backToOrders,
                style: AppFonts.getTextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTrackingPage(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final trackingUrl = order.trackingPage;
    
    debugPrint('🔍 Track Order - trackingUrl: $trackingUrl');
    
    if (trackingUrl == null || trackingUrl.isEmpty) {
      debugPrint('❌ Track Order - No tracking URL available');
      if (context.mounted) {
        AppSnackBar.error(context, loc.trackingUrlNotAvailable);
      }
      return;
    }

    try {
      // Ensure URL is properly formatted
      String finalUrl = trackingUrl.trim();
      if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
        finalUrl = 'https://$finalUrl';
      }

      debugPrint('🌐 Opening tracking URL: $finalUrl');
      final uri = Uri.parse(finalUrl);
      
      // Validate URI
      if (!uri.hasScheme || (!uri.hasAuthority && uri.host.isEmpty)) {
        debugPrint('❌ Invalid URL format: $finalUrl');
        if (context.mounted) {
          AppSnackBar.error(context, loc.invalidTrackingUrlFormat);
        }
        return;
      }
      
      // Try to launch the URL directly in external browser
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        debugPrint('✅ Successfully opened tracking URL: $finalUrl');
      } else {
        debugPrint('⚠️ launchUrl returned false, trying platformDefault mode');
        // If launch returned false, try with platformDefault mode as fallback
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          debugPrint('✅ Opened tracking URL with platformDefault mode');
        } catch (e) {
          debugPrint('❌ Error launching tracking URL with platformDefault: $e');
          // If still fails, show error message
          if (context.mounted) {
            AppSnackBar.error(
              context, 
              '${loc.couldNotOpenTrackingLink}. URL: $finalUrl'
            );
          }
        }
      }
    } on FormatException catch (e) {
      debugPrint('❌ Invalid URL format: $e');
      if (context.mounted) {
        AppSnackBar.error(context, loc.invalidTrackingUrlFormat);
      }
    } catch (e) {
      debugPrint('❌ Error opening tracking page: $e');
      if (context.mounted) {
        AppSnackBar.error(
          context, 
          '${loc.failedToOpenTrackingLink}: ${e.toString()}'
        );
      }
    }
  }

  void _showCancelOrderDialog(BuildContext context) {
    // Capture the context that is under the OrdersBloc provider.
    final blocContext = context;
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          loc.cancelOrder,
          style: AppFonts.getTextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          loc.cancelOrderQuestion,
          style: AppFonts.getTextStyle(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await HapticService.buttonClick();
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              loc.keepOrder,
              style: AppFonts.getTextStyle(
                color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await HapticService.buttonClick();
              Navigator.of(dialogContext).pop();
              blocContext.read<OrdersBloc>().add(CancelOrderEvent(order.id));
              Navigator.of(blocContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            child: Text(
              loc.confirmCancelOrder,
              style: AppFonts.getTextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
