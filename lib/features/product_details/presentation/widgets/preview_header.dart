import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/product_details_card_preview.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/utils/image_cache_utils.dart';

/// Same threshold as main image section and _AdaptivePreviewImage:
/// tall images fill header; smaller images are centered with fitWidth.
const double _tallImageThreshold = 1.2;

/// Header that shows the catalog preview image in the same space as the final
/// product image. Uses the same adaptive logic as the main image section:
/// large/tall images fill the header; smaller images use fitWidth and are centered.
class PreviewHeader extends StatefulWidget {
  final ProductDetailsCardPreview preview;

  const PreviewHeader({super.key, required this.preview});

  @override
  State<PreviewHeader> createState() => _PreviewHeaderState();
}

class _PreviewHeaderState extends State<PreviewHeader> {
  double? _aspectRatio;
  String? _lastResolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolveAspectRatio();
  }

  @override
  void didUpdateWidget(PreviewHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preview.imageUrl != widget.preview.imageUrl) {
      _lastResolvedUrl = null;
      _aspectRatio = null;
      _resolveAspectRatio();
    }
  }

  Future<void> _resolveAspectRatio() async {
    final url = widget.preview.imageUrl;
    if (url == null || url.isEmpty) {
      if (mounted) setState(() => _aspectRatio = 0.6);
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
      }, onError: (dynamic _, StackTrace? __) {
        if (mounted) setState(() => _aspectRatio = 0.6);
      }));
    } catch (_) {
      if (mounted) setState(() => _aspectRatio = 0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final headerHeight = width * 1.4;
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.preview.imageUrl == null || widget.preview.imageUrl!.isEmpty) {
      return SizedBox(
        width: width,
        height: headerHeight,
        child: Container(
          color: colorScheme.surface,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            size: ResponsiveConstants.lgIconSize,
          ),
        ),
      );
    }

    // Same logic as main image section: big/tall = fill header, small = fitWidth + center
    final double ratio = _aspectRatio ?? 0.6;
    final bool isTallImage = ratio >= _tallImageThreshold;
    final BoxFit fit = isTallImage ? BoxFit.cover : BoxFit.fitWidth;
    final Alignment alignment =
        isTallImage ? Alignment.topCenter : Alignment.center;

    // Fill entire header with scaffold background so there is no white space
    // above/below the image when using fitWidth; matches main image section.
    return SizedBox(
      width: width,
      height: headerHeight,
      child: Container(
        width: width,
        height: headerHeight,
        color: colorScheme.background,
        child: CachedNetworkImage(
          imageUrl: widget.preview.imageUrl!,
          fit: fit,
          alignment: alignment,
          placeholder: (_, __) => Container(
            color: colorScheme.background,
            child: const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            color: colorScheme.background,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: ResponsiveConstants.lgIconSize,
            ),
          ),
        ),
      ),
    );
  }
}
