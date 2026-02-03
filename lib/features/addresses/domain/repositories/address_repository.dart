import '../entities/address.dart';

abstract class AddressRepository {
  Future<List<Address>> getAddresses();
  Future<Address> addAddress(Address address);
  Future<void> updateAddress(Address address);
  Future<bool> deleteAddress(String id);
  Future<Address> setDefaultAddress(String id);
  Future<List<Map<String, dynamic>>> getCountryList();
  Future<List<Map<String, dynamic>>> getStateList(int countryId);
  Future<List<Map<String, dynamic>>> getProvinceList();
}
