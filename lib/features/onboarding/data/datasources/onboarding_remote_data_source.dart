import 'package:dio/dio.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/onboarding_page_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<OnboardingPageModel>> getOnboardingPages();
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final ApiClient apiClient;

  OnboardingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OnboardingPageModel>> getOnboardingPages() async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/get/onboarding',
        method: 'POST',
        params: {},
      );

      final envelope = apiClient.parseRpcEnvelope(response.data);
      
      if (envelope.status == 'success' && envelope.data != null) {
        final data = envelope.data as Map<String, dynamic>;
        final onboardingList = data['onboarding'] as List<dynamic>;
        
        final pages = onboardingList
            .map((json) {
              final pageJson = json as Map<String, dynamic>;
              // Resolve image URL if it's a relative path
              if (pageJson['image'] != null) {
                pageJson['image'] = _resolveImageUrl(pageJson['image'].toString());
              }
              return OnboardingPageModel.fromJson(pageJson);
            })
            .toList();
        
        // Sort pages by sequence to ensure correct order
        pages.sort((a, b) => a.sequence.compareTo(b.sequence));
        return pages;
      } else {
        throw Exception('Failed to fetch onboarding pages: ${envelope.message}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Resolve image URL from relative path to full URL
  String _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) {
      return '';
    }
    
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    
    // Import the base URL from app constants and safely concatenate,
    // ensuring exactly one slash between host and path.
    const String baseUrl = AppConstants.baseUrl;

    try {
      final String cleanBase =
          baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final String cleanPath =
          trimmed.startsWith('/') ? trimmed : '/$trimmed';
      return '$cleanBase$cleanPath';
    } catch (e) {
      print('❌ OnboardingRemoteDataSource._resolveImageUrl - Error resolving URL: $e');
      return trimmed; // Return original if resolution fails
    }
  }
}


