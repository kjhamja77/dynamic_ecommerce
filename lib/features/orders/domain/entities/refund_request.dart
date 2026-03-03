import 'package:equatable/equatable.dart';

class RefundRequest extends Equatable {
  final int id;
  final String number;
  final int orderId;
  final String orderName;
  final String state;
  final String reason;
  final double totalRequestedAmount;
  final String? stateDisplay;
  final String? rejectionReason;
  final double? refundAmount;
  final DateTime? createdAt;
  final DateTime? approvedDate;
  final DateTime? processedDate;
  final List<RefundLine> lines;
  final String? refundInvoiceName;
  final String? returnPickingName;

  const RefundRequest({
    required this.id,
    required this.number,
    required this.orderId,
    required this.orderName,
    required this.state,
    required this.reason,
    required this.totalRequestedAmount,
    this.stateDisplay,
    this.rejectionReason,
    this.refundAmount,
    this.createdAt,
    this.approvedDate,
    this.processedDate,
    this.lines = const <RefundLine>[],
    this.refundInvoiceName,
    this.returnPickingName,
  });

  @override
  List<Object?> get props => [
        id,
        number,
        orderId,
        orderName,
        state,
        reason,
        totalRequestedAmount,
        stateDisplay,
        rejectionReason,
        refundAmount,
        createdAt,
        approvedDate,
        processedDate,
        lines,
        refundInvoiceName,
        returnPickingName,
      ];
}

class RefundLine extends Equatable {
  final int productId;
  final String productName;
  final String imageUrl;
  final double orderedQty;
  final double refundQty;
  final double unitPrice;
  final double subtotal;

  const RefundLine({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.orderedQty,
    required this.refundQty,
    required this.unitPrice,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        imageUrl,
        orderedQty,
        refundQty,
        unitPrice,
        subtotal,
      ];
}


