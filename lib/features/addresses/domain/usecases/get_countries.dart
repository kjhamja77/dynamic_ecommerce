import '../repositories/address_repository.dart';

class GetCountries {
  final AddressRepository repo;
  GetCountries(this.repo);
  Future<List<Map<String, dynamic>>> call() => repo.getCountryList();
}


