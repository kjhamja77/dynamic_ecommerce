class ShippingAddress {
  final String id;
  final String firstName;
  final String lastName;
  final String streetAddress;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phone;
  final bool isDefault;
  final int? provinceId; // Province ID for incomplete check

  const ShippingAddress({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phone,
    this.isDefault = false,
    this.provinceId,
  });

  ShippingAddress copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? streetAddress,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? phone,
    bool? isDefault,
    int? provinceId,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
      provinceId: provinceId ?? this.provinceId,
    );
  }

  String get fullName => '$firstName $lastName';
  
  String get fullAddress {
    final parts = <String>[];
    
    // Only add non-empty fields
    if (streetAddress.trim().isNotEmpty) {
      parts.add(streetAddress.trim());
    }
    if (city.trim().isNotEmpty) {
      parts.add(city.trim());
    }
    
    // Combine state and zipCode if both exist, or add separately if only one exists
    final stateZip = <String>[];
    if (state.trim().isNotEmpty) {
      stateZip.add(state.trim());
    }
    if (zipCode.trim().isNotEmpty) {
      stateZip.add(zipCode.trim());
    }
    if (stateZip.isNotEmpty) {
      parts.add(stateZip.join(' '));
    }
    
    if (country.trim().isNotEmpty) {
      parts.add(country.trim());
    }
    
    // Join all parts with comma and space
    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShippingAddress &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.streetAddress == streetAddress &&
        other.city == city &&
        other.state == state &&
        other.zipCode == zipCode &&
        other.country == country &&
        other.phone == phone &&
        other.isDefault == isDefault &&
        other.provinceId == provinceId;
  }

  @override
  int get hashCode => id.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      streetAddress.hashCode ^
      city.hashCode ^
      state.hashCode ^
      zipCode.hashCode ^
      country.hashCode ^
      phone.hashCode ^
      isDefault.hashCode ^
      provinceId.hashCode;
}
