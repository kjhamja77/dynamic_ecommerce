import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/addresses/addresses.dart';

void main() {
  group('Address Feature Integration Tests', () {
    test('should create Address entity with all required fields', () {
      // Arrange & Act
      final address = Address(
        id: '1',
        fullName: 'Test User',
        phone: '+964-750-123-4567',
        country: 'Iraq',
        city: 'Baghdad',
        district: 'Al-Mansour',
        street: 'Test Street',
        streetNumber: '123',
        building: 'Test Building',
        floor: '1',
        apartment: 'A',
        zipCode: '10001',
        additionalInfo: 'Test address',
        label: 'Home',
        isDefault: false,
        createdAt: DateTime.now(),
        countryId: 1,
        stateId: 1,
        type: 'delivery',
      );

      // Assert
      expect(address.id, '1');
      expect(address.fullName, 'Test User');
      expect(address.country, 'Iraq');
      expect(address.city, 'Baghdad');
      expect(address.fullAddress, contains('123'));
      expect(address.fullAddress, contains('Test Street'));
      expect(address.fullAddress, contains('Baghdad'));
      expect(address.fullAddress, contains('Iraq'));
    });

    test('should create AddressModel from entity', () {
      // Arrange
      final address = Address(
        id: '1',
        fullName: 'Test User',
        phone: '+964-750-123-4567',
        country: 'Iraq',
        city: 'Baghdad',
        district: 'Al-Mansour',
        street: 'Test Street',
        streetNumber: '123',
        building: 'Test Building',
        floor: '1',
        apartment: 'A',
        zipCode: '10001',
        additionalInfo: 'Test address',
        label: 'Home',
        isDefault: false,
        createdAt: DateTime.now(),
        countryId: 1,
        stateId: 1,
        type: 'delivery',
      );

      // Act
      final model = AddressModel.fromEntity(address);

      // Assert
      expect(model.id, address.id);
      expect(model.fullName, address.fullName);
      expect(model.country, address.country);
      expect(model.city, address.city);
      expect(model.countryId, address.countryId);
      expect(model.stateId, address.stateId);
      expect(model.type, address.type);
    });

    test('should serialize AddressModel to JSON', () {
      // Arrange
      final address = Address(
        id: '1',
        fullName: 'Test User',
        phone: '+964-750-123-4567',
        country: 'Iraq',
        city: 'Baghdad',
        district: 'Al-Mansour',
        street: 'Test Street',
        streetNumber: '123',
        building: 'Test Building',
        floor: '1',
        apartment: 'A',
        zipCode: '10001',
        additionalInfo: 'Test address',
        label: 'Home',
        isDefault: false,
        createdAt: DateTime.now(),
        countryId: 1,
        stateId: 1,
        type: 'delivery',
      );
      final model = AddressModel.fromEntity(address);

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['fullName'], 'Test User');
      expect(json['country'], 'Iraq');
      expect(json['city'], 'Baghdad');
      expect(json['countryId'], 1);
      expect(json['stateId'], 1);
      expect(json['type'], 'delivery');
    });

    test('should create AddressModel from API JSON', () {
      // Arrange
      final apiJson = {
        'id': 123,
        'name': 'Test User',
        'phone': '+964-750-123-4567',
        'country_name': 'Iraq',
        'city': 'Baghdad',
        'district': 'Al-Mansour',
        'street': 'Test Street',
        'street_number': '123',
        'building': 'Test Building',
        'floor': '1',
        'apartment': 'A',
        'zip': '10001',
        'additional_info': 'Test address',
        'label': 'Home',
        'is_default': false,
        'country_id': 1,
        'state_id': 1,
        'type': 'delivery',
      };

      // Act
      final model = AddressModel.fromApiJson(apiJson);

      // Assert
      expect(model.id, '123');
      expect(model.fullName, 'Test User');
      expect(model.country, 'Iraq');
      expect(model.city, 'Baghdad');
      expect(model.countryId, 1);
      expect(model.stateId, 1);
      expect(model.type, 'delivery');
    });

    test('should verify address feature is properly exported', () {
      // This test verifies that all necessary components are exported
      // and can be imported from the addresses.dart barrel file
      
      // Assert - These should compile without errors
      expect(Address, isNotNull);
      expect(AddressModel, isNotNull);
      expect(AddressBloc, isNotNull);
      expect(AddressEvent, isNotNull);
      expect(AddressState, isNotNull);
      expect(AddressesPage, isNotNull);
      expect(EditAddressPage, isNotNull);
      expect(AddressCard, isNotNull);
    });
  });
}
