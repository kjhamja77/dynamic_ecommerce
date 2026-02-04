import 'dart:convert';

import 'package:flutter/foundation.dart';
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

    // Image from API: key "image" (base64 string); fallback to other keys
    String? avatarUrl = _imageFromApiJson(json);

    final profile = UserProfileModel(
      id: (json['user_id'] ?? json['id']).toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatarUrl: avatarUrl,
      phoneNumber: json['phone'] as String?,
      countryCode: json['country_code'] as String?,
      address: addressString,
      // Backend doesn't provide timestamps here; use now for required fields
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Debug logging
    debugPrint('UserProfileModel.fromApiJson: Parsed profile');
    debugPrint('  - ID: ${profile.id}');
    debugPrint('  - Name: ${profile.name}');
    debugPrint('  - Email: ${profile.email}');
    debugPrint('  - Phone: ${profile.phoneNumber}');
    debugPrint('  - Country Code: ${profile.countryCode}');
    // --- DEBUG: Image URL parsed from GET USER PROFILE API ---
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      debugPrint('🔵 [PARSED avatarUrl] from get user profile: null or empty');
    } else {
      debugPrint('🔵 [PARSED avatarUrl] from get user profile: length=${avatarUrl!.length}, preview: ${avatarUrl!.length > 60 ? "${avatarUrl!.substring(0, 60)}..." : avatarUrl}');
    }
    // --- END DEBUG ---

    return profile;
  }

  /// Reads image from API response. API key is "image" (base64 string or list of bytes). Normalizes to String for UI.
  static String? _imageFromApiJson(Map<String, dynamic> json) {
    final raw = json['image'];
    if (raw == null) {
      debugPrint('UserProfileModel._imageFromApiJson: "image" missing or null');
      return null;
    }
    if (raw is bool && !raw) {
      debugPrint('UserProfileModel._imageFromApiJson: "image" is false (no image)');
      return null;
    }
    if (raw is String) {
      final s = raw.trim();
      if (s.isNotEmpty) {
        debugPrint('UserProfileModel._imageFromApiJson: got "image" (base64 string), length=${s.length}');
        return s;
      }
      return null;
    }
    if (raw is List && raw.isNotEmpty) {
      try {
        final bytes = raw.map((e) => (e is num) ? e.toInt() & 0xff : 0).toList();
        final b64 = base64Encode(bytes);
        debugPrint('UserProfileModel._imageFromApiJson: got "image" (list of bytes), encoded length=${b64.length}');
        return b64;
      } catch (e) {
        debugPrint('UserProfileModel._imageFromApiJson: "image" list invalid: $e');
        return null;
      }
    }
    const fallbackKeys = ['image_1920', 'image_512', 'avatar', 'photo', 'picture'];
    for (final key in fallbackKeys) {
      final v = json[key];
      if (v is String && v.trim().isNotEmpty) {
        debugPrint('UserProfileModel._imageFromApiJson: using fallback key "$key", length=${v.length}');
        return v.trim();
      }
    }
    return null;
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
