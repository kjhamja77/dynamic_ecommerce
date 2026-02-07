import 'package:flutter/material.dart';
import '../../../../../core/services/haptic_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../domain/entities/product_details.dart';
import 'fullscreen_image_viewer.dart';

class ProductImageSectionWidget extends StatefulWidget {
  final ProductDetails productDetails;
  final PageController pageController;
  final List<String>? overrideImages;

  const ProductImageSectionWidget({
    super.key,
    required this.productDetails,
    required this.pageController,
    this.overrideImages,
  });

  @override
  State<ProductImageSectionWidget> createState() => _ProductImageSectionWidgetState();
}

class _ProductImageSectionWidgetState extends State<ProductImageSectionWidget> {
  String? _lastSelectedColor;

  @override
  void initState() {
    super.initState();
    _lastSelectedColor = _getSelectedColorId();
  }

  @override
  void didUpdateWidget(ProductImageSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if color selection changed
    final currentSelectedColor = _getSelectedColorId();
    if (_lastSelectedColor != currentSelectedColor) {
      _lastSelectedColor = currentSelectedColor;
      // Reset to first image when color changes
      if (widget.pageController.hasClients) {
        widget.pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  String _getSelectedColorId() {
    if (widget.productDetails.colorOptions.isEmpty) {
      return 'default';
    }
    final selectedColor = widget.productDetails.colorOptions.firstWhere(
      (ColorOption color) => color.isSelected,
      orElse: () => widget.productDetails.colorOptions.first,
    );
    return selectedColor.id;
  }

  /// Images to display: always use the current product images from state (already computed by BLoC)
  List<String> get _displayImages {
    final baseImages = widget.overrideImages ?? widget.productDetails.images;
    return _dedupeImages(baseImages);
  }

  List<String> _dedupeImages(List<String> images) {
    final Set<String> seen = {};
    return images.where((url) {
      if (url.isEmpty) return false;
      final isNew = !seen.contains(url);
      if (isNew) seen.add(url);
      return isNew;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayImages = _displayImages;
    return Positioned.fill(
      child: PageView.builder(
        key: ValueKey(displayImages.isEmpty
            ? 'empty'
            : '${displayImages.length}_${displayImages.first}'),
        controller: widget.pageController,
        itemCount: displayImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              await HapticService.buttonClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FullscreenImageViewer(
                    images: displayImages,
                    initialIndex: index,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                  reverseTransitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
                child: Hero(
                tag: 'product_image_${widget.productDetails.id}',
                child: FutureBuilder<Map<String, dynamic>>(
                  future: ImageCacheUtils.getAuthenticatedImageData(displayImages[index]),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: AppLoadingWidget.small(
                          message: 'Loading image...',
                          showMessage: false,
                        ),
                      );
                    }
                    final data = snapshot.data!;
                    final imageUrl = data['url'] as String;
                    final headers = data['headers'] as Map<String, String>;
                    
                    // debugPrint('ProductImageSectionWidget → Loading image: ${imageUrl.substring(0, imageUrl.length > 100 ? 100 : imageUrl.length)}...');
                    // debugPrint('ProductImageSectionWidget → Headers: ${headers.keys.join(", ")}');
                    
                    // Test the URL first to see what response we get
                    ImageCacheUtils.testImageUrl(displayImages[index]).then((testResult) {
                      if (!testResult['success']) {
                        debugPrint('ProductImageSectionWidget → ⚠️ Image test failed: Status ${testResult['statusCode']}, Message: ${testResult['message']}');
                      }
                    });
                    
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      httpHeaders: headers,
                      placeholder: (context, url) => Center(
                        child: AppLoadingWidget.small(
                          message: 'Loading image...',
                          showMessage: false,
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        debugPrint('❌ ProductImageSectionWidget → Image load error');
                        debugPrint('   URL: $url');
                        debugPrint('   Error type: ${error.runtimeType}');
                        debugPrint('   Error: $error');
                        if (error is Exception) {
                          debugPrint('   Exception: ${error.toString()}');
                        }
                        final colorScheme = Theme.of(context).colorScheme;
                        
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                color: colorScheme.onSurface.withValues(alpha: 0.4),
                                size: ResponsiveConstants.lgIconSize,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
