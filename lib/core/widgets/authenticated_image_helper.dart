import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../utils/image_cache_utils.dart';

/// Helper class to create authenticated CachedNetworkImage widgets
/// This ensures all images from authenticated endpoints include the Bearer token
class AuthenticatedImageHelper {
  /// Creates a CachedNetworkImage wrapped in FutureBuilder with authentication headers
  /// Use this instead of CachedNetworkImage for images from authenticated endpoints
  static Widget buildAuthenticatedImage({
    required String imageUrl,
    BoxFit? fit,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
    int? memCacheWidth,
    int? memCacheHeight,
    bool useCacheBuster = false,
  }) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _prepareImageData(imageUrl, useCacheBuster),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return placeholder ?? 
            Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
        }
        
        final data = snapshot.data!;
        final finalImageUrl = data['url'] as String;
        final headers = data['headers'] as Map<String, String>;
        
        return CachedNetworkImage(
          imageUrl: finalImageUrl,
          fit: fit,
          width: width,
          height: height,
          httpHeaders: headers,
          memCacheWidth: memCacheWidth,
          memCacheHeight: memCacheHeight,
          placeholder: (context, url) => placeholder ?? 
            Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          errorWidget: (context, url, error) => errorWidget ?? 
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

  static Future<Map<String, dynamic>> _prepareImageData(String imageUrl, bool useCacheBuster) async {
    String finalImageUrl = imageUrl;
    
    // For Odoo images, add session_id to URL as query parameter (more reliable than cookies)
    if (ImageCacheUtils.requiresAuthentication(imageUrl)) {
      finalImageUrl = await ImageCacheUtils.addSessionIdToUrl(imageUrl);
    }
    
    if (useCacheBuster) {
      finalImageUrl = ImageCacheUtils.addCacheBuster(finalImageUrl);
    }
    
    final headers = await ImageCacheUtils.getImageHeaders();
    
    return {
      'url': finalImageUrl,
      'headers': headers,
    };
  }
}

