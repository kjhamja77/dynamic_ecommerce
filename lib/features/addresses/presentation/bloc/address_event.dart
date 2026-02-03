import '../../domain/entities/address.dart';

abstract class AddressEvent {
  const AddressEvent();
}

class LoadAddresses extends AddressEvent {
  const LoadAddresses();
}

class AddNewAddress extends AddressEvent {
  final Address address;
  const AddNewAddress(this.address);
}

class UpdateAddressEvent extends AddressEvent {
  final Address address;
  const UpdateAddressEvent(this.address);
}

class DeleteAddressEvent extends AddressEvent {
  final String id;
  const DeleteAddressEvent(this.id);
}

class SetDefaultAddressEvent extends AddressEvent {
  final String id;
  const SetDefaultAddressEvent(this.id);
}

class LoadCountries extends AddressEvent {
  const LoadCountries();
}

class LoadStates extends AddressEvent {
  final int countryId;
  const LoadStates(this.countryId);
}
