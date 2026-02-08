import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_details.dart';
import '../bloc/product_details_bloc.dart';
import 'product_image_section_widget.dart';
import 'color_selection_widget.dart';
import 'page_indicator_widget.dart';

class CollapsibleImageSectionWidget extends StatelessWidget {
  final ProductDetails productDetails;
  final PageController pageController;
  final List<String>? variantImageUrls;

  const CollapsibleImageSectionWidget({
    super.key,
    required this.productDetails,
    required this.pageController,
    this.variantImageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
      buildWhen: (previous, current) {
        if (current is! ProductDetailsLoaded) return false;
        if (previous is! ProductDetailsLoaded) return true;
        final prev = previous as ProductDetailsLoaded;
        final curr = current as ProductDetailsLoaded;
        // Rebuild when selection or images change so main gallery updates on color tap
        return prev.productDetails.images != curr.productDetails.images ||
            prev.productDetails.selectedColor != curr.productDetails.selectedColor;
      },
      builder: (context, state) {
        // Always use the latest product details from the bloc when available
        final currentProduct =
            state is ProductDetailsLoaded ? state.productDetails : productDetails;
        return Stack(
          children: [
            // Main Product Image (reacts to color/variant changes)
            // Key forces rebuild when images or selection change so color thumbnail tap updates gallery
            ProductImageSectionWidget(
              key: ValueKey('img_${currentProduct.selectedColor}_${currentProduct.images.length}_${currentProduct.images.isNotEmpty ? currentProduct.images.first : ""}'),
              productDetails: currentProduct,
              pageController: pageController,
              overrideImages: null,
            ),

            // Color Selection - Top left (kept in sync with state)
            ColorSelectionWidget(
              productDetails: currentProduct,
            ),

            // Page Indicator - Above images, centered
            PageIndicatorWidget(
              productDetails: currentProduct,
              pageController: pageController,
              overrideImages: null,
            ),
          ],
        );
      },
    );
  }
}
