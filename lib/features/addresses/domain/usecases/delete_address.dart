import '../repositories/address_repository.dart';

class DeleteAddress {
  final AddressRepository repository;
  DeleteAddress(this.repository);

  Future<bool> call(String id) => repository.deleteAddress(id);
}
