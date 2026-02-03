import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/addresses/data/models/address_model.dart';

void main() {
  test('map API address json to AddressModel', () {
    final json = {
      'id': 67,
      'name': 'Home',
      'phone': '+1 555',
      'country_name': 'United States',
      'city': 'LA',
      'district': 'Central',
      'street': '123 Main',
      'street_number': '1',
      'building': 'A',
      'floor': '2',
      'apartment': '201',
      'zip': '90001',
      'label': 'Home',
      'is_default': true,
    };
    final model = AddressModel.fromApiJson(json);
    expect(model.id, '67');
    expect(model.fullName, 'Home');
    expect(model.city, 'LA');
    expect(model.street, '123 Main');
    expect(model.zipCode, '90001');
    expect(model.isDefault, true);
  });
}


