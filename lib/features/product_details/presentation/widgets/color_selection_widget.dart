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

  /// Get a thumbnail image for a color using variantCombinations.variantId
  /// and the grouped variant images (variantImagesMap) from ProductDetails.
  /// Supports both English name and Arabic displayName for matching.
  String _firstVariantImageForColor(ColorOption color) {
    String normalize(String s) => s.toLowerCase().trim();
    final List<VariantCombination> colorVariants = [];

    for (final v in productDetails.variantCombinations) {
      final variantColor = v.getAttributeValue('COLOR NAME') ??
          v.getAttributeValue('color name') ??
          v.getAttributeValue('اللون');
      if (variantColor == null || variantColor.isEmpty || v.variantId.isEmpty) continue;
      final nV = normalize(variantColor);
      final matchName = nV == normalize(color.name);
      final matchDisplay = color.displayName != null &&
          color.displayName!.isNotEmpty &&
          nV == normalize(color.displayName!);
      if (matchName || matchDisplay) {
        colorVariants.add(v);
      }
    }

    if (colorVariants.isEmpty) {
      // No variants for this color -> let caller fall back
      return '';
    }

    // Pick the variantId for this color that has the MOST images in variantImagesMap.
    String bestVariantId = colorVariants.first.variantId;
    int bestCount = -1;

    for (final v in colorVariants) {
      final String vid = v.variantId;
      final List<String> imgs =
          productDetails.variantImagesMap[vid] ?? const <String>[];
      if (imgs.length > bestCount) {
        bestCount = imgs.length;
        bestVariantId = vid;
      }
    }

    final List<String> bestImages =
        productDetails.variantImagesMap[bestVariantId] ?? const <String>[];

    if (bestImages.isNotEmpty) {
      return ImageCacheUtils.normalizeImageUrl(bestImages.first);
    }

    // Fallback: construct the standard variant image URL
    final String path = '/web/image/product.product/$bestVariantId/image_1920';
    return ImageCacheUtils.normalizeImageUrl(path);
  }

  Widget _buildColorThumbnail(BuildContext context, ColorOption color) {
    // Prefer a variant-based image (grouped by variantId), then color-level images, then product-level images.
    String thumbUrl = _firstVariantImageForColor(color);
    if (thumbUrl.isEmpty) {
      // Use images we already grouped per color in the model
      if (color.images.isNotEmpty) {
        thumbUrl = ImageCacheUtils.normalizeImageUrl(color.images.first);
      } else if (productDetails.images.isNotEmpty) {
        thumbUrl = ImageCacheUtils.normalizeImageUrl(productDetails.images.first);
      } else {
        thumbUrl = '';
      }
    }

    final isSelected = color.isSelected;
    debugPrint('product id when selecting colors ${productDetails.id}');
    debugPrint('product color id when selecting colors ${color.id}');

    // When only one color exists, no action - nothing to choose
    final hasMultipleColors = productDetails.colorOptions.length > 1;
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Ensure taps are captured even on transparent areas
      onTap: hasMultipleColors
          ? () async {
              debugPrint('🎨 ColorSelectionWidget: Tapped color "${productDetails.id}" (ID: ${color.id})');
              await HapticService.buttonClick();

              // 1) Resolve the best matching VariantCombination for this color,
        // taking into account current size/material selections when possible.
        String normalize(String s) => s.toLowerCase().trim();
        String? matchedVariantId;

        for (final v in productDetails.variantCombinations) {
          // Color must match (support both English name and Arabic displayName)
          final variantColor =
              v.getAttributeValue('COLOR NAME') ??
              v.getAttributeValue('color name') ??
              v.getAttributeValue('COLOR') ??
              v.getAttributeValue('color') ??
              v.getAttributeValue('colour') ??
              v.getAttributeValue('اللون');

          if (variantColor == null || variantColor.isEmpty) continue;
          final nV = normalize(variantColor);
          final matchesName = nV == normalize(color.name);
          final matchesDisplay = color.displayName != null &&
              color.displayName!.isNotEmpty &&
              nV == normalize(color.displayName!);
          if (!matchesName && !matchesDisplay) continue;

          // Optional: also match current selected size
          bool sizeOk = true;
          if (productDetails.selectedSize.isNotEmpty) {
            final variantSize =
                v.getAttributeValue(productDetails.primaryVariantLabel) ??
                v.getAttributeValue('SIZE') ??
                v.getAttributeValue('size');
            sizeOk = variantSize != null &&
                     normalize(variantSize) ==
                         normalize(productDetails.selectedSize);
          }

          // Optional: also match current selected material
          bool materialOk = true;
          if (productDetails.selectedMaterial != null &&
              productDetails.selectedMaterial!.isNotEmpty) {
            final variantMaterial =
                v.getAttributeValue('MATERIAL NAME') ??
                v.getAttributeValue('material name') ??
                v.getAttributeValue('MATERIAL') ??
                v.getAttributeValue('material');
            materialOk = variantMaterial != null &&
                         normalize(variantMaterial) ==
                             normalize(productDetails.selectedMaterial!);
          }

          if (sizeOk && materialOk) {
            matchedVariantId = v.variantId;
            break;
          }
        }

        // Fallback: if no strict match, pick the first variant that has this color (name or displayName)
        if (matchedVariantId == null) {
          for (final v in productDetails.variantCombinations) {
            final variantColor = v.getAttributeValue('COLOR NAME') ??
                v.getAttributeValue('color name') ??
                v.getAttributeValue('اللون');
            if (variantColor == null) continue;
            final nV = normalize(variantColor);
            if (nV == normalize(color.name) ||
                (color.displayName != null && color.displayName!.isNotEmpty && nV == normalize(color.displayName!))) {
              matchedVariantId = v.variantId;
              break;
            }
          }
          matchedVariantId ??= productDetails.variantCombinations.first.variantId;
        }

        debugPrint('🎨 ColorSelectionWidget: resolved variantId=$matchedVariantId for color="${color.displayName ?? color.name}"');

        // 1) Update color selection (availability, selectedColor, colorOptions)
        context.read<ProductDetailsBloc>().add(
          SelectColorEvent(
            productId: productDetails.id,
            colorId: color.id,
          ),
        );
        // 2) Force images/stock to this variant so they update reliably (Arabic + English).
        context.read<ProductDetailsBloc>().add(
          SelectVariantByIdEvent(matchedVariantId),
        );
      }
      : null,
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
