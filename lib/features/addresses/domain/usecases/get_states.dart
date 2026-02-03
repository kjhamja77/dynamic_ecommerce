import '../repositories/address_repository.dart';

class GetStates {
  final AddressRepository repo;
  GetStates(this.repo);
  Future<List<Map<String, dynamic>>> call(int countryId) => repo.getStateList(countryId);
}


