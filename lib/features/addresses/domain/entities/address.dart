class Address {
  final String id;
  final String fullName;
  final String phone;
  /// Dial country code for phone (e.g. "964"), mapped to API field "country_code" for addresses.
  final String? phoneCountryCode;
  final String country;
  final String city;
  final String district;
  final String street;
  final String streetNumber;
  final String building;
  final String floor;
  final String apartment;
  final String zipCode;
  final String additionalInfo;
  final String label; // e.g., Home, Office
  final bool isDefault;
  final DateTime createdAt;
  final int? countryId; // API country ID
  final int? stateId; // API state ID
  final int? provinceId; // Iraqi province ID (iq.provice)
  final String? type; // delivery, invoice, etc.

  const Address({
    required this.id,
    required this.fullName,
    required this.phone,
    this.phoneCountryCode,
    required this.country,
    required this.city,
    required this.district,
    required this.street,
    required this.streetNumber,
    required this.building,
    this.floor = '',
    this.apartment = '',
    required this.zipCode,
    this.additionalInfo = '',
    this.label = '',
    this.isDefault = false,
    required this.createdAt,
    this.countryId,
    this.stateId,
    this.provinceId,
    this.type,
  });

  Address copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? country,
    String? city,
    String? district,
    String? street,
    String? streetNumber,
    String? building,
    String? floor,
    String? apartment,
    String? zipCode,
    String? additionalInfo,
    String? label,
    bool? isDefault,
    DateTime? createdAt,
    int? countryId,
    int? stateId,
    int? provinceId,
    String? phoneCountryCode,
    String? type,
  }) {
    return Address(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      phoneCountryCode: phoneCountryCode ?? this.phoneCountryCode,
      country: country ?? this.country,
      city: city ?? this.city,
      district: district ?? this.district,
      street: street ?? this.street,
      streetNumber: streetNumber ?? this.streetNumber,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      zipCode: zipCode ?? this.zipCode,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      countryId: countryId ?? this.countryId,
      stateId: stateId ?? this.stateId,
      provinceId: provinceId ?? this.provinceId,
      type: type ?? this.type,
    );
  }

  String get fullAddress {
    final parts = [
      streetNumber,
      street,
      building,
      if (floor.isNotEmpty) 'Floor $floor',
      if (apartment.isNotEmpty) 'Apartment $apartment',
      district,
      city,
      country,
      zipCode,
    ].where((part) => part.isNotEmpty).toList();
    
    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
