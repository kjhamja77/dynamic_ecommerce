import '../repositories/address_repository.dart';
import '../entities/address.dart';

class SetDefaultAddress {
  final AddressRepository repository;
  SetDefaultAddress(this.repository);

  Future<Address> call(String id) => repository.setDefaultAddress(id);
}
