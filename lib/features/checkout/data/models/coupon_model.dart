import '../../domain/entities/coupon.dart';

class CouponModel extends Coupon {
  const CouponModel({
    required super.cardId,
    required super.code,
    required super.programId,
    required super.programName,
    required super.points,
    required super.balance,
    super.rewardDescription,
    super.expirationDate,
    super.programDateFrom,
    super.programDateTo,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return CouponModel(
      cardId: (json['card_id'] as num).toInt(),
      code: (json['code'] ?? '').toString(),
      programId: (json['program_id'] as num).toInt(),
      programName: (json['program_name'] ?? '').toString(),
      points: (json['points'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      rewardDescription: (json['reward_description'] ?? '').toString().isNotEmpty
          ? (json['reward_description'] ?? '').toString()
          : null,
      expirationDate: parseDate(json['expiration_date']),
      programDateFrom: parseDate(json['program_date_from']),
      programDateTo: parseDate(json['program_date_to']),
    );
  }
}

