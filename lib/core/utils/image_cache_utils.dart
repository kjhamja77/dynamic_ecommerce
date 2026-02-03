import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../services/language_service.dart';

/// Utility class for handling image cache busting and optimization
class ImageCacheUtils {
  static final Random _random = Random();
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  /// Add cache buster to image URL to force refresh
  /// This ensures that when backend images change, the app will fetch the new version
  static String addCacheBuster(String imageUrl) {
    if (imageUrl.isEmpty) return imageUrl;
    
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) return imageUrl;
    
    // Add timestamp and random number as cache buster
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(10000);
    final separator = uri.queryParameters.isNotEmpty ? '&' : '?';
    return '$imageUrl${separator}v=$timestamp&r=$random';
  }
  
  /// Add cache buster with a specific version (useful for coordinated refreshes)
  static String addCacheBusterWithVersion(String imageUrl, String version) {
    if (imageUrl.isEmpty) return imageUrl;
    
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) return imageUrl;
    
    final separator = uri.queryParameters.isNotEmpty ? '&' : '?';
    return '$imageUrl${separator}v=$version';
  }
  
  /// Clear all cached images (use sparingly as it affects performance)
  static Future<void> clearImageCache() async {
    // This would require importing the cached_network_image package
    // and calling CachedNetworkImage.evictFromCache() for all URLs
    // For now, we rely on cache busting URLs
  }

  /// Evict cached image for a specific URL (useful when URL format changes)
  /// This helps clear old cached images with bad URLs (e.g., double slashes)
  static Future<void> evictCachedImage(String imageUrl) async {
    try {
      await CachedNetworkImage.evictFromCache(imageUrl);
      debugPrint('🗑️ ImageCacheUtils: Evicted cached image: $imageUrl');
    } catch (e) {
      debugPrint('⚠️ ImageCacheUtils: Failed to evict cached image: $e');
    }
  }

  /// Evict old cached images with double slashes when we detect a normalized version
  /// This ensures old bad URLs don't interfere with new normalized URLs
  static Future<void> evictDoubleSlashVersion(String normalizedUrl) async {
    // Create the bad URL version (with double slash)
    final badUrl = normalizedUrl.replaceFirst('/web/image/', '//web/image/');
    if (badUrl != normalizedUrl) {
      await evictCachedImage(badUrl);
    }
  }
  
  /// Get optimized cache settings for CachedNetworkImage
  static Map<String, dynamic> getOptimizedCacheSettings() {
    return {
      'memCacheWidth': 300,
      'memCacheHeight': 300,
      'maxWidthDiskCache': 600,
      'maxHeightDiskCache': 600,
    };
  }
  
  /// Get HTTP headers for image requests.
  /// By default includes Authorization Bearer token (if present) and Accept-Language.
  /// Note: session_id is added to URL as query parameter, not as Cookie header
  /// Use this with CachedNetworkImage's httpHeaders parameter
  static Future<Map<String, String>> getImageHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{};
    
    // Add Authorization header if token exists
    if (includeAuth) {
      try {
        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          // debugPrint('ImageCacheUtils:getImageHeaders → added Authorization header');
        }
      } catch (e) {
        // debugPrint('ImageCacheUtils:getImageHeaders → Error reading token: $e');
      }
    }
    
    // Note: We don't add Cookie header here because:
    // 1. session_id is already in the URL as query parameter (more reliable for Odoo)
    // 2. CachedNetworkImage might not handle Cookie headers properly
    // 3. URL-based session_id is the recommended approach for Odoo images
    
    // Add Accept-Language header
    try {
      final apiLang = await LanguageService().getApiLanguageCode();
      if (apiLang != null && apiLang.isNotEmpty) {
        headers['Accept-Language'] = apiLang;
        // debugPrint('ImageCacheUtils:getImageHeaders → added Accept-Language: $apiLang');
      }
    } catch (e) {
      // debugPrint('ImageCacheUtils:getImageHeaders → Error reading language: $e');
    }
    
    // debugPrint('ImageCacheUtils:getImageHeaders → Returning ${headers.length} header(s): ${headers.keys.join(", ")}');
    return headers;
  }

  static bool _isPublicKardosiWebImage(String imageUrl) {
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) return false;
    return uri.host == 'kardosi.filesdna.com' && uri.path.startsWith('/web/image/');
  }

  /// Normalize image URL by ensuring proper base URL + path combination.
  /// Removes double slashes and handles both absolute and relative URLs.
  /// This fixes issues where URLs like "https://kardosi.filesdna.com//web/image/..." are generated.
  /// Also evicts the old bad URL from cache if it exists.
  static String normalizeImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return imageUrl;
    
    String normalized;
    
    // If already a full URL, just normalize double slashes in the path
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Replace double slashes in path (but keep // after http:)
      normalized = imageUrl.replaceAll(RegExp(r'(?<!:)//+'), '/');
    } else {
      // Relative URL - combine with base URL
      final baseUrl = AppConstants.baseUrl;
      final trimmedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final trimmedPath = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
      normalized = '$trimmedBase$trimmedPath';
    }
    
    // If the URL changed (had double slashes), evict the old bad version from cache
    if (normalized != imageUrl && imageUrl.contains('//web/image/')) {
      // Evict the old bad URL asynchronously (don't block)
      evictDoubleSlashVersion(normalized).catchError((e) {
        debugPrint('⚠️ ImageCacheUtils: Failed to evict old cached image: $e');
      });
    }
    
    return normalized;
  }

  /// Add session ID to image URL as query parameter (alternative method for Odoo)
  /// This is useful when cookies don't work or as a fallback
  static Future<String> addSessionIdToUrl(String imageUrl) async {
    if (imageUrl.isEmpty) {
      // debugPrint('ImageCacheUtils:addSessionIdToUrl → Image URL is empty');
      return imageUrl;
    }
    
    try {
      final sessionId = await _storage.read(key: AppConstants.sessionIdKey);
      if (sessionId != null && sessionId.isNotEmpty) {
        // debugPrint('ImageCacheUtils:addSessionIdToUrl → Found session_id: ${sessionId.substring(0, sessionId.length > 10 ? 10 : sessionId.length)}...');
        
        // Normalize URL to fix double slashes and ensure absolute URL
        String absoluteUrl = normalizeImageUrl(imageUrl);
        // debugPrint('ImageCacheUtils:addSessionIdToUrl → Normalized URL: $absoluteUrl');
        
        final uri = Uri.tryParse(absoluteUrl);
        if (uri != null) {
          // Check if session_id already exists in URL
          if (uri.queryParameters.containsKey('session_id')) {
            // debugPrint('ImageCacheUtils:addSessionIdToUrl → session_id already in URL, skipping');
            return absoluteUrl;
          }
          
          final queryParams = Map<String, String>.from(uri.queryParameters);
          // Uri.replace will automatically URL-encode the session_id
          queryParams['session_id'] = sessionId;
          final newUri = uri.replace(queryParameters: queryParams);
          final finalUrl = newUri.toString();
          // debugPrint('ImageCacheUtils:addSessionIdToUrl → Added session_id to URL: ${finalUrl.substring(0, finalUrl.length > 100 ? 100 : finalUrl.length)}...');
          return finalUrl;
        } else {
          // debugPrint('ImageCacheUtils:addSessionIdToUrl → Failed to parse URL: $absoluteUrl');
        }
      } else {
        // debugPrint('ImageCacheUtils:addSessionIdToUrl → No session_id found in storage');
      }
    } catch (e) {
      // debugPrint('ImageCacheUtils:addSessionIdToUrl → Error adding session_id: $e');
    }
    
    return imageUrl;
  }
  
  /// Check if an image URL requires authentication
  /// Odoo image endpoints (/web/image/...) typically require authentication
  static bool requiresAuthentication(String imageUrl) {
    if (imageUrl.isEmpty) return false;
    
    // Check if it's an Odoo image endpoint
    return imageUrl.contains('/web/image/') || 
           imageUrl.contains('bazar-iq.filesdna.com');
  }

  /// Get both authenticated URL (with session_id) and headers for image requests
  /// This is the recommended method for authenticated images
  /// Returns a map with 'url' and 'headers' keys
  /// Note: useCacheBuster defaults to false for better performance and caching.
  /// Enable it only when you explicitly need to force-refresh an image.
  static Future<Map<String, dynamic>> getAuthenticatedImageData(String imageUrl, {bool useCacheBuster = false}) async {
    if (imageUrl.isEmpty) {
      // debugPrint('ImageCacheUtils:getAuthenticatedImageData → Image URL is empty');
      return {
        'url': imageUrl,
        'headers': <String, String>{},
      };
    }
    
    // debugPrint('ImageCacheUtils:getAuthenticatedImageData → Processing URL: ${imageUrl.substring(0, imageUrl.length > 80 ? 80 : imageUrl.length)}...');
    
    // Normalize URL first to fix double slashes (this also evicts old bad URLs from cache)
    String finalUrl = normalizeImageUrl(imageUrl);

    // IMPORTANT:
    // Some deployments expose /web/image publicly (no auth needed). In that case, adding
    // session_id/auth headers can cause unexpected 403/redirects and break image loading.
    // For kardosi.filesdna.com we treat /web/image as public.
    final bool publicKardosiWebImage = _isPublicKardosiWebImage(finalUrl);
    
    // Add session_id to URL for Odoo images (more reliable than cookies)
    if (!publicKardosiWebImage && requiresAuthentication(imageUrl)) {
      // debugPrint('ImageCacheUtils:getAuthenticatedImageData → URL requires authentication');
      finalUrl = await addSessionIdToUrl(imageUrl);
    } else {
      // debugPrint('ImageCacheUtils:getAuthenticatedImageData → URL does not require authentication');
    }
    
    // Add cache buster by default for authenticated images to prevent caching failed requests
    if (useCacheBuster) {
      finalUrl = addCacheBuster(finalUrl);
      // debugPrint('ImageCacheUtils:getAuthenticatedImageData → Added cache buster');
    }
    
    // Get headers
    final headers = await getImageHeaders(includeAuth: !publicKardosiWebImage);
    // debugPrint('ImageCacheUtils:getAuthenticatedImageData → Headers count: ${headers.length}');
    // debugPrint('ImageCacheUtils:getAuthenticatedImageData → Final URL: ${finalUrl.substring(0, finalUrl.length > 120 ? 120 : finalUrl.length)}...');
    
    return {
      'url': finalUrl,
      'headers': headers,
    };
  }

  /// Test an image URL by making a direct HTTP request using Dio
  /// This is useful for debugging authentication issues
  /// Returns the HTTP status code and response info
  static Future<Map<String, dynamic>> testImageUrl(String imageUrl) async {
    try {
      final imageData = await getAuthenticatedImageData(imageUrl, useCacheBuster: true);
      final finalUrl = imageData['url'] as String;
      final headers = imageData['headers'] as Map<String, String>;
      
      // debugPrint('ImageCacheUtils:testImageUrl → Testing URL: $finalUrl');
      // debugPrint('ImageCacheUtils:testImageUrl → Headers: ${headers.keys.join(", ")}');
      
      final dio = Dio();
      final response = await dio.get(
        finalUrl,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => true, // Accept any status code
        ),
      );
      
      // debugPrint('ImageCacheUtils:testImageUrl → Status Code: ${response.statusCode}');
      // debugPrint('ImageCacheUtils:testImageUrl → Content-Type: ${response.headers.value("content-type")}');
      // debugPrint('ImageCacheUtils:testImageUrl → Content-Length: ${response.data?.length ?? 0} bytes');
      
      if (response.statusCode != 200) {
        // debugPrint('ImageCacheUtils:testImageUrl → ❌ Error: ${response.statusMessage}');
        if (response.data is List<int>) {
          final errorText = String.fromCharCodes(response.data as List<int>);
          // debugPrint('ImageCacheUtils:testImageUrl → Error body: ${errorText.substring(0, errorText.length > 200 ? 200 : errorText.length)}');
        }
      } else {
        // debugPrint('ImageCacheUtils:testImageUrl → ✅ Success! Image loaded (${response.data?.length ?? 0} bytes)');
      }
      
      return {
        'statusCode': response.statusCode,
        'success': response.statusCode == 200,
        'contentLength': response.data?.length ?? 0,
        'contentType': response.headers.value('content-type'),
        'message': response.statusMessage ?? 'Unknown',
      };
    } catch (e) {
      // debugPrint('ImageCacheUtils:testImageUrl → ❌ Exception: $e');
      return {
        'statusCode': 0,
        'success': false,
        'contentLength': 0,
        'contentType': null,
        'message': e.toString(),
      };
    }
  }
}
