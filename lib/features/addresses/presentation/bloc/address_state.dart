import 'package:equatable/equatable.dart';
import '../../domain/entities/address.dart';

abstract class AddressState extends Equatable {
  const AddressState();
}

class AddressInitial extends AddressState {
  @override
  List<Object?> get props => [];
}

class AddressLoading extends AddressState {
  @override
  List<Object?> get props => [];
}

class AddressesLoaded extends AddressState {
  final List<Address> addresses;
  const AddressesLoaded(this.addresses);
  
  @override
  List<Object?> get props => [addresses];
}

class AddressUpdating extends AddressState {
  final List<Address> addresses;
  const AddressUpdating(this.addresses);
  
  @override
  List<Object?> get props => [addresses];
}

class AddressSuccess extends AddressState {
  final String message;
  final List<Address>? addresses; // Optional addresses to preserve state
  
  const AddressSuccess(this.message, {this.addresses});
  
  @override
  List<Object?> get props => [message, addresses];
}

class AddressError extends AddressState {
  final String message;
  const AddressError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class CountriesLoading extends AddressState {
  @override
  List<Object?> get props => [];
}

class CountriesLoaded extends AddressState {
  final List<Map<String, dynamic>> countries;
  const CountriesLoaded(this.countries);
  
  @override
  List<Object?> get props => [countries];
}

class StatesLoading extends AddressState {
  @override
  List<Object?> get props => [];
}

class StatesLoaded extends AddressState {
  final int countryId;
  final List<Map<String, dynamic>> states;
  const StatesLoaded(this.countryId, this.states);
  
  @override
  List<Object?> get props => [countryId, states];
}
