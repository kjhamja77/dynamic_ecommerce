import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../domain/entities/cart_item.dart';
import '../../../checkout/presentation/pages/checkout_page.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/cart_bloc.dart';
import '../../data/models/cart_response_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/navigation/navigation_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/bloc/biometric_bloc.dart';
import '../../../checkout/presentation/constants/checkout_constants.dart';

class CartSummary extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartSummary({
    super.key,
    required this.cartItems,
  });

  @override
  State<CartSummary> createState() => _CartSummaryState();
}

class _CartSummaryState extends State<CartSummary> with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkIfGuest();
  }

  Future<void> _checkIfGuest() async {
    try {
      final storage = di.sl<FlutterSecureStorage>();
      final cached = await storage.read(key: AppConstants.userKey);
      final isGuest = (cached ?? '').toLowerCase().contains('guest: true');
      if (mounted) {
        setState(() {
          _isGuest = isGuest;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        // Use API values if available, otherwise fallback to local calculations
        double subtotal, taxAmount, total;
        int totalItems;
        String currency = 'IQD';
        List<String> taxLabels = [];

        // Get cached currency from provider
        final currencyProvider = context.watch<CurrencyProvider>();
        currency = currencyProvider.currency ?? 'IQD';

        if (state is CartLoaded && state.cartResponse != null) {
          // Use exact API values but with cached currency
          subtotal = state.subtotal;
          taxAmount = state.taxAmount;
          total = state.total;
          totalItems = state.totalItems;
          
          // Build tax labels from API tax summary
          taxLabels = state.taxSummary.map((tax) => '${tax.taxName}').toList();
        } else {
          // Fallback to local calculations
          subtotal = widget.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
          taxAmount = subtotal * 0.15; // 15% VAT fallback
          total = subtotal + taxAmount;
          totalItems = widget.cartItems.fold(0, (sum, item) => sum + item.quantity);
          taxLabels = [AppLocalizations.of(context)!.vatFallback];
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveConstants.lgRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.4 : 0.1,
                ),
                blurRadius: CheckoutConstants.cardShadowBlur,
                offset: Offset(0, -CheckoutConstants.cardShadowOffset),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: ResponsiveConstants.lgPadding,
                right: ResponsiveConstants.lgPadding,
                top: ResponsiveConstants.mdPadding,
                bottom: ResponsiveConstants.lgPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header: Total + expand/collapse icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) {
                          final colorScheme = Theme.of(context).colorScheme;
                          
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.total,
                                style: AppFonts.getTextStyle(
                                  fontSize: ResponsiveConstants.mdFontSize,
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  if (state is CartUpdating)
                                    Container(
                                      height: 20,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: colorScheme.outline.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    )
                                  else
                                    Text(
                                      _formatCurrency(total, currency, currencyProvider, context),
                                      style: AppFonts.getTextStyle(
                                        fontSize: ResponsiveConstants.titleFontSize,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  SizedBox(width: ResponsiveConstants.smSpacing),
                                  GestureDetector(
                                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                                    child: AnimatedRotation(
                                      duration: const Duration(milliseconds: 200),
                                      turns: _isExpanded ? 0.5 : 0.0,
                                      child: Icon(
                                        Icons.expand_more,
                                        size: ResponsiveConstants.mdIconSize,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

                  // Expandable details
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: _isExpanded
                        ? Padding(
                            padding: EdgeInsets.only(top: ResponsiveConstants.mdSpacing),
                            child: (state is CartUpdating)
                                ? _buildSummaryShimmer(context)
                                : _buildSummaryDetails(
                              context,
                              totalItems,
                              subtotal,
                              taxAmount,
                              total,
                              taxLabels,
                              currency,
                              state,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  SizedBox(height: ResponsiveConstants.lgSpacing),
                  _buildCheckoutButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryDetails(BuildContext context, int totalItems, double subtotal, double taxAmount, double total, List<String> taxLabels, String currency, CartState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: double.infinity,
                child: _buildPriceBreakdown(context, subtotal, taxAmount, total, taxLabels, currency, state),
              ),
            ],
          );
        }
        return Align(
          alignment: Alignment.topRight,
          child: _buildPriceBreakdown(
            context,
            subtotal,
            taxAmount,
            total,
            taxLabels,
            currency,
            state,
          ),
        );
      },
    );
  }

  Widget _buildTotalItems(BuildContext context, int totalItems) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.totalItems,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.smFontSize,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          '$totalItems',
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.mdFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(BuildContext context, double subtotal, double taxAmount, double total, List<String> taxLabels, String currency, CartState state) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    List<TableRow> rows = [];

    TableRow buildRow(String label, String amount, {bool large = false}) {
      final Widget amountCell = Padding(
        padding: EdgeInsetsDirectional.only(
          bottom: ResponsiveConstants.xsSpacing,
          end: isRtl ? 0 : ResponsiveConstants.smSpacing,
          start: isRtl ? ResponsiveConstants.smSpacing : 0,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.getTextStyle(
                fontSize: large ? ResponsiveConstants.titleFontSize : ResponsiveConstants.mdFontSize,
                fontWeight: large ? FontWeight.w700 : FontWeight.w600,
                color: large 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );

      final Widget labelCell = Padding(
        padding: EdgeInsetsDirectional.only(
          bottom: ResponsiveConstants.xsSpacing,
          start: isRtl ? 0 : ResponsiveConstants.smSpacing,
          end: isRtl ? ResponsiveConstants.smSpacing : 0,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            label,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      );

      return TableRow(children: isRtl ? [labelCell, amountCell] : [amountCell, labelCell]);
    }

    rows.add(buildRow(
      AppLocalizations.of(context)!.subtotal,
      _formatCurrency(subtotal, currency, currencyProvider, context),
    ));

    if (state is CartLoaded && state.cartResponse != null && state.taxSummary.isNotEmpty) {
      for (final tax in state.taxSummary) {
        rows.add(buildRow(
          // Show only the tax name to avoid repeating the percentage many times
          tax.taxName,
          _formatCurrency(tax.totalTaxAmount, currency, currencyProvider, context),
        ));
      }
    } else {
      rows.add(buildRow(
        taxLabels.isNotEmpty ? taxLabels.first : AppLocalizations.of(context)!.tax,
        _formatCurrency(taxAmount, currency, currencyProvider, context),
      ));
    }

    rows.add(buildRow(
      AppLocalizations.of(context)!.total,
      _formatCurrency(total, currency, currencyProvider, context),
      large: true,
    ));

    return Table(
      columnWidths: isRtl
          ? const { 0: FlexColumnWidth(), 1: IntrinsicColumnWidth() }
          : const { 0: IntrinsicColumnWidth(), 1: FlexColumnWidth() },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  String _formatCurrency(double amount, String currency, dynamic currencyProvider, BuildContext context) {
    // Use the formatPrice method which handles removing .00 properly
    return currencyProvider.formatPrice(amount, locale: Localizations.localeOf(context));
  }

  Widget _buildSummaryShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _shimmerLine(width: 140),
        SizedBox(height: ResponsiveConstants.xsSpacing),
        _shimmerLine(width: 100),
        SizedBox(height: ResponsiveConstants.xsSpacing),
        _shimmerLine(width: 160),
      ],
    );
  }

  Widget _shimmerLine({double width = 120}) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 14,
            width: width,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );
      },
    );
  }
  List<Widget> _buildDetailedTaxBreakdown(BuildContext context, List<TaxSummaryModel> taxSummary, String currency, dynamic currencyProvider) {
    return taxSummary.map((tax) => Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.xsSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              '${tax.taxName} (${tax.taxRate.toStringAsFixed(0)}%)',
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.smFontSize,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Flexible(
            flex: 0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _formatCurrency(tax.totalTaxAmount, currency, currencyProvider, context),
                maxLines: 1,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildCheckoutButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showCheckoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveConstants.lgPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.proceedToCheckout,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    if (_isGuest) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogCtx) {
          final colorScheme = Theme.of(context).colorScheme;
          
          return AlertDialog(
            backgroundColor: colorScheme.surface,
            title: Text(
              AppLocalizations.of(context)!.proceedToCheckout,
              style: AppFonts.getTextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.signInForBetterExperience,
                  style: AppFonts.getTextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.guestCart,
                  style: AppFonts.getTextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: AppFonts.getTextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  context.pushAuth(
                    BlocProvider(
                      create: (context) => di.sl<BiometricBloc>(),
                      child: const LoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: Text(
                  AppLocalizations.of(context)!.signIn,
                  style: AppFonts.getTextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            AppLocalizations.of(context)!.proceedToCheckout,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.lgFontSize,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.youWillBeRedirectedToCheckout,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.mdFontSize,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: AppFonts.getTextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(cartItems: widget.cartItems),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(
                AppLocalizations.of(context)!.continueButton,
                style: AppFonts.getTextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
