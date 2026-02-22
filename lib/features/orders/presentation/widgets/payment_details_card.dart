import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/order.dart';
import '../../core/constants/order_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/api_client.dart';

class PaymentDetailsCard extends StatelessWidget {
  final Order order;

  const PaymentDetailsCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.all(ResponsiveConstants.mdPadding),
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.2 : 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isRTL) Icon(
                Icons.payment_outlined,
                color: colorScheme.onSurface,
                size: ResponsiveConstants.mdIconSize,
              ),
              if (!isRTL) SizedBox(width: ResponsiveConstants.smSpacing),
              Text(
                loc.paymentDetails,
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (isRTL) SizedBox(width: ResponsiveConstants.smSpacing),
              if (isRTL) Icon(
                Icons.payment_outlined,
                color: colorScheme.onSurface,
                size: ResponsiveConstants.mdIconSize,
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.mdSpacing),
          
          _buildInfoRow(context, loc.paymentMethod, order.paymentMethod),
          _buildInfoRow(
            context,
            loc.paymentStatus,
            OrderConstants.localizedPaymentStatus(context, order.paymentStatus),
          ),
          
          // Show invoice status if available
          if (order.invoiceStatus != null && order.invoiceStatus!.isNotEmpty) ...[
            SizedBox(height: ResponsiveConstants.smSpacing),
            _buildInfoRow(
              context,
              loc.invoiceStatus,
              order.invoiceStatus!,
            ),
          ],
          
          // Show shipping method details if available
          if (order.shippingMethod != null && order.shippingMethod!.isNotEmpty) ...[
            if (order.shippingMethod!['product_name'] != null && order.shippingMethod!['product_name'].toString().isNotEmpty) ...[
              SizedBox(height: ResponsiveConstants.smSpacing),
              _buildInfoRow(
                context,
                loc.shippingMethod,
                order.shippingMethod!['product_name'].toString(),
              ),
            ],
            if (order.shippingMethod!['price_total'] != null) ...[
              SizedBox(height: ResponsiveConstants.xsSpacing),
              _buildInfoRow(
                context,
                loc.shippingCost,
                order.shippingMethod!['price_total'].toString(),
              ),
            ],
          ],

          // Download invoice button (if invoice status is available)
          if (order.invoiceStatus != null && order.invoiceStatus!.isNotEmpty) ...[
            SizedBox(height: ResponsiveConstants.lgSpacing),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openInvoice(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveConstants.mdPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ResponsiveConstants.mdRadius),
                  ),
                  foregroundColor: OrderConstants.primaryColor,
                  side: BorderSide(color: OrderConstants.primaryColor),
                ).copyWith(
                  overlayColor: MaterialStateProperty.all(
                    OrderConstants.primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                icon: const Icon(Icons.download_outlined),
                label: Text(
                  loc.downloadInvoice,
                  style: AppFonts.getTextStyle(
                    fontWeight: FontWeight.w600,
                    color: OrderConstants.primaryColor,
                  ),
                ),
              ),
            ),
          ],
          
          if (order.paymentStatus.name == 'paid') ...[
            SizedBox(height: ResponsiveConstants.smSpacing),
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.smPadding),
              decoration: BoxDecoration(
                color: OrderConstants.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                border: Border.all(color: OrderConstants.successColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  if (!isRTL) Icon(Icons.check_circle_outline, color: OrderConstants.successColor, size: 16),
                  if (!isRTL) SizedBox(width: ResponsiveConstants.xsSpacing),
                  Text(
                    loc.paymentCompletedSuccessfully,
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                      color: OrderConstants.successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isRTL) SizedBox(width: ResponsiveConstants.xsSpacing),
                  if (isRTL) Icon(Icons.check_circle_outline, color: OrderConstants.successColor, size: 16),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.xsSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInvoice(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final orderIdInt = int.tryParse(order.id);
    if (orderIdInt == null) {
      AppSnackBar.error(context, loc.somethingWentWrong);
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // For modern Android (10+), storage permission is not needed
      // We'll save to app's external directory or use share functionality
      // Skip permission check for Android 10+ as scoped storage doesn't require it

      // Use ApiClient to make authenticated request
      final apiClient = di.sl<ApiClient>();
      final base = AppConstants.baseUrl;
      final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      final url = '$cleanBase/ecom/sale/download-invoice?order_id=$orderIdInt';

      // Make authenticated GET request to download PDF
      final response = await apiClient.requestRaw(
        url,
        method: 'GET',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      // Check if response is successful
      if (response.statusCode == 200 && response.data != null) {
        final responseBytes = response.data as List<int>;
        
        // Check if response is actually a PDF (starts with PDF magic number) or JSON error
        // PDF files start with %PDF-
        final isPdf = responseBytes.isNotEmpty && 
                      responseBytes.length >= 4 &&
                      String.fromCharCodes(responseBytes.take(4)) == '%PDF';
        
        // If not PDF, try to parse as JSON error
        if (!isPdf) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          try {
            final responseText = String.fromCharCodes(responseBytes);
            final errorJson = json.decode(responseText) as Map<String, dynamic>?;
            final errorMessage = errorJson?['message']?.toString() ?? loc.noInvoiceFoundForOrder;
            
            if (context.mounted) {
              AppSnackBar.error(context, errorMessage);
            }
            return;
          } catch (_) {
            // If not JSON, show generic error
            if (context.mounted) {
              AppSnackBar.error(context, loc.invalidInvoiceFileFormat);
            }
            return;
          }
        }

        // Save file to app's external directory (doesn't require storage permission)
        Directory? saveDirectory;
        if (Platform.isAndroid) {
          // Use external storage directory (app-specific, no permission needed)
          saveDirectory = await getExternalStorageDirectory();
        } else {
          // For iOS, use Documents directory
          saveDirectory = await getApplicationDocumentsDirectory();
        }
        
        if (saveDirectory == null) {
          if (context.mounted) {
            Navigator.of(context).pop();
            AppSnackBar.error(context, loc.couldNotAccessStorageDirectory);
          }
          return;
        }

        // Create file name
        final fileName = 'Invoice_Order_${order.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(path.join(saveDirectory.path, fileName));
        
        // Write PDF bytes to file
        await file.writeAsBytes(responseBytes);
        
        // Verify file was written successfully
        if (!await file.exists()) {
          debugPrint('❌ File was not created: ${file.path}');
          if (context.mounted) {
            Navigator.of(context).pop();
            AppSnackBar.error(context, loc.couldNotAccessStorageDirectory);
          }
          return;
        }
        
        final fileSize = await file.length();
        debugPrint('✅ Invoice saved to: ${file.path} ($fileSize bytes)');
        
        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        
        // Open the PDF file using open_file with explicit PDF type
        try {
          debugPrint('📄 Attempting to open PDF file: ${file.path}');
          final result = await OpenFile.open(
            file.path,
            type: 'application/pdf',
          );
          
          debugPrint('📄 OpenFile result: type=${result.type}, message=${result.message}');
          
          // Check result type
          if (result.type == ResultType.done) {
            debugPrint('✅ Invoice opened successfully');
            if (context.mounted) {
              AppSnackBar.success(context, loc.invoiceDownloadedAndOpened);
            }
          } else if (result.type == ResultType.noAppToOpen) {
            debugPrint('⚠️ No app found to open PDF');
            if (context.mounted) {
              AppSnackBar.error(context, loc.invoiceSavedButCouldNotOpen);
            }
          } else if (result.type == ResultType.fileNotFound) {
            debugPrint('❌ File not found: ${file.path}');
            if (context.mounted) {
              AppSnackBar.error(context, loc.invoiceSavedButCouldNotOpen);
            }
          } else if (result.type == ResultType.permissionDenied) {
            debugPrint('❌ Permission denied to open file');
            if (context.mounted) {
              AppSnackBar.error(context, loc.invoiceSavedButCouldNotOpen);
            }
          } else {
            debugPrint('⚠️ Open file returned: ${result.message}');
            // Even if not "done", try to show success as the file might have opened
            if (context.mounted) {
              AppSnackBar.success(context, loc.invoiceDownloaded);
            }
          }
        } catch (e) {
          debugPrint('❌ Error opening invoice: $e');
          if (context.mounted) {
            AppSnackBar.error(context, '${loc.failedToDownloadInvoice}: ${e.toString()}');
          }
        }
      } else {
        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        
        // Handle error response - try to parse JSON error from bytes
        try {
          final responseBytes = response.data as List<int>?;
          if (responseBytes != null && responseBytes.isNotEmpty) {
            final responseText = String.fromCharCodes(responseBytes);
            final errorJson = json.decode(responseText) as Map<String, dynamic>?;
            final errorMessage = errorJson?['message']?.toString() ?? 
                               loc.noInvoiceFoundForOrder;
            
            if (context.mounted) {
              AppSnackBar.error(context, errorMessage);
            }
            return;
          }
        } catch (_) {
          // If parsing fails, show generic error
        }
        
        debugPrint('Invoice download failed: ${response.statusCode}');
        if (context.mounted) {
          String errorMsg = loc.somethingWentWrong;
          if (response.statusCode == 401) {
            errorMsg = loc.authenticationRequiredPleaseLogin;
          } else if (response.statusCode == 404) {
            errorMsg = loc.noInvoiceFoundForOrder;
          }
          AppSnackBar.error(context, errorMsg);
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
        AppSnackBar.error(context, '${loc.failedToDownloadInvoice}: ${e.toString()}');
      }
      debugPrint('Error downloading invoice: $e');
    }
  }
}
