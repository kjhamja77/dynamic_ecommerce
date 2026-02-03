import '../../domain/entities/shipping_address.dart';

class ShippingAddressModel extends ShippingAddress {
  const ShippingAddressModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.streetAddress,
    required super.city,
    required super.state,
    required super.zipCode,
    required super.country,
    required super.phone,
    required super.isDefault,
  });

  factory ShippingAddressModel.fromEntity(ShippingAddress address) {
    return ShippingAddressModel(
      id: address.id,
      firstName: address.firstName,
      lastName: address.lastName,
      streetAddress: address.streetAddress,
      city: address.city,
      state: address.state,
      zipCode: address.zipCode,
      country: address.country,
      phone: address.phone,
      isDefault: address.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'phone': phone,
      'isDefault': isDefault,
    };
  }

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      streetAddress: json['streetAddress'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
      phone: json['phone'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
