import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../core/constants/order_constants.dart';
import '../../domain/entities/refund_request.dart';
import '../../domain/usecases/get_refund_request_details.dart';
import '../../domain/usecases/cancel_refund_request.dart';
import '../bloc/refund_requests_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;

class RefundRequestDetailsPage extends StatefulWidget {
  final RefundRequest refundRequest;

  const RefundRequestDetailsPage({
    super.key,
    required this.refundRequest,
  });

  @override
  State<RefundRequestDetailsPage> createState() =>
      _RefundRequestDetailsPageState();
}

class _RefundRequestDetailsPageState extends State<RefundRequestDetailsPage> {
  late Future<RefundRequest> _detailsFuture;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<RefundRequest> _loadDetails() async {
    final useCase = di.sl<GetRefundRequestDetails>();
    final result = await useCase(
      GetRefundRequestDetailsParams(widget.refundRequest.id),
    );
    return result.fold(
      (failure) => widget.refundRequest,
      (details) => details,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          loc.returns,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: FutureBuilder<RefundRequest>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final refund = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: _buildContent(context, refund),
              ),
              _buildCancelButton(context, refund),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, RefundRequest refund) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final currency = context.watch<CurrencyProvider>();
    final locale = Localizations.localeOf(context);
    final isPending =
        refund.state.toLowerCase() == 'pending' ||
        refund.stateDisplay?.toLowerCase().contains('pending') == true;
    final Color statusChipColor =
        isPending ? OrderConstants.primaryColorLight : OrderConstants.successColor;

    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card with orange hero header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius:
                  BorderRadius.circular(ResponsiveConstants.mdRadius),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(
                    alpha:
                        theme.brightness == Brightness.dark ? 0.3 : 0.08,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Orange hero header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        OrderConstants.primaryColor,
                        OrderConstants.primaryColorDark,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        ResponsiveConstants.mdRadius,
                      ),
                      topRight: Radius.circular(
                        ResponsiveConstants.mdRadius,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveConstants.xsPadding,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveConstants.smRadius,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.assignment_return_outlined,
                                        size: 12,
                                        color: colorScheme.onPrimary,
                                      ),
                                      SizedBox(
                                        width: ResponsiveConstants.xsSpacing,
                                      ),
                                      Text(
                                        loc.returns,
                                        style: AppFonts.getTextStyle(
                                          fontSize:
                                              ResponsiveConstants.xsFontSize,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: ResponsiveConstants.xsSpacing,
                            ),
                            Text(
                              loc.orderNumberWithValue(refund.orderName),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.mdFontSize,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveConstants.xsSpacing,
                            ),
                            Text(
                              refund.number,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.xsFontSize,
                                color: colorScheme.onPrimary
                                    .withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveConstants.smPadding,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusChipColor,
                              borderRadius: BorderRadius.circular(
                                ResponsiveConstants.smRadius,
                              ),
                            ),
                            child: Text(
                              refund.stateDisplay?.isNotEmpty == true
                                  ? refund.stateDisplay!
                                  : refund.state,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.xsFontSize,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          SizedBox(height: ResponsiveConstants.xsSpacing),
                          Text(
                            currency.formatPrice(
                              refund.totalRequestedAmount,
                              locale: locale,
                            ),
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.smFontSize,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Body
                Padding(
                  padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reason',
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.smFontSize,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Text(
                        refund.reason,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.smFontSize,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.mdSpacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.totalAmount,
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.smFontSize,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            currency.formatPrice(
                              refund.totalRequestedAmount,
                              locale: locale,
                            ),
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.smFontSize,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveConstants.lgSpacing),

          // Items
          if (refund.lines.isNotEmpty) ...[
            Text(
              loc.orderItemsTitle,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            ...refund.lines.map(
              (line) => _RefundLineTile(line: line),
            ),
          ],
          SizedBox(height: ResponsiveConstants.lgSpacing),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, RefundRequest refund) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPending = refund.state.toLowerCase() == 'pending';

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ResponsiveConstants.mdPadding,
          0,
          ResponsiveConstants.mdPadding,
          ResponsiveConstants.mdPadding,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isPending && !_isCancelling
                ? () => _showCancelRefundDialog(context, refund)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPending
                  ? OrderConstants.primaryColor
                  : colorScheme.surfaceContainerHighest,
              foregroundColor:
                  isPending ? colorScheme.onPrimary : colorScheme.onSurface,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveConstants.mdPadding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ResponsiveConstants.mdRadius),
              ),
            ),
            child: Text(
              'Cancel request',
              style: AppFonts.getTextStyle(
                fontWeight: FontWeight.w600,
                color: isPending
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelRefundDialog(
    BuildContext context,
    RefundRequest refund,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Cancel return request',
            style: AppFonts.getTextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel this return request?',
            style: AppFonts.getTextStyle(
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Keep request',
                style: AppFonts.getTextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _cancelRefundRequest(refund);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: Text(
                'Cancel request',
                style: AppFonts.getTextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelRefundRequest(RefundRequest refund) async {
    if (!mounted) return;
    setState(() {
      _isCancelling = true;
    });

    try {
      final useCase = di.sl<CancelRefundRequest>();
      final result =
          await useCase(CancelRefundRequestParams(refund.id));

      if (!mounted) return;

      result.fold(
        (failure) {
          AppSnackBar.error(
            context,
            failure.message ??
                'Could not cancel return request. Please try again.',
          );
        },
        (_) {
          // Refresh refund list in My Orders if bloc is available
          try {
            final bloc = context.read<RefundRequestsBloc>();
            bloc.add(const RefreshRefundRequests());
          } catch (_) {
            // Bloc may not be in the tree; ignore if so.
          }

          AppSnackBar.success(
            context,
            'Return request cancelled successfully.',
          );

          Navigator.of(context).pop(); // Close details page
        },
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        'Unexpected error while cancelling request: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }
}

class _RefundLineTile extends StatelessWidget {
  final RefundLine line;

  const _RefundLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currency = context.watch<CurrencyProvider>();
    final locale = Localizations.localeOf(context);

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        // border: Border.all(
        //   color: colorScheme.outline.withValues(alpha: 0.2),
        // ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius:
                  BorderRadius.circular(ResponsiveConstants.smRadius),
            ),
            child: line.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(
                      ResponsiveConstants.smRadius,
                    ),
                    child: Image.network(
                      line.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.image_not_supported_outlined,
                    color: colorScheme.outline,
                  ),
          ),
          SizedBox(width: ResponsiveConstants.mdSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.smFontSize,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.smSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: ${line.refundQty} / ${line.orderedQty}',
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.xsFontSize,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      currency.formatPrice(
                        line.subtotal,
                        locale: locale,
                      ),
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.smFontSize,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

