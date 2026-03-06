import '../../domain/entities/address.dart';
import '../../../../core/utils/country_code_detector.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.fullName,
    required super.phone,
    super.phoneCountryCode,
    required super.country,
    required super.city,
    required super.district,
    required super.street,
    required super.streetNumber,
    required super.building,
    super.floor = '',
    super.apartment = '',
    required super.zipCode,
    super.additionalInfo = '',
    super.label = '',
    super.isDefault = false,
    required super.createdAt,
    super.countryId,
    super.stateId,
    super.provinceId,
    super.type,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        phone: json['phone'] as String,
        phoneCountryCode: json['phoneCountryCode'] as String?,
        country: json['country'] as String,
        city: json['city'] as String,
        district: json['district'] as String,
        street: json['street'] as String,
        streetNumber: json['streetNumber'] as String,
        building: json['building'] as String,
        floor: json['floor'] as String? ?? '',
        apartment: json['apartment'] as String? ?? '',
        zipCode: json['zipCode'] as String,
        additionalInfo: json['additionalInfo'] as String? ?? '',
        label: json['label'] as String? ?? '',
        isDefault: json['isDefault'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        countryId: json['countryId'] as int?,
        stateId: json['stateId'] as int?,
        provinceId: json['provinceId'] as int?,
        type: json['type'] as String?,
      );

  // Map backend RPC address shape to our model
  factory AddressModel.fromApiJson(Map<String, dynamic> json) {
    final rawPhone = (json['phone'] ?? '').toString();
    final rawCc = (json['country_code'] ?? json['phone_country_code'])?.toString();

    // Normalize into: phone = national digits only, phoneCountryCode = dial digits.
    final phoneDigits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    String national = phoneDigits;
    String? dialDigits;

    // 1) Prefer explicit country_code from API when it matches phone prefix.
    if (rawCc != null && rawCc.toString().trim().isNotEmpty) {
      final cc = rawCc.replaceAll(RegExp(r'[^0-9]'), '');
      if (cc.isNotEmpty) {
        if (national.startsWith(cc)) {
          national = national.substring(cc.length);
        }
        dialDigits = cc;
      }
    }

    // 2) If no valid dial from country_code, try to detect from phone prefix.
    if ((dialDigits == null || dialDigits.isEmpty) && phoneDigits.isNotEmpty) {
      final detectedCountry = CountryCodeDetector.detectCountry(phoneDigits);
      if (detectedCountry != null && phoneDigits.startsWith(detectedCountry.phoneCode)) {
        dialDigits = detectedCountry.phoneCode;
        national = phoneDigits.substring(detectedCountry.phoneCode.length);
      }
    }

    return AddressModel(
      id: (json['id'] ?? json['address_id'] ?? '').toString(),
      fullName: (json['name'] ?? '').toString(),
      phone: national,
      phoneCountryCode: dialDigits,
      country: (json['country_name'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['street2'] ?? '').toString(), // street2 is district in API
      street: (json['street'] ?? '').toString(),
      streetNumber: (json['street_number'] ?? '').toString(),
      building: (json['building'] ?? '').toString(),
      floor: (json['floor'] ?? '').toString(),
      apartment: (json['apartment'] ?? '').toString(),
      zipCode: (json['zip'] ?? '').toString(),
      additionalInfo: (json['additional_info'] ?? '').toString(),
      label: (json['type'] ?? '').toString(), // Use type as label if available
      isDefault: (json['default_address'] ?? false) == true,
      createdAt: DateTime.now(),
      countryId: json['country_id'] as int?,
      stateId: json['state_id'] as int?,
      provinceId: extractProvinceId(json['province_id']),
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phone': phone,
        'phoneCountryCode': phoneCountryCode,
        'country': country,
        'city': city,
        'district': district,
        'street': street,
        'streetNumber': streetNumber,
        'building': building,
        'floor': floor,
        'apartment': apartment,
        'zipCode': zipCode,
        'additionalInfo': additionalInfo,
        'label': label,
        'isDefault': isDefault,
        'createdAt': createdAt.toIso8601String(),
        'countryId': countryId,
        'stateId': stateId,
      'provinceId': provinceId,
        'type': type,
      };

  factory AddressModel.fromEntity(Address address) => AddressModel(
        id: address.id,
        fullName: address.fullName,
        phone: address.phone,
        phoneCountryCode: address.phoneCountryCode,
        country: address.country,
        city: address.city,
        district: address.district,
        street: address.street,
        streetNumber: address.streetNumber,
        building: address.building,
        floor: address.floor,
        apartment: address.apartment,
        zipCode: address.zipCode,
        additionalInfo: address.additionalInfo,
        label: address.label,
        isDefault: address.isDefault,
        createdAt: address.createdAt,
        countryId: address.countryId,
        stateId: address.stateId,
        provinceId: address.provinceId,
        type: address.type,
      );

  @override
  AddressModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? phoneCountryCode,
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
    String? type,
  }) {
    return AddressModel(
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

  static int? extractProvinceId(dynamic provinceField) {
    if (provinceField == null) return null;
    if (provinceField is int) return provinceField;
    if (provinceField is num) return provinceField.toInt();
    if (provinceField is Map<String, dynamic>) {
      final rawId = provinceField['id'];
      if (rawId is bool && rawId == false) return null;
      if (rawId is int) return rawId;
      if (rawId is num) return rawId.toInt();
      if (rawId != null) {
        final parsed = int.tryParse(rawId.toString());
        return parsed;
      }
    }
    return null;
  }
}
