import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/address.dart';
import '../../domain/usecases/get_addresses.dart';
import '../../domain/usecases/add_address.dart';
import '../../domain/usecases/update_address.dart';
import '../../domain/usecases/delete_address.dart';
import '../../domain/usecases/set_default_address.dart';
import '../../domain/usecases/get_countries.dart';
import '../../domain/usecases/get_states.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final GetAddresses getAddresses;
  final AddAddress addAddress;
  final UpdateAddress updateAddress;
  final DeleteAddress deleteAddress;
  final SetDefaultAddress setDefaultAddress;
  final GetCountries getCountries;
  final GetStates getStates;

  AddressBloc({
    required this.getAddresses,
    required this.addAddress,
    required this.updateAddress,
    required this.deleteAddress,
    required this.setDefaultAddress,
    required this.getCountries,
    required this.getStates,
  }) : super(AddressInitial()) {
    on<LoadAddresses>(_onLoad);
    on<AddNewAddress>(_onAdd);
    on<UpdateAddressEvent>(_onUpdate);
    on<DeleteAddressEvent>(_onDelete);
    on<SetDefaultAddressEvent>(_onSetDefault);
    on<LoadCountries>(_onLoadCountries);
    on<LoadStates>(_onLoadStates);
  }

  Future<void> _onLoad(LoadAddresses event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final list = await getAddresses();
      emit(AddressesLoaded(list));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onLoadCountries(LoadCountries event, Emitter<AddressState> emit) async {
    emit(CountriesLoading());
    try {
      final list = await getCountries();
      emit(CountriesLoaded(list));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onLoadStates(LoadStates event, Emitter<AddressState> emit) async {
    emit(StatesLoading());
    try {
      final list = await getStates(event.countryId);
      emit(StatesLoaded(event.countryId, list));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onAdd(AddNewAddress event, Emitter<AddressState> emit) async {
    // Get current state to preserve addresses list
    List<Address>? currentAddresses;
    if (state is AddressesLoaded) {
      currentAddresses = List<Address>.from((state as AddressesLoaded).addresses);
    } else if (state is AddressUpdating) {
      currentAddresses = List<Address>.from((state as AddressUpdating).addresses);
    } else if (state is AddressSuccess && (state as AddressSuccess).addresses != null) {
      currentAddresses = List<Address>.from((state as AddressSuccess).addresses!);
    }

    if (currentAddresses != null) {
      // Optimistically add
      currentAddresses.add(event.address);
      emit(AddressUpdating(currentAddresses));
      try {
        await addAddress(event.address);
        emit(AddressSuccess('Address added successfully', addresses: currentAddresses));
      } catch (e) {
        currentAddresses.removeWhere((a) => a.id == event.address.id);
        emit(AddressError(e.toString()));
        add(const LoadAddresses());
      }
    } else {
      // Fallback
      emit(AddressLoading());
      try {
        await addAddress(event.address);
        emit(const AddressSuccess('Address added'));
        add(const LoadAddresses());
      } catch (e) {
        emit(AddressError(e.toString()));
      }
    }
  }

  Future<void> _onUpdate(UpdateAddressEvent event, Emitter<AddressState> emit) async {
    // Get current state to preserve addresses list
    List<Address>? base;
    if (state is AddressesLoaded) {
      base = List<Address>.from((state as AddressesLoaded).addresses);
    } else if (state is AddressUpdating) {
      base = List<Address>.from((state as AddressUpdating).addresses);
    } else if (state is AddressSuccess && (state as AddressSuccess).addresses != null) {
      base = List<Address>.from((state as AddressSuccess).addresses!);
    }

    if (base != null) {
      final idx = base.indexWhere((a) => a.id == event.address.id);
      if (idx != -1) {
        final original = base[idx];
        base[idx] = event.address;
        emit(AddressUpdating(base));
        try {
          await updateAddress(event.address);
          emit(AddressSuccess('Address updated successfully', addresses: base));
        } catch (e) {
          base[idx] = original;
          emit(AddressError(e.toString()));
          add(const LoadAddresses());
        }
      } else {
        emit(AddressLoading());
        try {
          await updateAddress(event.address);
          emit(const AddressSuccess('Address updated'));
          add(const LoadAddresses());
        } catch (e) {
          emit(AddressError(e.toString()));
        }
      }
    } else {
      emit(AddressLoading());
      try {
        await updateAddress(event.address);
        emit(const AddressSuccess('Address updated'));
        add(const LoadAddresses());
      } catch (e) {
        emit(AddressError(e.toString()));
      }
    }
  }

  Future<void> _onDelete(DeleteAddressEvent event, Emitter<AddressState> emit) async {
    // Get current state to preserve addresses list
    List<Address>? base;
    if (state is AddressesLoaded) {
      base = List<Address>.from((state as AddressesLoaded).addresses);
    } else if (state is AddressUpdating) {
      base = List<Address>.from((state as AddressUpdating).addresses);
    } else if (state is AddressSuccess && (state as AddressSuccess).addresses != null) {
      base = List<Address>.from((state as AddressSuccess).addresses!);
    }

    if (base != null) {
      final original = List<Address>.from(base);
      base.removeWhere((addr) => addr.id == event.id);
      emit(AddressUpdating(base));
      try {
        await deleteAddress(event.id);
        emit(AddressSuccess('Address deleted successfully', addresses: base));
      } catch (e) {
        emit(AddressError(e.toString()));
        // Revert and reload
        emit(AddressesLoaded(original));
        add(const LoadAddresses());
      }
    } else {
      emit(AddressLoading());
      try {
        await deleteAddress(event.id);
        emit(const AddressSuccess('Address deleted'));
        add(const LoadAddresses());
      } catch (e) {
        emit(AddressError(e.toString()));
      }
    }
  }

  Future<void> _onSetDefault(SetDefaultAddressEvent event, Emitter<AddressState> emit) async {
    // Get a working copy from any compatible state
    List<Address>? base;
    if (state is AddressesLoaded) {
      base = List<Address>.from((state as AddressesLoaded).addresses);
    } else if (state is AddressUpdating) {
      base = List<Address>.from((state as AddressUpdating).addresses);
    } else if (state is AddressSuccess && (state as AddressSuccess).addresses != null) {
      base = List<Address>.from((state as AddressSuccess).addresses!);
    }

    if (base != null) {
      for (int i = 0; i < base.length; i++) {
        if (base[i].id == event.id) {
          base[i] = base[i].copyWith(isDefault: true);
        } else {
          base[i] = base[i].copyWith(isDefault: false);
        }
      }
      emit(AddressUpdating(base));
      try {
        await setDefaultAddress(event.id);
        emit(AddressSuccess('Default address updated successfully', addresses: base));
      } catch (e) {
        emit(AddressError(e.toString()));
        add(const LoadAddresses());
      }
    } else {
      // Silently set and then load
      try {
        await setDefaultAddress(event.id);
        emit(const AddressSuccess('Default address updated successfully'));
        add(const LoadAddresses());
      } catch (e) {
        emit(AddressError(e.toString()));
      }
    }
  }
}
