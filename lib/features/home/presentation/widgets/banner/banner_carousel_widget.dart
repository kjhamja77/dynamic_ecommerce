import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../../core/constants/responsive_constants.dart';
import '../../../../../core/widgets/app_loading_widget.dart';
import '../../../domain/entities/banner.dart' as home_banner;
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../common/no_image_data_placeholder.dart';

class BannerCarouselWidget extends StatefulWidget {
  final List<home_banner.Banner> banners;
  final double height;
  final bool showIndicators;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final double viewportFraction;
  final double itemSpacing;

  const BannerCarouselWidget({
    super.key,
    required this.banners,
    this.height = 200,
    this.showIndicators = true,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.viewportFraction = 0.85,
    this.itemSpacing = 12.0,
  });

  @override
  State<BannerCarouselWidget> createState() => _BannerCarouselWidgetState();
}

class _BannerCarouselWidgetState extends State<BannerCarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
    );
    if (widget.autoPlay && widget.banners.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (_currentPage < widget.banners.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onBannerTap(home_banner.Banner banner) {
    if (banner.actionUrl != null) {
      debugPrint('Banner tapped: ${banner.title} -> ${banner.actionUrl}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return _buildBannerCard(banner);
            },
          ),
        ),
        if (widget.showIndicators && widget.banners.length > 1)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveConstants.smSpacing),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: widget.banners.length,
              effect: ExpandingDotsEffect(
                dotHeight: 6,
                dotWidth: 6,
                expansionFactor: 3,
                spacing: ResponsiveConstants.xsSpacing,
                dotColor: Colors.grey.shade400,
                activeDotColor: Colors.black,
                paintStyle: PaintingStyle.fill,
                strokeWidth: 0,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBannerCard(home_banner.Banner banner) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.itemSpacing / 2,
      ),
      child: GestureDetector(
        onTap: () async {
          await HapticService.buttonClick();
          _onBannerTap(banner);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            boxShadow: isDark
                ? const <BoxShadow>[]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            child: Stack(
              children: [
                if (banner.imageUrl.trim().isEmpty)
                  const NoImageDataPlaceholder()
                else
                  CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      // While loading, match theme (avoid bright block in dark mode)
                      return Container(
                        color: isDark
                            ? colorScheme.surface
                            : Colors.grey.shade200,
                        child: const AppLoadingWidget.small(),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return const NoImageDataPlaceholder();
                    },
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner.title,
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.lgFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveConstants.xsSpacing),
                        Text(
                          banner.description,
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.smFontSize,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (banner.actionText != null) ...[
                          SizedBox(height: ResponsiveConstants.smSpacing),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveConstants.mdPadding,
                              vertical: ResponsiveConstants.xsPadding,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                            ),
                            child: Text(
                              banner.actionText!,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.smFontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


