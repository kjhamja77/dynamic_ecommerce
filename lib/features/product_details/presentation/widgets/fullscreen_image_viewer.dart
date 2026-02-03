import 'package:flutter/material.dart';
import '../../../../../core/services/haptic_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/widgets/app_loading_widget.dart';

class FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main image viewer using PhotoViewGallery
          PhotoViewGallery.builder(
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            builder: (context, index) {
              final imageUrl = widget.images[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(imageUrl),
                heroAttributes: PhotoViewHeroAttributes(tag: 'product_image_$index'),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                initialScale: PhotoViewComputedScale.contained,
              );
            },
            loadingBuilder: (context, event) => Center(
              child: AppLoadingWidget.small(
                message: 'Loading image...',
                showMessage: false,
              ),
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.h,
            right: 16.w,
            child: GestureDetector(
              onTap: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: ResponsiveConstants.mdIconSize,
                ),
              ),
            ),
          ),

          // Page indicator (only show if more than one image)
          if (widget.images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: widget.images.length,
                    effect: WormEffect(
                      dotColor: Colors.white.withValues(alpha: 0.6),
                      activeDotColor: Colors.white,
                      dotHeight: 8.h,
                      dotWidth: 8.w,
                      spacing: 8.w,
                    ),
                  ),
                ),
              ),
            ),

          // Image counter
          if (widget.images.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16.h,
              left: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveConstants.smFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Hint
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom +
                (widget.images.length > 1 ? 80.h : 32.h),
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: ResponsiveConstants.smIconSize,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Double-tap or pinch to zoom',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveConstants.xsFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
