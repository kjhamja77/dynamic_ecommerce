import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/product_details.dart';

class PageIndicatorWidget extends StatelessWidget {
  final ProductDetails productDetails;
  final PageController pageController;
  final List<String>? overrideImages;

  const PageIndicatorWidget({
    super.key,
    required this.productDetails,
    required this.pageController,
    this.overrideImages,
  });

  /// Compute the same image list used by the PageView:
  /// we now rely on `productDetails.images`, which the BLoC keeps in sync
  /// with the currently active variant (via SelectVariantByIdEvent).
  List<String> _getDisplayImages() {
    final baseImages = overrideImages ?? productDetails.images;
    return _dedupe(baseImages);
  }

  // De-duplicate while preserving order (no URL normalization to match PageView logic)
  List<String> _dedupe(List<String> images) {
    final seen = <String>{};
    final result = <String>[];
    for (final url in images) {
      if (url.isEmpty) continue;
      if (seen.add(url)) {
        result.add(url);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Get the images to display based on selected color
    final displayImages = _getDisplayImages();

    // Only show indicator if there are multiple images
    if (displayImages.length <= 1) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: ResponsiveConstants.productDetailsPageIndicatorBottom, // Responsive positioning
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: true, // allow horizontal swipes to propagate to the PageView below
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.mdSpacing,
              vertical: ResponsiveConstants.smPadding,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
            ),
            child: SmoothPageIndicator(
              controller: pageController,
              count: displayImages.length,
              effect: WormEffect(
                dotColor: Colors.white.withOpacity(0.6),
                activeDotColor: Colors.white,
                dotHeight: ResponsiveConstants.xsDimension,
                dotWidth: ResponsiveConstants.xsDimension,
                spacing: ResponsiveConstants.smSpacing,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
