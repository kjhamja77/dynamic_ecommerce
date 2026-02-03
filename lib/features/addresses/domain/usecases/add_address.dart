import '../repositories/address_repository.dart';
import '../entities/address.dart';

class AddAddress {
  final AddressRepository repository;
  AddAddress(this.repository);

  Future<Address> call(Address address) => repository.addAddress(address);
}
