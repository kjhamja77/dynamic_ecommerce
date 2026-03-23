import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/checkout_item.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../constants/checkout_constants.dart';

class CheckoutItemCard extends StatelessWidget {
  final CheckoutItem item;
  final VoidCallback? onRemove;

  const CheckoutItemCard({
    super.key,
    required this.item,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final product = item.cartItem.product;
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.4 : 0.08,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(context, product),
          SizedBox(width: ResponsiveConstants.mdSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full product name
                Text(
                  product.name,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                // Attributes row (size / color / brand)
                _buildAttributesRow(context, loc),
              ],
            ),
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          // Price and remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                context.read<CurrencyProvider>().formatPrice(
                      item.cartItem.totalPrice,
                      locale: Localizations.localeOf(context),
                    ),
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w700,
                  color: CheckoutConstants.primaryColor,
                ),
              ),
              if (onRemove != null) ...[
                SizedBox(height: ResponsiveConstants.xsSpacing),
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                    size: 20.w,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(BuildContext context, dynamic product) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = product.images.isNotEmpty ? product.images.first : '';
    final normalizedUrl = imageUrl.isNotEmpty
        ? ImageCacheUtils.normalizeImageUrl(imageUrl)
        : '';
    final cacheSettings = ImageCacheUtils.getOptimizedCacheSettings();

    final size = 90.w;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        child: normalizedUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: normalizedUrl,
                fit: BoxFit.cover,
                memCacheWidth: cacheSettings['memCacheWidth'] as int?,
                memCacheHeight: cacheSettings['memCacheHeight'] as int?,
                maxWidthDiskCache: cacheSettings['maxWidthDiskCache'] as int?,
                maxHeightDiskCache: cacheSettings['maxHeightDiskCache'] as int?,
                placeholder: (_, __) => Container(
                  color: colorScheme.surface,
                  child: Center(
                    child: SizedBox(
                      width: ResponsiveConstants.mdIconSize,
                      height: ResponsiveConstants.mdIconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Icon(
                  Icons.image_not_supported_outlined,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  size: ResponsiveConstants.mdIconSize,
                ),
              )
            : Icon(
                Icons.image,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                size: ResponsiveConstants.lgIconSize,
              ),
      ),
    );
  }

  Widget _buildAttributesRow(BuildContext context, AppLocalizations loc) {
    final chips = <Widget>[];
    final cartItem = item.cartItem;

    if (cartItem.selectedSize.isNotEmpty) {
      chips.add(_buildAttributeChip(
        context,
        '${loc.size}: ${cartItem.selectedSize}',
      ));
    }

    if (cartItem.selectedColor.isNotEmpty) {
      chips.add(_buildAttributeChip(
        context,
        '${loc.color}: ${cartItem.selectedColor}',
      ));
    }

    if (cartItem.product.brand.isNotEmpty) {
      chips.add(_buildAttributeChip(
        context,
        '${loc.brand}: ${cartItem.product.brand}',
      ));
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: ResponsiveConstants.xsSpacing,
      runSpacing: ResponsiveConstants.xsSpacing,
      children: chips,
    );
  }

  Widget _buildAttributeChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.xsPadding,
        vertical: ResponsiveConstants.xsPadding / 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
      ),
      child: Text(
        label,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.xsFontSize,
          color: colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
