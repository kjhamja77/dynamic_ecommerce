import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/endpoints.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import '../models/address_model.dart';
import 'address_remote_data_source.dart';

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiClient api;
  AddressRemoteDataSourceImpl(this.api);

  @override
  Future<List<AddressModel>> listAddresses() async {
    try {
      debugPrint('AddressRemoteDataSourceImpl.listAddresses: Requesting addresses');
      final Response resp = await api.requestRpc(Endpoints.userAddress, params: {'action': 'list'});
      debugPrint('AddressRemoteDataSourceImpl.listAddresses: Raw response: ${resp.data}');
      final env = api.parseRpcEnvelope(resp.data);
      debugPrint('AddressRemoteDataSourceImpl.listAddresses: Parsed envelope: status=${env.status}, message=${env.message}, data=${env.data}');
      if (env.status != 'success') {
        throw Exception(env.message ?? 'Failed to fetch addresses');
      }
      final data = env.data as Map<String, dynamic>?;
      debugPrint('AddressRemoteDataSourceImpl.listAddresses: Data: $data');
      // Based on the actual API response, addresses are in data.addresses
      final list = (data?['addresses'] as List?) ?? const [];
      debugPrint('AddressRemoteDataSourceImpl.listAddresses: Raw list: $list');
      final result = list
          .cast<Map<String, dynamic>>()
          .map(_mapApiToModel)
          .toList();
      debugPrint('AddressRemoteDataSourceImpl.listAddresses: Final result: $result');
      return result;
    } catch (e, s) {
      debugPrint('AddressRemoteDataSourceImpl.listAddresses error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  Future<AddressModel> setDefaultAddressRemote(String id) async {
    try {
      final requestData = {
        'params': {
          'action': 'update',
          'address_id': int.tryParse(id),
          'default_address': true,
        }
      };
      debugPrint('AddressRemoteDataSourceImpl.setDefaultAddressRemote: Sending params: $requestData');
      // Queued raw POST (already wrapped as {params:{...}} in requestData)
      final Response resp = await api.requestRaw(
        Endpoints.userAddress,
        method: 'POST',
        data: requestData,
      );
      final env = api.parseRpcEnvelope(resp.data);
      if (env.status != 'success') {
        throw Exception(env.message ?? 'Failed to set default address');
      }
      // Re-list to get updated record
      final list = await listAddresses();
      return list.firstWhere((a) => a.id == id, orElse: () => list.isNotEmpty ? list.first : AddressModel(
        id: id,
        fullName: '',
        phone: '',
        country: '',
        city: '',
        district: '',
        street: '',
        streetNumber: '',
        building: '',
        floor: '',
        apartment: '',
        zipCode: '',
        additionalInfo: '',
        label: '',
        isDefault: true,
        createdAt: DateTime.now(),
        countryId: null,
        stateId: null,
        type: 'delivery',
      ));
    } catch (e, s) {
      debugPrint('AddressRemoteDataSourceImpl.setDefaultAddressRemote error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<AddressModel> createAddress(AddressModel address) async {
    try {
      final addressData = _toApiParams(address);
      final params = {
        'action': 'create',
        'addresses': [addressData],
      };
      debugPrint('AddressRemoteDataSourceImpl.createAddress: Sending params: $params');
      final Response resp = await api.requestRpc(Endpoints.userAddress, params: params);
      final env = api.parseRpcEnvelope(resp.data);
      if (env.status != 'success') {
        throw Exception(env.message ?? 'Failed to create address');
      }
      // Re-list to get canonical data
      final list = await listAddresses();
      return list.isNotEmpty ? list.last : address;
    } catch (e, s) {
      debugPrint('AddressRemoteDataSourceImpl.createAddress error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      final params = _toApiParams(address);
      params['action'] = 'update';
      params['address_id'] = int.tryParse(address.id);
      final Response resp = await api.requestRpc(Endpoints.userAddress, params: params);
      final env = api.parseRpcEnvelope(resp.data);
      if (env.status != 'success') {
        throw Exception(env.message ?? 'Failed to update address');
      }
      // Re-list to get updated record
      final list = await listAddresses();
      return list.firstWhere((a) => a.id == address.id, orElse: () => address);
    } catch (e, s) {
      debugPrint('AddressRemoteDataSourceImpl.updateAddress error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<bool> deleteAddress(String id) async {
    try {
      final Response resp = await api.requestRpc(Endpoints.userAddress, params: {
        'action': 'delete',
        'address_id': int.tryParse(id),
      });
      final env = api.parseRpcEnvelope(resp.data);
      if (env.status != 'success') {
        throw Exception(env.message ?? 'Failed to delete address');
      }
      return true;
    } catch (e, s) {
      debugPrint('AddressRemoteDataSourceImpl.deleteAddress error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCountryList() async {
    try {
      debugPrint('AddressRemoteDataSourceImpl.getCountryList: Requesting countries');
      debugPrint('AddressRemoteDataSourceImpl.getCountryList: Endpoint: ${Endpoints.getCountryList}');
      
      // Use POST method with empty params as per Postman collection
      final requestData = {
        'params': {}
      };
      
      final resp = await api.requestRaw(
        Endpoints.getCountryList,
        method: 'POST',
        data: requestData,
      );
      debugPrint('AddressRemoteDataSourceImpl.getCountryList: Raw response: ${resp.data}');
      
      final env = api.parseRpcEnvelope(resp.data);
      debugPrint('AddressRemoteDataSourceImpl.getCountryList: Parsed envelope: status=${env.status}, message=${env.message}, data=${env.data}');
      
      if (env.status != 'success') throw Exception(env.message ?? 'Failed to get countries');
      
      // Parse the response data
      final rawData = env.data;
      debugPrint('AddressRemoteDataSourceImpl.getCountryList: Raw data: $rawData');
      
      // Handle different response structures
      List<dynamic>? countries;
      if (rawData is Map<String, dynamic>) {
        debugPrint('AddressRemoteDataSourceImpl.getCountryList: Data keys: ${rawData.keys.toList()}');
        
        // Try different possible keys for countries list
        if (rawData.containsKey('countries')) {
          countries = rawData['countries'] as List?;
        } else if (rawData.containsKey('data') && rawData['data'] is List) {
          countries = rawData['data'] as List?;
        } else if (rawData.containsKey('result') && rawData['result'] is List) {
          countries = rawData['result'] as List?;
        }
      } else if (rawData is List) {
        // Data itself is a list of countries
        countries = rawData;
      }
      
      if (countries != null && countries.isNotEmpty) {
        debugPrint('AddressRemoteDataSourceImpl.getCountryList: Found ${countries.length} countries');
        final result = countries.cast<Map<String, dynamic>>();
        return result;
      }
      
      debugPrint('AddressRemoteDataSourceImpl.getCountryList: No countries found in response');
      return [];
    } catch (e, s) {
      debugPrint('AddressRemoteDataSourceImpl.getCountryList error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStateList(int countryId) async {
    try {
      debugPrint('AddressRemoteDataSourceImpl.getStateList: Requesting states for country $countryId');
      
      // Use POST method with params structure as per Postman collection
      final requestData = {
        'params': {
          'country_id': countryId,
        }
      };
      
      final resp = await api.requestRaw(
        Endpoints.getStateList,
        method: 'POST',
        data: requestData,
      );
      debugPrint('AddressRemoteDataSourceImpl.getStateList: Raw response: ${resp.data}');
      
      final env = api.parseRpcEnvelope(resp.data);
      debugPrint('AddressRemoteDataSourceImpl.getStateList: Parsed envelope: status=${env.status}, message=${env.message}, data=${env.data}');
      
      if (env.status != 'success') throw Exception(env.message ?? 'Failed to get states');
      
      // Parse the response data
      final rawData = env.data;
      debugPrint('AddressRemoteDataSourceImpl.getStateList: Raw data: $rawData');
      
      // Handle different response structures
      List<dynamic>? states;
      if (rawData is Map<String, dynamic>) {
        debugPrint('AddressRemoteDataSourceImpl.getStateList: Data keys: ${rawData.keys.toList()}');
        
        // Try different possible keys for states list
        if (rawData.containsKey('states')) {
          states = rawData['states'] as List?;
        } else if (rawData.containsKey('data') && rawData['data'] is List) {
          states = rawData['data'] as List?;
        } else if (rawData.containsKey('result') && rawData['result'] is List) {
          states = rawData['result'] as List?;
        }
      } else if (rawData is List) {
        // Data itself is a list of states
        states = rawData;
      }
      
      if (states != null && states.isNotEmpty) {
        debugPrint('AddressRemoteDataSourceImpl.getStateList: Found ${states.length} states');
        final result = states.cast<Map<String, dynamic>>();
        return result;
      }
      
      debugPrint('AddressRemoteDataSourceImpl.getStateList: No states found in response');
      return [];
    } catch (e, s) {
      debugPrint('AddressRemoteDataSourceImpl.getStateList error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProvinceList() async {
    try {
      debugPrint('AddressRemoteDataSourceImpl.getProvinceList: Requesting Iraqi provinces');
      debugPrint('AddressRemoteDataSourceImpl.getProvinceList: Endpoint: ${Endpoints.getProvinceList}');

      // Queued raw GET (no RPC wrapping)
      final resp = await api.requestRaw(
        Endpoints.getProvinceList,
        method: 'GET',
      );
      debugPrint('AddressRemoteDataSourceImpl.getProvinceList: Raw response: ${resp.data}');

      final body = resp.data;
      if (body is! Map<String, dynamic>) {
        debugPrint('AddressRemoteDataSourceImpl.getProvinceList: Unexpected response type');
        return [];
      }

      // Handle both direct HTTP response and potential RPC-style wrapper
      Map<String, dynamic>? envelope = body;
      if (body.containsKey('result') && body['result'] is Map<String, dynamic>) {
        envelope = body['result'] as Map<String, dynamic>;
      }

      final status = (envelope['status'] ?? '').toString();
      if (status != 'success') {
        final message = envelope['message']?.toString() ?? 'Failed to get provinces';
        throw Exception(message);
      }

      final data = envelope['data'] as Map<String, dynamic>?;
      if (data == null) {
        debugPrint('AddressRemoteDataSourceImpl.getProvinceList: No data field in response');
        return [];
      }

      final provinces = (data['provinces'] as List?) ?? const [];
      debugPrint('AddressRemoteDataSourceImpl.getProvinceList: Found ${provinces.length} provinces');
      return provinces.cast<Map<String, dynamic>>();
    } catch (e, s) {
      debugPrint('AddressRemoteDataSourceImpl.getProvinceList error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }
  // Map API shape to AddressModel (we store as strings)
  AddressModel _mapApiToModel(Map<String, dynamic> j) {
    debugPrint('AddressRemoteDataSourceImpl._mapApiToModel: Mapping address data: $j');
    debugPrint('AddressRemoteDataSourceImpl._mapApiToModel: Raw field values:');
    debugPrint('  - id: "${j['id']}"');
    debugPrint('  - name: "${j['name']}"');
    debugPrint('  - phone: "${j['phone']}"');
    debugPrint('  - street: "${j['street']}"');
    debugPrint('  - street2: "${j['street2']}"');
    debugPrint('  - city: "${j['city']}"');
    debugPrint('  - zip: "${j['zip']}"');
    debugPrint('  - state_id: "${j['state_id']}"');
    debugPrint('  - state_name: "${j['state_name']}"');
    debugPrint('  - country_id: "${j['country_id']}"');
    debugPrint('  - country_name: "${j['country_name']}"');
    debugPrint('  - default_address: "${j['default_address']}"');
    debugPrint('  - type: "${j['type']}"');
    
    // Delegate normalization of phone and country_code to AddressModel.fromApiJson
    return AddressModel.fromApiJson(j);
  }

  Map<String, dynamic> _toApiParams(AddressModel a) {
    // Ensure phone is national digits only and country_code is pure dial code (no '+').
    final phoneDigits = a.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final ccDigits = (a.phoneCountryCode ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final countryCodeForApi = ccDigits.isEmpty ? null : ccDigits;

    return {
      'name': a.fullName,
      'phone': phoneDigits,
      'country_code': countryCodeForApi,
      'street': a.street,
      'city': a.city,
      'zip': a.zipCode,
      'district': a.district,
      'street_number': a.streetNumber,
      'building': a.building,
      'floor': a.floor,
      'apartment': a.apartment,
      'additional_info': a.additionalInfo,
      // Map app \"additional notes\" to backend delivery_instruction field
      'delivery_instruction': a.additionalInfo,
      'label': a.label,
      'is_default': a.isDefault,
      'country_id': a.countryId,
      'state_id': a.stateId,
      'province_id': a.provinceId,
      'type': a.type ?? 'delivery', // Default to delivery if not specified
    };
  }
}


