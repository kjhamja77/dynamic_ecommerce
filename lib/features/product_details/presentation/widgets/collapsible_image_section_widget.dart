import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/product_details.dart';
import '../bloc/product_details_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/utils/image_cache_utils.dart';
import 'product_image_section_widget.dart';
import 'page_indicator_widget.dart';
import 'color_selection_widget.dart';

class CollapsibleImageSectionWidget extends StatelessWidget {
  final ProductDetails productDetails;
  final PageController pageController;
  final List<String>? variantImageUrls;
  /// When true, image + color section are not in their own scroll; they scroll with the main page.
  final bool scrollWithPage;
  /// When true, render the color selector under the image; when false, only
  /// the main image section is shown (useful when the selector is part of the
  /// product info area instead of the collapsible header).
  final bool showColorSelection;
  /// Optional callback to report the resolved image height so that the
  /// parent (e.g. ProductDetailsPage) can size the SliverAppBar header
  /// to exactly match the image height.
  final ValueChanged<double>? onHeaderHeightResolved;

  const CollapsibleImageSectionWidget({
    super.key,
    required this.productDetails,
    required this.pageController,
    this.variantImageUrls,
    this.scrollWithPage = false,
    this.showColorSelection = true,
    this.onHeaderHeightResolved,
  });

  /// Same dedupe logic as PageIndicatorWidget / ProductImageSectionWidget.
  static List<String> _dedupeImages(List<String> images) {
    final seen = <String>{};
    return images.where((url) {
      if (url.isEmpty) return false;
      return seen.add(url);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
      buildWhen: (previous, current) => true,
      builder: (context, state) {
        final currentProduct =
            state is ProductDetailsLoaded ? state.productDetails : productDetails;
        final displayImages = _dedupeImages(variantImageUrls ?? currentProduct.images);
        final showIndicator = displayImages.length > 1;

        final headerImageSection = _AdaptiveImageSection(
          firstImageUrl:
              displayImages.isNotEmpty ? displayImages.first : null,
          showIndicator: showIndicator,
          childBuilder: (
            ProductDetails product,
            PageController pc,
            List<String>? urls,
            double? aspectRatio,
          ) {
            // Decide how to fit the image based on its aspect ratio:
            // - Taller images fill the header (cover).
            // - Flatter/smaller images are centered and scaled to width.
            final double ratio = aspectRatio ?? 0.6;
            const double tallThreshold = 1.2;
            final bool isTallImage = ratio >= tallThreshold;

            final BoxFit fit = isTallImage ? BoxFit.cover : BoxFit.fitWidth;
            final Alignment alignment =
                isTallImage ? Alignment.topCenter : Alignment.center;

            return Stack(
              children: [
                ProductImageSectionWidget(
                  key: ValueKey(
                      'img_${urls?.length ?? product.images.length}_${(urls != null && urls.isNotEmpty) ? urls.first : (product.images.isNotEmpty ? product.images.first : "")}'),
                  productDetails: product,
                  pageController: pc,
                  overrideImages: urls,
                  fit: fit,
                  alignment: alignment,
                ),
                if (showIndicator)
                  PageIndicatorWidget(
                    productDetails: product,
                    pageController: pc,
                    overrideImages: urls,
                  ),
              ],
            );
          },
          productDetails: currentProduct,
          pageController: pageController,
          variantImageUrls: variantImageUrls,
          // When used inside the collapsible header (showColorSelection=false
          // in the page), we report the resolved height to the parent so
          // the SliverAppBar's expandedHeight can match it exactly.
          fillParentHeight: !showColorSelection,
          onHeightResolved: onHeaderHeightResolved,
        );

        final imageAndColor = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            headerImageSection,
            if (showColorSelection) ...[
              ColorSelectionWidget(
                productDetails: currentProduct,
                overlayOnImage: false,
              ),
              // Extra space so that the color selector is fully visible
              // above the bottom bar when used in the main scroll.
              SizedBox(height: ResponsiveConstants.lgSpacing),
            ],
          ],
        );

        // For the main product details header we only want the image section
        // itself to participate in the sliver layout. Wrapping it in an
        // additional Column can overflow when the header has tight height
        // constraints, so we return the image section directly here.
        if (scrollWithPage && !showColorSelection) {
          return headerImageSection;
        }

        if (scrollWithPage) {
          // When scrollWithPage is true we only want to render the image (and
          // optionally the color selector) with no extra reserved space. The
          // collapsible header height is controlled by SliverAppBar itself.
          return imageAndColor;
        }
        // Inside flexible space: own scroll so tall images show in full.
        return Padding(
          padding: EdgeInsets.only(top: kToolbarHeight),
          child: LayoutBuilder(
            builder: (context, c) {
              final availableHeight = c.maxHeight;
              return SizedBox(
                height: availableHeight,
                child: SingleChildScrollView(
                  child: imageAndColor,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Sizes the image section by the first image's aspect ratio so small images get a smaller area (fill width)
/// and larger images get their natural size, without extra empty space.
class _AdaptiveImageSection extends StatefulWidget {
  final String? firstImageUrl;
  final bool showIndicator;
  final Widget Function(
    ProductDetails productDetails,
    PageController pageController,
    List<String>? overrideImages,
    double? aspectRatio,
  ) childBuilder;
  final ProductDetails productDetails;
  final PageController pageController;
  final List<String>? variantImageUrls;
  /// When true, the image fills the full height made available by the parent
  /// (e.g. the SliverAppBar's expandedHeight), removing any empty space
  /// under the image inside the collapsible header.
  final bool fillParentHeight;
  /// Callback to report the resolved height (in logical pixels) of the
  /// image section after aspect ratio has been computed.
  final ValueChanged<double>? onHeightResolved;

  const _AdaptiveImageSection({
    required this.firstImageUrl,
    required this.showIndicator,
    required this.childBuilder,
    required this.productDetails,
    required this.pageController,
    this.variantImageUrls,
    this.fillParentHeight = false,
    this.onHeightResolved,
  });

  @override
  State<_AdaptiveImageSection> createState() => _AdaptiveImageSectionState();
}

class _AdaptiveImageSectionState extends State<_AdaptiveImageSection> {
  double? _aspectRatio;
  String? _lastResolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolveAspectRatio();
  }

  @override
  void didUpdateWidget(_AdaptiveImageSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firstImageUrl != widget.firstImageUrl) {
      _lastResolvedUrl = null;
      _aspectRatio = null;
      _resolveAspectRatio();
    }
  }

  /// Default ratio while loading to avoid a large placeholder that then shrinks when image loads.
  static const double _defaultLoadingRatio = 0.6;

  Future<void> _resolveAspectRatio() async {
    final url = widget.firstImageUrl;
    if (url == null || url.isEmpty) {
      if (mounted) setState(() => _aspectRatio = _defaultLoadingRatio);
      return;
    }
    if (_lastResolvedUrl == url) return;
    _lastResolvedUrl = url;
    try {
      final data = await ImageCacheUtils.getAuthenticatedImageData(url);
      final imageUrl = data['url'] as String;
      final headers = data['headers'] as Map<String, String>;
      final provider = NetworkImage(imageUrl, headers: headers);
      final completer = provider.resolve(const ImageConfiguration());
      if (!mounted) return;
      completer.addListener(ImageStreamListener((ImageInfo info, bool _) {
        if (!mounted) return;
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        if (w > 0 && h > 0) {
          setState(() => _aspectRatio = h / w);
        }
      }, onError: (dynamic exception, StackTrace? stackTrace) {
        if (mounted) setState(() => _aspectRatio = _defaultLoadingRatio);
      }));
    } catch (_) {
      if (mounted) setState(() => _aspectRatio = _defaultLoadingRatio);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder so we always respect the height constraints coming
    // from the SliverAppBar / FlexibleSpaceBar. This prevents overflow while
    // still letting us size the image based on its aspect ratio.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final mediaSize = MediaQuery.of(context).size;
        final viewportHeight = mediaSize.height;
        final maxConstraintHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : viewportHeight;

        // While loading the real aspect ratio for the header image, keep a
        // stable full-height loader so we don't show the image in a smaller
        // size and then jump to the final height.
        if (widget.fillParentHeight && _aspectRatio == null) {
          final headerHeight = maxConstraintHeight;
          if (widget.onHeightResolved != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onHeightResolved!(headerHeight);
            });
          }
          return SizedBox(
            width: width,
            height: headerHeight,
            child: const ProductImageLoader(),
          );
        }

        double height;
        if (widget.fillParentHeight) {
          // When used in the collapsible header, always fill the full
          // height provided by the SliverAppBar so there is no vertical
          // white space above or below the image.
          height = maxConstraintHeight;
        } else {
          // Target visual size for other usages is based on a
          // 1080 x 1548 design (height / width ≈ 1.433). We clamp the
          // computed aspect ratio to this target so that images do not
          // grow taller than the intended design while still supporting
          // smaller images gracefully.
          const double designAspectRatio = 1840 / 1180; // ≈ 1.433
          final rawRatio = _aspectRatio ?? _defaultLoadingRatio;
          final ratio = rawRatio.clamp(0.4, designAspectRatio);

          // Size the image based on its aspect ratio with sensible min/max
          // bounds, but never exceed the height provided by the parent when
          // not used as the collapsible header.
          final minHeight = width * 0.4;
          final maxHeightCap = viewportHeight * 1.0;
          height = (width * ratio).clamp(minHeight, maxHeightCap);
        }

        // Report the resolved height to the parent if requested so it can use
        // the same value for the SliverAppBar's expandedHeight.
        if (widget.fillParentHeight && widget.onHeightResolved != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onHeightResolved!(height);
          });
        }

        return SizedBox(
          width: width,
          height: height,
          child: widget.childBuilder(
            widget.productDetails,
            widget.pageController,
            widget.variantImageUrls,
            _aspectRatio,
          ),
        );
      },
    );
  }
}
