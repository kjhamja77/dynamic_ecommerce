import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zalando_clone_app/core/constants/responsive_constants.dart';
import '../constants/checkout_constants.dart';
import '../../domain/entities/checkout_item.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/utils/image_cache_utils.dart';

class OrderSummarySection extends StatelessWidget {
  final List<CheckoutItem> items;
  final CheckoutSummary summary;

  const OrderSummarySection({
    super.key,
    required this.items,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shadowAlpha = theme.brightness == Brightness.dark ? 0.25 : 0.08;
    return Container(
      padding: EdgeInsets.all(CheckoutConstants.cardPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(CheckoutConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: shadowAlpha),
            blurRadius: CheckoutConstants.cardShadowBlur,
            offset: Offset(0, CheckoutConstants.cardShadowOffset),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag,
                color: CheckoutConstants.primaryColor,
                size: CheckoutConstants.iconSize,
              ),
              SizedBox(width: CheckoutConstants.smallSpacing),
              Text(
                AppLocalizations.of(context)!.orderSummary,
                style: AppFonts.getTextStyle(fontSize: CheckoutConstants.titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: CheckoutConstants.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: CheckoutConstants.itemSpacing),
          Text(
            '${AppLocalizations.of(context)!.totalItems}: ${summary.totalItems}',
            style: AppFonts.getTextStyle(fontSize: CheckoutConstants.subtitleFontSize,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          ...items.map((item) => _buildItemRow(context, item)),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          Divider(color: colorScheme.outline.withValues(alpha: 0.5)),
          SizedBox(height: CheckoutConstants.smallSpacing),
          // Summary details
          _buildSummaryRow(AppLocalizations.of(context)!.subtotal, summary.subtotal, context),
          _buildSummaryRow(AppLocalizations.of(context)!.shipping, summary.shipping, context),
          _buildSummaryRow(AppLocalizations.of(context)!.tax, summary.tax, context),
          if (summary.discount > 0)
            _buildSummaryRow(AppLocalizations.of(context)!.discount, -summary.discount, context, isDiscount: true),
          
          SizedBox(height: CheckoutConstants.smallSpacing),
          
          // Total
          Divider(color: colorScheme.outline.withValues(alpha: 0.5)),
          SizedBox(height: CheckoutConstants.smallSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.total,
                style: AppFonts.getTextStyle(fontSize: CheckoutConstants.titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: CheckoutConstants.primaryColor,
                ),
              ),
              Text(
                context.read<CurrencyProvider>().formatPrice(summary.total, locale: Localizations.localeOf(context)),
                style: AppFonts.getTextStyle(fontSize: CheckoutConstants.titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: CheckoutConstants.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, CheckoutItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
      padding: EdgeInsets.all(ResponsiveConstants.smSpacing),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: item.cartItem.product.images.isNotEmpty
                  ? _CheckoutItemImageLoader(
                      imageUrl: item.cartItem.product.images.first,
                      placeholder: Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image,
                          color: colorScheme.outline,
                          size: 24.w,
                        ),
                      ),
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image,
                        color: colorScheme.outline,
                        size: 24.w,
                      ),
                    ),
            ),
          ),
          
          SizedBox(width: ResponsiveConstants.mdSpacing),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product name - Ensure it doesn't overflow
                Text(
                  item.cartItem.product.name,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                // Variant chips (Size, Color, Brand)
                Builder(
                  builder: (context) {
                    final loc = AppLocalizations.of(context)!;
                    final variantChips = <Widget>[];
                    
                    // Add size chip if available
                    if (item.cartItem.selectedSize.isNotEmpty) {
                      variantChips.add(
                        _buildVariantChip(
                          context,
                          '${loc.size}: ${item.cartItem.selectedSize}',
                        ),
                      );
                    }
                    
                    // Add color chip if available
                    if (item.cartItem.selectedColor.isNotEmpty) {
                      variantChips.add(
                        _buildVariantChip(
                          context,
                          '${loc.color}: ${item.cartItem.selectedColor}',
                        ),
                      );
                    }
                    
                    // Add brand chip if available and not already in product name
                    if (item.cartItem.product.brand.isNotEmpty) {
                      variantChips.add(
                        _buildVariantChip(
                          context,
                          '${loc.brand}: ${item.cartItem.product.brand}',
                        ),
                      );
                    }
                    
                    if (variantChips.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return Wrap(
                      spacing: ResponsiveConstants.xsSpacing,
                      runSpacing: ResponsiveConstants.xsSpacing,
                      children: variantChips,
                    );
                  },
                ),
              ],
            ),
          ),
          
          SizedBox(width: ResponsiveConstants.mdSpacing),
          
          // Price and actions - Wrap in Flexible to prevent overflow
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.read<CurrencyProvider>().formatPrice(item.cartItem.totalPrice, locale: Localizations.localeOf(context)),
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                if (item.cartItem.product.originalPrice != null &&
                    item.cartItem.product.originalPrice! > item.cartItem.product.price)
                  Text(
                    context.read<CurrencyProvider>().formatPrice(item.cartItem.product.originalPrice!, locale: Localizations.localeOf(context)),
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                      color: colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.xsPadding + 2,
        vertical: ResponsiveConstants.xsPadding - 1,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.xsFontSize - 1,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, BuildContext context, {bool isDiscount = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${context.read<CurrencyProvider>().formatPrice(amount.abs(), locale: Localizations.localeOf(context))}',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              fontWeight: FontWeight.w500,
              color: isDiscount ? colorScheme.tertiary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version of the order summary with tighter spacing and a cleaner layout
class CompactOrderSummarySection extends StatelessWidget {
  final List<CheckoutItem> items;
  final CheckoutSummary summary;

  const CompactOrderSummarySection({
    super.key,
    required this.items,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shadowAlpha = theme.brightness == Brightness.dark ? 0.25 : 0.08;
    return Container(
      padding: EdgeInsets.all(CheckoutConstants.cardPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(CheckoutConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: shadowAlpha),
            blurRadius: CheckoutConstants.cardShadowBlur,
            offset: Offset(0, CheckoutConstants.cardShadowOffset),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: CheckoutConstants.primaryColor,
                size: CheckoutConstants.iconSize,
              ),
              SizedBox(width: CheckoutConstants.smallSpacing),
              Text(
                AppLocalizations.of(context)!.orderSummary,
                style: AppFonts.getTextStyle(fontSize: CheckoutConstants.titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: CheckoutConstants.primaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: CheckoutConstants.primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${AppLocalizations.of(context)!.totalItems}: ${summary.totalItems}',
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.xsFontSize,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: CheckoutConstants.smallSpacing),
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _compactItemRow(item),
                if (idx != items.length - 1) ...[
                  SizedBox(height: 8.h),
                  Divider(color: colorScheme.outline.withValues(alpha: 0.5)),
                  SizedBox(height: 8.h),
                ],
              ],
            );
          }),
          SizedBox(height: CheckoutConstants.smallSpacing),
          Divider(color: colorScheme.outline.withValues(alpha: 0.5)),
          SizedBox(height: CheckoutConstants.smallSpacing),
          // Summary footer (pill rows)
          _compactPillRow(AppLocalizations.of(context)!.subtotal, summary.subtotal, context),
          _compactPillRow(AppLocalizations.of(context)!.shipping, summary.shipping, context),
          _compactPillRow(AppLocalizations.of(context)!.tax, summary.tax, context),
          if (summary.discount > 0) _compactPillRow(AppLocalizations.of(context)!.discount, -summary.discount, context, isDiscount: true),

          SizedBox(height: CheckoutConstants.smallSpacing),
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.total,
                style: AppFonts.getTextStyle(fontSize: CheckoutConstants.titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: CheckoutConstants.primaryColor,
                ),
              ),
              const Spacer(),
              Text(
                context.read<CurrencyProvider>().formatPrice(summary.total, locale: Localizations.localeOf(context)),
                style: AppFonts.getTextStyle(
                  fontSize: CheckoutConstants.titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compactItemRow(CheckoutItem item) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final currencyProvider = context.read<CurrencyProvider>();
        final unitPrice = item.cartItem.price;
        final quantity = item.cartItem.quantity;
        final totalPrice = item.cartItem.totalPrice;

        return LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                    child: item.cartItem.product.images.isNotEmpty
                        ? _CheckoutItemImageLoader(
                            imageUrl: item.cartItem.product.images.first,
                            placeholder: Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            errorWidget: Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.image,
                                color: colorScheme.outline,
                                size: 24.w,
                              ),
                            ),
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image,
                              color: colorScheme.outline,
                              size: 24.w,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: ResponsiveConstants.mdSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.cartItem.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.mdFontSize,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Builder(
                        builder: (context) {
                          final loc = AppLocalizations.of(context)!;
                          final variantChips = <Widget>[];
                          if (item.cartItem.selectedSize.isNotEmpty) {
                            variantChips.add(
                              _buildCompactVariantChip(context, '${loc.size}: ${item.cartItem.selectedSize}'),
                            );
                          }
                          if (item.cartItem.selectedColor.isNotEmpty) {
                            variantChips.add(
                              _buildCompactVariantChip(context, '${loc.color}: ${item.cartItem.selectedColor}'),
                            );
                          }
                          if (item.cartItem.product.brand.isNotEmpty) {
                            variantChips.add(
                              _buildCompactVariantChip(context, '${loc.brand}: ${item.cartItem.product.brand}'),
                            );
                          }
                          if (variantChips.isEmpty) return const SizedBox.shrink();
                          return Wrap(
                            spacing: ResponsiveConstants.xsSpacing,
                            runSpacing: ResponsiveConstants.xsSpacing,
                            children: variantChips,
                          );
                        },
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveConstants.smPadding,
                                vertical: ResponsiveConstants.xsPadding,
                              ),
                              decoration: BoxDecoration(
                                color: CheckoutConstants.primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                                border: Border.all(
                                  color: CheckoutConstants.primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${AppLocalizations.of(context)!.quantity}: $quantity',
                                style: AppFonts.getTextStyle(
                                  fontSize: ResponsiveConstants.xsFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: CheckoutConstants.primaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: ResponsiveConstants.smSpacing),
                          Flexible(
                            child: Text(
                              '${currencyProvider.formatPrice(unitPrice, locale: Localizations.localeOf(context))} × $quantity',
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.xsFontSize,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveConstants.smSpacing),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 0,
                    maxWidth: constraints.maxWidth * 0.25,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currencyProvider.formatPrice(totalPrice, locale: Localizations.localeOf(context)),
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.lgFontSize,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (item.cartItem.product.originalPrice != null &&
                          item.cartItem.product.originalPrice! > item.cartItem.product.price) ...[
                        SizedBox(height: ResponsiveConstants.xsSpacing),
                        Text(
                          currencyProvider.formatPrice(
                            item.cartItem.product.originalPrice! * quantity,
                            locale: Localizations.localeOf(context),
                          ),
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.xsFontSize,
                            color: colorScheme.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                          ),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCompactVariantChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.xsPadding + 2,
        vertical: ResponsiveConstants.xsPadding - 1,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.xsFontSize - 1,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _compactPillRow(String label, double amount, BuildContext context, {bool isDiscount = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.xsFontSize,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${isDiscount ? '-' : ''}${context.read<CurrencyProvider>().formatPrice(amount.abs(), locale: Localizations.localeOf(context))}',
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              fontWeight: FontWeight.w600,
              color: isDiscount ? colorScheme.tertiary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// StatefulWidget to cache the image loading future and prevent reloading on rebuild
class _CheckoutItemImageLoader extends StatefulWidget {
  final String imageUrl;
  final Widget placeholder;
  final Widget errorWidget;

  const _CheckoutItemImageLoader({
    required this.imageUrl,
    required this.placeholder,
    required this.errorWidget,
  });

  @override
  State<_CheckoutItemImageLoader> createState() => _CheckoutItemImageLoaderState();
}

class _CheckoutItemImageLoaderState extends State<_CheckoutItemImageLoader> {
  late Future<Map<String, dynamic>> _imageDataFuture;

  @override
  void initState() {
    super.initState();
    // Cache the future so it doesn't recreate on rebuild
    _imageDataFuture = ImageCacheUtils.getAuthenticatedImageData(
      widget.imageUrl,
      useCacheBuster: false, // Disable cache buster to prevent reloading on page enter
    );
  }

  @override
  void didUpdateWidget(_CheckoutItemImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only recreate future if image URL actually changed
    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageDataFuture = ImageCacheUtils.getAuthenticatedImageData(
        widget.imageUrl,
        useCacheBuster: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _imageDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return widget.placeholder;
        }
        final data = snapshot.data!;
        return CachedNetworkImage(
          imageUrl: data['url'] as String,
          fit: BoxFit.contain,
          httpHeaders: data['headers'] as Map<String, String>,
          placeholder: (context, url) => widget.placeholder,
          errorWidget: (context, url, error) => widget.errorWidget,
        );
      },
    );
  }
}
