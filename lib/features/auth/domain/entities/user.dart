import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? currency;
  final int? currencyId;
  final bool mobileVerified;
  final bool isGuest;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.currency,
    this.currencyId,
    this.mobileVerified = false,
    this.isGuest = false,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        profileImage,
        phoneNumber,
        createdAt,
        updatedAt,
        currency,
        currencyId,
        mobileVerified,
        isGuest,
      ];
}
