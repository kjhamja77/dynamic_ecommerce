import 'package:dio/dio.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import '../../../../core/constants/endpoints.dart';

class LanguageDto {
  final int id;
  final String name;
  final String code; // ar_001, en_US
  final String isoCode; // ar, en
  final String direction; // rtl, ltr

  LanguageDto({
    required this.id,
    required this.name,
    required this.code,
    required this.isoCode,
    required this.direction,
  });

  factory LanguageDto.fromJson(Map<String, dynamic> json) {
    return LanguageDto(
      id: json['id'] as int,
      name: (json['name'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      isoCode: (json['iso_code'] ?? '').toString(),
      direction: (json['direction'] ?? 'ltr').toString(),
    );
  }
}

abstract class LanguageRemoteDataSource {
  Future<List<LanguageDto>> getLanguageList();
}

class LanguageRemoteDataSourceImpl implements LanguageRemoteDataSource {
  final ApiClient apiClient;
  LanguageRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<LanguageDto>> getLanguageList() async {
    try {
      final response = await apiClient.requestRpc(
        Endpoints.getAvailableLanguage,
        method: 'GET',
      );
      final envelope = apiClient.parseRpcEnvelope(response.data);
      final root = envelope.data;
      // API shape: { status, code, success, status_code, message, data: { total_count, languages: [...] } }
      final dataNode = (root is Map) ? root['data'] : null;
      if (dataNode is Map && dataNode['languages'] is List) {
        final list = (dataNode['languages'] as List)
            .whereType<Map>()
            .map((e) => LanguageDto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return list;
      }
      return <LanguageDto>[];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch languages');
    }
  }
}


