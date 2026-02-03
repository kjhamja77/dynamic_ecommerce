import '../models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> listAddresses();
  Future<AddressModel> createAddress(AddressModel address);
  Future<AddressModel> updateAddress(AddressModel address);
  Future<bool> deleteAddress(String id);
  Future<List<Map<String, dynamic>>> getCountryList();
  Future<List<Map<String, dynamic>>> getStateList(int countryId);
  Future<AddressModel> setDefaultAddressRemote(String id);
  Future<List<Map<String, dynamic>>> getProvinceList();
}


