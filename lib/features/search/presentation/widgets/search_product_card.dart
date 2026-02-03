import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../data/models/search_product_model.dart';

class SearchProductCard extends StatelessWidget {
  final SearchProductModel product;
  final VoidCallback? onTap;

  const SearchProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(ResponsiveConstants.mdRadius),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(ResponsiveConstants.mdRadius),
                  ),
                  child: _buildProductImage(),
                ),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(ResponsiveConstants.smPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    Text(
                      product.brand,
                      style: AppFonts.getTextStyle(
                        fontSize: _getResponsiveBrandFontSize(),
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: ResponsiveConstants.xsSpacing),
                    
                    // Product Name
                    Text(
                      product.name,
                      style: AppFonts.getTextStyle(
                        fontSize: _getResponsiveProductNameFontSize(),
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: ResponsiveConstants.xsSpacing),
                    
                    // Price and Availability
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Text(
                          '${product.price.toStringAsFixed(0)} ${product.currency}',
                          style: AppFonts.getTextStyle(
                            fontSize: _getResponsivePriceFontSize(),
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        // Stock indicator
                        if (product.qtyAvailable > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveConstants.xsPadding,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.inStock,
                              style: AppFonts.getTextStyle(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveConstants.xsPadding,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.outOfStock,
                              style: AppFonts.getTextStyle(
                                fontSize: 10,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (product.primaryImageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey.shade400,
          size: ResponsiveConstants.lgIconSize,
        ),
      );
    }

    // Handle relative URLs by prepending base URL if needed
    String imageUrl = product.primaryImageUrl;
    if (imageUrl.startsWith('/web/image/')) {
      // This is a relative URL from the API, you might need to prepend your base URL
      imageUrl = '${AppConstants.baseUrl}${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}';
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: ImageCacheUtils.getAuthenticatedImageData(imageUrl),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
              ),
            ),
          );
        }
        final data = snapshot.data!;
        return CachedNetworkImage(
          imageUrl: data['url'] as String,
          fit: BoxFit.cover,
          httpHeaders: data['headers'] as Map<String, String>,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade200,
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey.shade400,
              size: ResponsiveConstants.lgIconSize,
            ),
          ),
        );
      },
    );
  }

  // Responsive helper methods
  double _getResponsiveBrandFontSize() {
    if (1.sw >= 900) return 11; // Tablet and desktop
    if (1.sw >= 600) return 10.5; // Large phones
    return 10; // Small phones
  }

  double _getResponsiveProductNameFontSize() {
    if (1.sw >= 900) return 13; // Tablet and desktop
    if (1.sw >= 600) return 12.5; // Large phones
    return 12; // Small phones
  }

  double _getResponsivePriceFontSize() {
    if (1.sw >= 900) return 14; // Tablet and desktop
    if (1.sw >= 600) return 13.5; // Large phones
    return 13; // Small phones
  }
}

