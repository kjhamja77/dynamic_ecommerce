import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/product_details_bloc.dart';
import '../../domain/entities/product_details.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../../../l10n/app_localizations.dart';

class ColorSelectionWidget extends StatelessWidget {
  final ProductDetails productDetails;

  const ColorSelectionWidget({
    super.key,
    required this.productDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (productDetails.colorOptions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: ResponsiveConstants.mdSpacing, // Responsive positioning
      left: ResponsiveConstants.mdSpacing,
      right: ResponsiveConstants.mdSpacing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColorLabel(context),
          SizedBox(height: ResponsiveConstants.smSpacing),
          _buildColorThumbnails(context),
        ],
      ),
    );
  }

  Widget _buildColorLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Prefer the currently selected ColorOption (using localized display name),
    // fall back to matching by selectedColor string, then to the first option.
    ColorOption selectedOpt = productDetails.colorOptions
        .firstWhere((c) => c.isSelected, orElse: () => productDetails.colorOptions.first);

    // If selectedColor is set but the current option is not marked selected (edge cases),
    // try to find a ColorOption whose English or display name matches it.
    if (productDetails.selectedColor.isNotEmpty && !selectedOpt.isSelected) {
      final sel = productDetails.selectedColor.toLowerCase().trim();
      for (final c in productDetails.colorOptions) {
        final candidateNames = <String>[
          c.name.toLowerCase().trim(),
          c.displayNameOrName.toLowerCase().trim(),
        ];
        if (candidateNames.any((n) => n == sel || n.contains(sel) || sel.contains(n))) {
          selectedOpt = c;
          break;
        }
      }
    }

    final label = selectedOpt.displayNameOrName;
    
    return Text(
      '${l10n.color}: ${label.toLowerCase()}',
      style: AppFonts.getTextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
        shadows: [
          Shadow(
            offset: Offset(0, 1.h),
            blurRadius: 4.r,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.9),
          ),
          Shadow(
            offset: Offset(0, 1.h),
            blurRadius: 2.r,
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildColorThumbnails(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: productDetails.colorOptions.map((color) {
          return _buildColorThumbnail(context, color);
        }).toList(),
      ),
    );
  }

  String _firstVariantImageForColor(String colorName) {
    // Try to find the first variant that matches the color and use its image
    for (final v in productDetails.variantCombinations) {
      final bool colorMatch = v.hasAttributeValue('color', colorName) ||
                              v.hasAttributeValue('colour', colorName) ||
                              v.hasAttributeValue('اللون', colorName) ||
                              v.hasAttributeValue('color name', colorName);
      if (!colorMatch) continue;
      if (v.variantId.isNotEmpty) {
        final path = '/web/image/product.product/${v.variantId}/image_1920';
        return ImageCacheUtils.normalizeImageUrl(path);
      }
    }
    return '';
  }

  Widget _buildColorThumbnail(BuildContext context, ColorOption color) {
    // Prefer a real variant image representing this color; fallback to color images, then product images
    String thumbUrl = _firstVariantImageForColor(color.name);
    if (thumbUrl.isEmpty) {
      thumbUrl = (color.images.isNotEmpty)
          ? ImageCacheUtils.normalizeImageUrl(color.images.first)
          : (productDetails.images.isNotEmpty 
              ? ImageCacheUtils.normalizeImageUrl(productDetails.images.first) 
              : '');
    }

    final isSelected = color.isSelected;

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Ensure taps are captured even on transparent areas
      onTap: () async {
        debugPrint('🎨 ColorSelectionWidget: Tapped color "${color.displayNameOrName}" (ID: ${color.id})');
        await HapticService.buttonClick();
        context.read<ProductDetailsBloc>().add(
          SelectColorEvent(
            productId: productDetails.id,
            colorId: color.id,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: ResponsiveConstants.productDetailsColorThumbnailSpacing),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
              : Theme.of(context).colorScheme.surface,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
          child: SizedBox(
            width: ResponsiveConstants.productDetailsColorThumbnailSize,
            height: ResponsiveConstants.productDetailsColorThumbnailSize,
            child: (thumbUrl.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: thumbUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      final colorScheme = Theme.of(context).colorScheme;
                      return Container(
                        color: colorScheme.surface,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          size: 20.w,
                        ),
                      );
                    },
                  )
                : Builder(
                    builder: (context) {
                      final colorScheme = Theme.of(context).colorScheme;
                      return Container(
                        color: colorScheme.surface,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          size: 20.w,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
