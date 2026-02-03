import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    super.phoneNumber,
    super.countryCode,
    super.address,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      phoneNumber: json['phone_number'] as String?,
      countryCode: json['country_code'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Maps backend RPC profile shape to our entity
  factory UserProfileModel.fromApiJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    final addressString = address == null
        ? null
        : [
            address['street'],
            address['street2'],
            address['city'],
            address['zip'],
            address['state_name'],
            address['country_name'],
          ]
            .where((e) => e != null && (e as String).toString().trim().isNotEmpty)
            .map((e) => e as String)
            .join(', ');

    return UserProfileModel(
      id: (json['user_id'] ?? json['id']).toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatarUrl: json['image'] as String?,
      phoneNumber: json['phone'] as String?,
      countryCode: json['country_code'] as String?,
      address: addressString,
      // Backend doesn't provide timestamps here; use now for required fields
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatarUrl: entity.avatarUrl,
      phoneNumber: entity.phoneNumber,
      countryCode: entity.countryCode,
      address: entity.address,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
