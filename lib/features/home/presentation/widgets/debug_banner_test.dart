import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';

/// Debug widget to test banner image URL construction
class DebugBannerTest extends StatelessWidget {
  const DebugBannerTest({super.key});

  @override
  Widget build(BuildContext context) {
    // Test the URL construction logic
    final String testImagePath = '/web/image/bs.ecommerce.component/10/image';
    final String constructedUrl = _constructImageUrl(testImagePath);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Banner Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original Path:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(testImagePath),
            const SizedBox(height: 16),
            Text(
              'Base URL:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(AppConstants.baseUrl),
            const SizedBox(height: 16),
            Text(
              'Constructed URL:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(constructedUrl),
            const SizedBox(height: 16),
            Text(
              'Test Image:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CachedNetworkImage(
                  imageUrl: constructedUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    print('❌ Debug test error: $url - $error');
                    return Container(
                      color: Colors.red.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Error: $error',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'URL: $url',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constructs full image URL from relative path (same logic as DynamicComponentRenderer)
  String _constructImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    if (imagePath.startsWith('http')) {
      return imagePath;
    } else {
      return '${AppConstants.baseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}';
    }
  }
}


