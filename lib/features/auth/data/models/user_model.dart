import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.profileImage,
    super.phoneNumber,
    required super.createdAt,
    required super.updatedAt,
    super.currency,
    super.currencyId,
    super.mobileVerified,
    super.isGuest,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profileImage: json['profile_image'],
      phoneNumber: json['phone_number'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      currency: json['currency'],
      currencyId: json['currency_id'],
      mobileVerified: json['mobile_verified'] as bool? ?? false,
      isGuest: json['guest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image': profileImage,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'currency': currency,
      'currency_id': currencyId,
      'mobile_verified': mobileVerified,
      'guest': isGuest,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      profileImage: user.profileImage,
      phoneNumber: user.phoneNumber,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      currency: user.currency,
      currencyId: user.currencyId,
      mobileVerified: user.mobileVerified,
      isGuest: user.isGuest,
    );
  }
}
