import 'package:flutter/material.dart';
// removed unused GoogleFonts import
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/core/widgets/section_header.dart';
import '../../../../../core/widgets/app_loading_widget.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../core/utils/image_cache_utils.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../pages/story_detail_page.dart';
// Removed localization uses for unavailable keys

class FashionStoriesSection extends StatelessWidget {
  final String? title;
  final List<StoryData> stories;
  const FashionStoriesSection({super.key, this.title, required this.stories});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: ResponsiveConstants.smSpacing,
        bottom: ResponsiveConstants.smSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title?.isNotEmpty == true ? title! : 'Fashion Stories',
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                // Fixed dimensions for consistency across items
                const double tileWidth = 150;
                const double imageHeight = 150; // square image
                const double titleHeight = 40;   // reserves space for up to 2 lines
                return GestureDetector(
                  onTap: () => _navigateToStory(context, story),
                  child: Container(
                    width: tileWidth,
                    margin: EdgeInsets.only(right: ResponsiveConstants.mdSpacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fixed-height image for consistent cards
                        ClipRRect(
                          borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                          child: SizedBox(
                            height: imageHeight,
                            width: double.infinity,
                            child: _StoryImageLoader(imageUrl: story.imageUrl),
                          ),
                        ),
                        SizedBox(height: ResponsiveConstants.xsSpacing),
                        SizedBox(
                          height: titleHeight,
                          child: Text(
                            story.title,
                            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox.shrink(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to individual story
  void _navigateToStory(BuildContext context, StoryData story) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryDetailPage(
          title: story.title,
          imageUrl: story.imageUrl,
          htmlBody: story.htmlBody ?? '',
          subTitle: story.subHeading,
          heroTag: null,
        ),
      ),
    );
  }
}

class StoryData {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String? subHeading;
  final String? htmlBody;

  const StoryData({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    this.subHeading,
    this.htmlBody,
  });
}

class _StoryImageLoader extends StatefulWidget {
  final String imageUrl;

  const _StoryImageLoader({
    required this.imageUrl,
  });

  @override
  State<_StoryImageLoader> createState() => _StoryImageLoaderState();
}

class _StoryImageLoaderState extends State<_StoryImageLoader> {
  late final Future<Map<String, dynamic>> _imageDataFuture;

  @override
  void initState() {
    super.initState();
    // Cache the future so it doesn't recreate on rebuild
    _imageDataFuture = ImageCacheUtils.getAuthenticatedImageData(
      widget.imageUrl,
      useCacheBuster: false, // Disable cache buster to prevent reloading on scroll
    );
  }

  @override
  void didUpdateWidget(_StoryImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only recreate future if image URL actually changed
    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageDataFuture = ImageCacheUtils.getAuthenticatedImageData(
        widget.imageUrl,
        useCacheBuster: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _imageDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.grey.shade100,
            child: Center(
              child: AppLoadingWidget.small(
                message: AppLocalizations.of(context)!.loading,
                showMessage: false,
              ),
            ),
          );
        }
        final data = snapshot.data!;
        return CachedNetworkImage(
          imageUrl: data['url'] as String,
          fit: BoxFit.contain,
          httpHeaders: data['headers'] as Map<String, String>,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade100,
            child: Center(
              child: AppLoadingWidget.small(
                message: AppLocalizations.of(context)!.loading,
                showMessage: false,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade100,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey.shade400,
              size: ResponsiveConstants.lgIconSize,
            ),
          ),
        );
      },
    );
  }
}


