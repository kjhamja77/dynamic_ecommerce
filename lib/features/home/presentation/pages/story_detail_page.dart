import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';

class StoryDetailPage extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String htmlBody;
  final String? subTitle;
  final String? heroTag;

  const StoryDetailPage({
    super.key,
    required this.title,
    required this.htmlBody,
    this.imageUrl,
    this.subTitle,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final bool hasBody = htmlBody.trim().isNotEmpty;
    final bool hasSubTitle = (subTitle != null && subTitle!.trim().isNotEmpty);
    // Debug
    // ignore: avoid_print
    print('📰 StoryDetailPage: title="$title" hasImage=$hasImage hasBody=${hasBody ? 'yes' : 'no'} hasSubTitle=${hasSubTitle ? 'yes' : 'no'}');
    if (hasBody) {
      // ignore: avoid_print
      print('📰 StoryDetailPage: html length = ${htmlBody.length}');
    }
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            pinned: true,
            expandedHeight: 280,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: colorScheme.onSurface,
                size: ResponsiveConstants.mdIconSize,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: colorScheme.onSurface,
                  size: ResponsiveConstants.mdIconSize,
                ),
                onPressed: () => Share.share(title),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  if (imageUrl != null && imageUrl!.isNotEmpty)
                    (heroTag != null
                        ? Hero(
                            tag: heroTag!,
                            child: CachedNetworkImage(
                              imageUrl: imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: colorScheme.surfaceVariant,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: colorScheme.surfaceVariant,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          )),
                  if (imageUrl == null || imageUrl!.isEmpty)
                    Container(color: colorScheme.surfaceVariant),
                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Color(0xAA000000),
                        ],
                      ),
                    ),
                  ),
                  // Title over image (and subtitle only when we have an image)
                  Positioned(
                    left: ResponsiveConstants.mdPadding,
                    right: ResponsiveConstants.mdPadding,
                    bottom: ResponsiveConstants.mdPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.titleFontSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasImage && subTitle != null && subTitle!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              subTitle!,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.mdFontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show subtitle here when there is no header image
                  if (!hasImage && hasSubTitle) ...[
                    Text(
                      subTitle!,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.smSpacing),
                  ],
                  if (hasBody || hasSubTitle) ...[
                    // Card-like container for body
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(
                              alpha: theme.brightness == Brightness.dark ? 0.5 : 0.08,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.12),
                        ),
                      ),
                      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
                      child: hasBody
                          ? Html(
                              data: htmlBody,
                              style: {
                                'body': Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                  fontSize: FontSize(16),
                                  lineHeight: LineHeight(1.6),
                                  color: colorScheme.onSurface,
                                ),
                                'p': Style(margin: Margins.symmetric(vertical: 8)),
                                'h1': Style(
                                  fontSize: FontSize(26),
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                                'h2': Style(
                                  fontSize: FontSize(22),
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                                'h3': Style(
                                  fontSize: FontSize(20),
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              },
                              shrinkWrap: true,
                            )
                          : Text(
                              subTitle!,
                              style: AppFonts.getTextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurface,
                                height: 1.6,
                              ),
                            ),
                    ),
                    SizedBox(height: ResponsiveConstants.lgSpacing),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


