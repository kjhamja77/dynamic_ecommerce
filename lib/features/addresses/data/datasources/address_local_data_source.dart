import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address_model.dart';

abstract class AddressLocalDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> addAddress(AddressModel address);
  Future<AddressModel> updateAddress(AddressModel address);
  Future<bool> deleteAddress(String id);
  Future<AddressModel> setDefaultAddress(String id);

  /// Clear all stored addresses. Used on logout so the next user does not see the previous user's addresses.
  Future<void> clearAll();
}

class AddressLocalDataSourceImpl implements AddressLocalDataSource {
  final SharedPreferences prefs;
  static const String _key = 'addresses_v1';

  AddressLocalDataSourceImpl(this.prefs);

  @override
  Future<List<AddressModel>> getAddresses() async {
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) return [];
    final List list = json.decode(jsonString) as List;
    return list.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    final list = await getAddresses();
    // Only make first address default if no default exists
    // Otherwise, preserve the isDefault flag from the address being added
    final bool hasDefault = list.any((a) => a.isDefault);
    final AddressModel toSave = list.isEmpty
        ? AddressModel.fromEntity(address.copyWith(isDefault: true))
        : (hasDefault && address.isDefault
            ? AddressModel.fromEntity(address.copyWith(isDefault: false))
            : address);
    list.add(toSave);
    await _save(list);
    return toSave;
  }

  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    final list = await getAddresses();
    final idx = list.indexWhere((a) => a.id == address.id);
    if (idx == -1) throw Exception('Address not found');
    
    // Preserve the default status if this was the default address
    final wasDefault = list[idx].isDefault;
    final updatedAddress = wasDefault ? address : address.copyWith(isDefault: false);
    
    list[idx] = updatedAddress;
    await _save(list);
    return updatedAddress;
  }

  @override
  Future<bool> deleteAddress(String id) async {
    final list = await getAddresses();
    final wasDefault = list.any((a) => a.id == id && a.isDefault);
    list.removeWhere((a) => a.id == id);
    if (wasDefault && list.isNotEmpty) {
      list[0] = AddressModel.fromEntity(list[0].copyWith(isDefault: true));
    }
    await _save(list);
    return true;
  }

  @override
  Future<AddressModel> setDefaultAddress(String id) async {
    final list = await getAddresses();
    for (int i = 0; i < list.length; i++) {
      list[i] = AddressModel.fromEntity(list[i].copyWith(isDefault: false));
    }
    final idx = list.indexWhere((a) => a.id == id);
    if (idx == -1) throw Exception('Address not found');
    list[idx] = AddressModel.fromEntity(list[idx].copyWith(isDefault: true));
    await _save(list);
    return list[idx];
  }

  @override
  Future<void> clearAll() async {
    await _save([]);
  }

  Future<void> _save(List<AddressModel> list) async {
    final jsonString = json.encode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}
