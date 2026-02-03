import '../../../../core/network/api_client.dart';
import '../models/terms_conditions_model.dart';

abstract class TermsConditionsRemoteDataSource {
  Future<TermsConditionsResponseModel> getTermsConditions();
}

class TermsConditionsRemoteDataSourceImpl implements TermsConditionsRemoteDataSource {
  final ApiClient apiClient;

  TermsConditionsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TermsConditionsResponseModel> getTermsConditions() async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/get/terms-conditions',
        method: 'GET',
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        
        if (responseData['status'] == 'success' && responseData['success'] == 1) {
          return TermsConditionsResponseModel.fromJson(responseData['data']);
        } else {
          throw Exception('API returned error: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load terms and conditions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching terms and conditions: $e');
    }
  }
}
