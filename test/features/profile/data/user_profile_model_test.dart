import 'package:flutter_test/flutter_test.dart';
import 'package:zalando_clone_app/features/profile/data/models/user_profile_model.dart';

void main() {
  group('UserProfileModel.fromApiJson', () {
    test('maps backend shape to entity fields', () {
      final apiJson = {
        'user_id': 9,
        'partner_id': 67,
        'name': 'John Doe',
        'phone': '+1 555 123 4567',
        'email': 'john@example.com',
        'address': {
          'id': 67,
          'type': 'contact',
          'street': '456 New St',
          'street2': 'near madina',
          'city': 'Los Angeles',
          'zip': '90002',
          'state_id': 548,
          'state_name': 'Dubai',
          'country_id': 2,
          'country_name': 'United Arab Emirates',
        },
        'image': null,
      };

      final model = UserProfileModel.fromApiJson(apiJson);

      expect(model.id, '9');
      expect(model.name, 'John Doe');
      expect(model.email, 'john@example.com');
      expect(model.phoneNumber, '+1 555 123 4567');
      expect(model.address, contains('456 New St'));
      expect(model.address, contains('near madina'));
      expect(model.address, contains('Los Angeles'));
      expect(model.address, contains('90002'));
      expect(model.address, contains('Dubai'));
      expect(model.address, contains('United Arab Emirates'));
    });
  });
}


