import 'package:flutter/material.dart';

import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/refund_request.dart';
import '../../domain/usecases/create_refund_request.dart';
import '../../../../l10n/app_localizations.dart';

class RefundRequestBottomSheet extends StatefulWidget {
  final Order order;

  const RefundRequestBottomSheet({super.key, required this.order});

  @override
  State<RefundRequestBottomSheet> createState() =>
      _RefundRequestBottomSheetState();
}

class _RefundRequestBottomSheetState extends State<RefundRequestBottomSheet> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: ResponsiveConstants.lgPadding,
          right: ResponsiveConstants.lgPadding,
          top: ResponsiveConstants.lgPadding,
          bottom: bottomInset +
              mediaQuery.padding.bottom +
              ResponsiveConstants.lgPadding,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    loc.requestReturn,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.lgFontSize,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Text(
              loc.returnThisOrder,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.smFontSize,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            Text(
              'Items in this order',
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.order.items.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: ResponsiveConstants.smSpacing),
                itemBuilder: (context, index) {
                  final CartItem item = widget.order.items[index];

                  return Container(
                    padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        ResponsiveConstants.mdRadius,
                      ),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.getTextStyle(
                                  fontSize: ResponsiveConstants.mdFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveConstants.xsSpacing,
                              ),
                              Text(
                                'Ordered qty: ${item.quantity}',
                                style: AppFonts.getTextStyle(
                                  fontSize: ResponsiveConstants.xsFontSize,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            Text(
              'Reason for return',
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveConstants.xsSpacing),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Please describe why you want to return these item(s).',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(ResponsiveConstants.mdRadius),
                ),
              ),
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSubmitting
                      ? colorScheme.primary.withValues(alpha: 0.7)
                      : colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor: colorScheme.surface
                      .withValues(alpha: 0.5),
                  disabledForegroundColor: colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveConstants.mdRadius,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveConstants.mdPadding,
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(
                        'Submit request',
                        style: AppFonts.getTextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;

    final String reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      AppSnackBar.error(context, 'Please enter a reason for your return.');
      return;
    }

    final int? orderId = int.tryParse(widget.order.id);
    if (orderId == null) {
      AppSnackBar.error(
        context,
        'Could not determine order ID for refund request.',
      );
      return;
    }

    final List<RefundLineInput> refundLines = <RefundLineInput>[];
    for (final CartItem item in widget.order.items) {
      final int? lineId = int.tryParse(item.id);
      final int qty = item.quantity;
      if (lineId != null && qty > 0) {
        refundLines.add(
          RefundLineInput(
            lineId: lineId,
            quantity: qty.toDouble(),
          ),
        );
      }
    }

    if (refundLines.isEmpty) {
      AppSnackBar.error(
        context,
        'No items available for refund.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final CreateRefundRequest useCase = sl<CreateRefundRequest>();
      final result = await useCase(
        CreateRefundRequestParams(
          orderId: orderId,
          refundLines: refundLines,
          reason: reason,
        ),
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _isSubmitting = false;
          });
          AppSnackBar.error(
            context,
            failure.message ??
                'Could not submit return request. Please try again.',
          );
        },
        (RefundRequest refundRequest) {
          setState(() {
            _isSubmitting = false;
          });
          Navigator.of(context).pop<RefundRequest>(refundRequest);
          AppSnackBar.success(
            context,
            loc.requestReturn,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      AppSnackBar.error(
        context,
        'Unexpected error while submitting return request: $e',
      );
    }
  }
}

