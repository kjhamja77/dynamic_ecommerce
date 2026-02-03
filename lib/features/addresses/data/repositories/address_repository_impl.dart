import '../../../../core/network/network_info.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_local_data_source.dart';
import '../datasources/address_remote_data_source.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressLocalDataSource local;
  final AddressRemoteDataSource remote;
  final NetworkInfo networkInfo;

  AddressRepositoryImpl({
    required this.local,
    required this.remote,
    required this.networkInfo,
  });

  @override
  Future<Address> addAddress(Address address) async {
    if (await networkInfo.isConnected) {
      final model = AddressModel.fromEntity(address);
      final remoteSaved = await remote.createAddress(model);
      await local.addAddress(remoteSaved);
      return remoteSaved;
    }
    // Offline fallback persists locally
    return await local.addAddress(AddressModel.fromEntity(address));
  }

  @override
  Future<void> updateAddress(Address address) async {
    if (await networkInfo.isConnected) {
      final updated = await remote.updateAddress(AddressModel.fromEntity(address));
      await local.updateAddress(updated);
      return;
    }
    await local.updateAddress(AddressModel.fromEntity(address));
  }

  @override
  Future<bool> deleteAddress(String id) async {
    if (await networkInfo.isConnected) {
      await remote.deleteAddress(id);
    }
    return local.deleteAddress(id);
  }

  @override
  Future<List<Address>> getAddresses() async {
    if (await networkInfo.isConnected) {
      final remoteList = await remote.listAddresses();
      
      // Ensure only one address is marked as default
      // If multiple addresses have default_address: true, keep only the first one
      bool foundDefault = false;
      final normalizedList = remoteList.map((address) {
        if (address.isDefault) {
          if (foundDefault) {
            // This is a duplicate default, set it to false
            return AddressModel.fromEntity(address.copyWith(isDefault: false));
          } else {
            // First default address found, keep it as default
            foundDefault = true;
            return address;
          }
        }
        return address;
      }).toList();
      
      // Replace local cache with remote
      // naive: clear and set via save helper
      // Save all at once
      // local has no bulk setter; re-save by clearing and adding
      final current = await local.getAddresses();
      for (final a in current) {
        await local.deleteAddress(a.id);
      }
      for (final a in normalizedList) {
        await local.addAddress(a);
      }
      return normalizedList;
    }
    // For offline, also ensure only one default
    final localList = await local.getAddresses();
    bool foundDefault = false;
    final normalizedLocalList = localList.map((address) {
      if (address.isDefault) {
        if (foundDefault) {
          // This is a duplicate default, set it to false
          return AddressModel.fromEntity(address.copyWith(isDefault: false));
        } else {
          // First default address found, keep it as default
          foundDefault = true;
          return address;
        }
      }
      return address;
    }).toList();
    
    // Update local storage if normalization changed anything
    if (normalizedLocalList.length == localList.length) {
      bool needsUpdate = false;
      for (int i = 0; i < normalizedLocalList.length; i++) {
        if (normalizedLocalList[i].isDefault != localList[i].isDefault) {
          needsUpdate = true;
          break;
        }
      }
      if (needsUpdate) {
        // Re-save normalized addresses
        final current = await local.getAddresses();
        for (final a in current) {
          await local.deleteAddress(a.id);
        }
        for (final a in normalizedLocalList) {
          await local.addAddress(a);
        }
      }
    }
    
    return normalizedLocalList;
  }

  @override
  Future<Address> setDefaultAddress(String id) async {
    // Call remote to update default flag, then sync local cache
    if (await networkInfo.isConnected) {
      final updated = await remote.setDefaultAddressRemote(id);
      // Also reflect in local cache for faster subsequent loads
      await local.setDefaultAddress(id);
      return updated;
    }
    return await local.setDefaultAddress(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getCountryList() async {
    if (await networkInfo.isConnected) {
      return remote.getCountryList();
    }
    // Offline: return empty; caller can handle
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getStateList(int countryId) async {
    if (await networkInfo.isConnected) {
      return remote.getStateList(countryId);
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getProvinceList() async {
    if (await networkInfo.isConnected) {
      return remote.getProvinceList();
    }
    return [];
  }
}
