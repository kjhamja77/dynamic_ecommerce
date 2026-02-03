import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/image_cache_utils.dart';

/// A widget that wraps CachedNetworkImage with automatic authentication headers
/// Use this instead of CachedNetworkImage for images from authenticated endpoints
class AuthenticatedCachedImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final bool useCacheBuster;
  final Map<String, String>? additionalHeaders;

  const AuthenticatedCachedImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
    this.useCacheBuster = false,
    this.additionalHeaders,
  });

  @override
  State<AuthenticatedCachedImage> createState() => _AuthenticatedCachedImageState();
}

class _AuthenticatedCachedImageState extends State<AuthenticatedCachedImage> {
  Map<String, String>? _headers;
  bool _isLoadingHeaders = true;

  @override
  void initState() {
    super.initState();
    _loadHeaders();
  }

  Future<void> _loadHeaders() async {
    try {
      final headers = await ImageCacheUtils.getImageHeaders();
      
      // Merge with additional headers if provided
      if (widget.additionalHeaders != null) {
        headers.addAll(widget.additionalHeaders!);
      }
      
      if (mounted) {
        setState(() {
          _headers = headers;
          _isLoadingHeaders = false;
        });
      }
    } catch (e) {
      debugPrint('AuthenticatedCachedImage: Error loading headers: $e');
      if (mounted) {
        setState(() {
          _headers = widget.additionalHeaders ?? {};
          _isLoadingHeaders = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingHeaders) {
      return widget.placeholder ?? 
        Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
    }

    return FutureBuilder<String>(
      future: _prepareImageUrl(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return widget.placeholder ?? 
            Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
        }
        
        final imageUrl = snapshot.data!;
        
        return CachedNetworkImage(
          imageUrl: imageUrl,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          httpHeaders: _headers ?? {},
          memCacheWidth: widget.memCacheWidth,
          memCacheHeight: widget.memCacheHeight,
          placeholder: (context, url) => widget.placeholder ?? 
            Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          errorWidget: (context, url, error) => widget.errorWidget ?? 
            Container(
              color: Colors.grey.shade200,
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey.shade400,
                size: 40,
              ),
            ),
        );
      },
    );
  }

  Future<String> _prepareImageUrl() async {
    String imageUrl = widget.imageUrl;
    
    // For Odoo images, add session_id to URL as query parameter (more reliable than cookies)
    if (ImageCacheUtils.requiresAuthentication(imageUrl)) {
      imageUrl = await ImageCacheUtils.addSessionIdToUrl(imageUrl);
    }
    
    if (widget.useCacheBuster) {
      imageUrl = ImageCacheUtils.addCacheBuster(imageUrl);
    }
    
    return imageUrl;
  }
}

