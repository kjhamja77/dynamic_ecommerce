import '../repositories/address_repository.dart';
import '../entities/address.dart';

class GetAddresses {
  final AddressRepository repository;
  GetAddresses(this.repository);

  Future<List<Address>> call() => repository.getAddresses();
}
