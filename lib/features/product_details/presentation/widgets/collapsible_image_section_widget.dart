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

  const CollapsibleImageSectionWidget({
    super.key,
    required this.productDetails,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
      builder: (context, state) {
        // Always use the latest product details from the bloc when available
        final currentProduct =
            state is ProductDetailsLoaded ? state.productDetails : productDetails;

        return Stack(
          children: [
            // Main Product Image (reacts to color/variant changes)
            ProductImageSectionWidget(
              productDetails: currentProduct,
              pageController: pageController,
            ),

            // Color Selection - Top left (kept in sync with state)
            ColorSelectionWidget(
              productDetails: currentProduct,
            ),

            // Page Indicator - Above images, centered
            PageIndicatorWidget(
              productDetails: currentProduct,
              pageController: pageController,
            ),
          ],
        );
      },
    );
  }
}
