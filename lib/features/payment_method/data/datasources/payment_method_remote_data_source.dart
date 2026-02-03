import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/payment_method_model.dart';
import '../../domain/entities/payment_method.dart';

abstract class PaymentMethodRemoteDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods();
}

class PaymentMethodRemoteDataSourceImpl implements PaymentMethodRemoteDataSource {
  final ApiClient apiClient;

  PaymentMethodRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await apiClient.requestRpc(
        '/ecom/get/PaymentMethods',
        method: 'GET',
      );
      final envelope = apiClient.parseRpcEnvelope(response.data);
      final root = envelope.data;
      final listNode = (root is Map && root['payment_method'] is List)
          ? root['payment_method']
          : (root is Map && root['data'] is Map && (root['data'] as Map)['payment_method'] is List)
              ? (root['data'] as Map)['payment_method']
              : null;
      
      if (listNode is List) {
        final dtos = listNode
            .whereType<Map>()
            .map((e) => _PaymentMethodDto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        
        return dtos.map((dto) => _mapDtoToModel(dto)).toList();
      }
      
      return <PaymentMethodModel>[];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch payment methods');
    }
  }

  PaymentMethodModel _mapDtoToModel(_PaymentMethodDto dto) {
    // Infer payment type from name and URL
    final isAlQasehUrl = dto.url != null && 
        (dto.url!.toLowerCase().contains('alqaseh') || 
         dto.url!.toLowerCase().contains('/api/alqaseh'));
    
    final type = isAlQasehUrl 
        ? PaymentMethodType.alQaseh 
        : _inferPaymentType(dto.name);
    
    return PaymentMethodModel(
      id: dto.id.toString(),
      name: dto.name,
      type: type,
      isDefault: false, // Default will be set from local storage preference
      createdAt: DateTime.now(), // API doesn't provide this, use current time
    );
  }

  PaymentMethodType _inferPaymentType(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('al qaseh') || lower.contains('qaseh') || lower.contains('alqaseh')) {
      return PaymentMethodType.alQaseh;
    }
    if (lower.contains('cash')) return PaymentMethodType.cashOnDelivery;
    if (lower.contains('paypal')) return PaymentMethodType.paypal;
    if (lower.contains('apple')) return PaymentMethodType.applePay;
    if (lower.contains('google')) return PaymentMethodType.googlePay;
    if (lower.contains('card')) return PaymentMethodType.creditCard;
    if (lower.contains('wire') || lower.contains('transfer') || lower.contains('bank')) {
      return PaymentMethodType.bankTransfer;
    }
    return PaymentMethodType.bankTransfer;
  }
}

// Internal DTO class matching the API response structure
class _PaymentMethodDto {
  final int id;
  final String name;
  final int? journalId;
  final String? url;

  _PaymentMethodDto({
    required this.id,
    required this.name,
    this.journalId,
    this.url,
  });

  factory _PaymentMethodDto.fromJson(Map<String, dynamic> json) {
    // Handle journal_id: can be num, false, or null
    int? journalId;
    final journalIdValue = json['journal_id'];
    if (journalIdValue is num) {
      journalId = journalIdValue.toInt();
    } else if (journalIdValue is bool && journalIdValue == false) {
      journalId = null;
    }
    
    // Handle url: can be empty string or null
    String? url;
    final urlValue = json['url'];
    if (urlValue is String && urlValue.isNotEmpty) {
      url = urlValue;
    }
    
    return _PaymentMethodDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      journalId: journalId,
      url: url,
    );
  }
}







