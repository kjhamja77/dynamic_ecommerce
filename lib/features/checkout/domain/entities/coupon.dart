class Coupon {
  final int cardId;
  final String code;
  final int programId;
  final String programName;
  final double points;
  final double balance;
  final String? rewardDescription;
  final DateTime? expirationDate;
  final DateTime? programDateFrom;
  final DateTime? programDateTo;

  const Coupon({
    required this.cardId,
    required this.code,
    required this.programId,
    required this.programName,
    required this.points,
    required this.balance,
    this.rewardDescription,
    this.expirationDate,
    this.programDateFrom,
    this.programDateTo,
  });
}

