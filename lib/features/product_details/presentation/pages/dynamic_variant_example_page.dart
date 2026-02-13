import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../domain/entities/product_details.dart';
import '../controllers/dynamic_variant_controller.dart';
import '../widgets/dynamic_variant_selector.dart';

/// Example page demonstrating the fully dynamic variant selection system
/// 
/// This page shows how to:
/// - Initialize the DynamicVariantSelector with ProductDetails
/// - Handle variant changes
/// - Display variant-specific images
/// - Show price and stock updates
/// - Disable "Add to Cart" when out of stock
class DynamicVariantExamplePage extends StatefulWidget {
  final ProductDetails productDetails;

  const DynamicVariantExamplePage({
    super.key,
    required this.productDetails,
  });

  @override
  State<DynamicVariantExamplePage> createState() => _DynamicVariantExamplePageState();
}

class _DynamicVariantExamplePageState extends State<DynamicVariantExamplePage> {
  DynamicVariantController? _currentController;
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dynamic Variant Selection',
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images Gallery
            _buildImageGallery(),

            SizedBox(height: ResponsiveConstants.mdSpacing),

            // Product Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.mdPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productDetails.brand,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.xsSpacing),
                  Text(
                    widget.productDetails.name,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.xlFontSize,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ResponsiveConstants.lgSpacing),

            // Dynamic Variant Selector
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.mdPadding,
              ),
              child: DynamicVariantSelector(
                productDetails: widget.productDetails,
                onVariantChanged: (controller) {
                  setState(() {
                    _currentController = controller;
                    _currentImageIndex = 0; // Reset to first image when variant changes
                  });
                  
                  debugPrint('🔄 Variant changed:');
                  debugPrint('   Variant ID: ${controller.variantId}');
                  debugPrint('   Price: \$${controller.currentPrice}');
                  debugPrint('   In Stock: ${controller.inStock}');
                  debugPrint('   Quantity: ${controller.quantityAvailable}');
                  debugPrint('   Images: ${controller.currentImages.length}');
                },
              ),
            ),

            SizedBox(height: ResponsiveConstants.lgSpacing),

            // Add to Cart Button
            _buildAddToCartButton(),

            SizedBox(height: ResponsiveConstants.xlSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = _currentController?.currentImages ?? widget.productDetails.images;
    
    if (images.isEmpty) {
      return Container(
        height: 400,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Main image
        SizedBox(
          height: 400,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.error, size: 64, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),

        // Image indicators
        if (images.length > 1)
          Padding(
            padding: EdgeInsets.all(ResponsiveConstants.smPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveConstants.xsSpacing / 2,
                  ),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    final isInStock = _currentController?.inStock ?? true;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isInStock
              ? () {
                  _showAddToCartSuccess();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isInStock ? colorScheme.primary : Colors.grey,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            ),
            elevation: isInStock ? 2 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isInStock ? Icons.shopping_cart : Icons.block,
                size: 24,
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Text(
                isInStock ? 'Add to Cart' : 'Out of Stock',
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddToCartSuccess() {
    if (_currentController == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added to cart: Variant ${_currentController!.variantId}',
          style: AppFonts.getTextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
