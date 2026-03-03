import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/refund_request.dart';

class RefundRequestModel extends RefundRequest {
  const RefundRequestModel({
    required super.id,
    required super.number,
    required super.orderId,
    required super.orderName,
    required super.state,
    required super.reason,
    required super.totalRequestedAmount,
    super.stateDisplay,
    super.rejectionReason,
    super.refundAmount,
    super.createdAt,
    super.approvedDate,
    super.processedDate,
    super.lines = const <RefundLine>[],
    super.refundInvoiceName,
    super.returnPickingName,
  });

  factory RefundRequestModel.fromJson(Map<String, dynamic> json) {
    return RefundRequestModel(
      id: (json['refund_request_id'] as num).toInt(),
      number: (json['refund_request_number'] ?? '').toString(),
      orderId: (json['order_id'] as num).toInt(),
      orderName: (json['order_name'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      totalRequestedAmount:
          (json['total_requested_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Maps a single refund request item from the list API:
  /// {
  ///   "id": 2,
  ///   "name": "RFR/00002",
  ///   "sale_order_id": 48,
  ///   "sale_order_name": "S00048",
  ///   "state": "pending",
  ///   "state_display": "Pending Approval",
  ///   "reason": "i dont like the product",
  ///   "rejection_reason": "",
  ///   "total_requested_amount": 26250,
  ///   "refund_amount": 0,
  ///   "create_date": "2026-03-02 07:01:31",
  ///   "approved_date": null,
  ///   "processed_date": null,
  ///   ...
  /// }
  factory RefundRequestModel.fromListJson(Map<String, dynamic> json) {
    final List<dynamic> rawLines =
        (json['refund_lines'] as List<dynamic>?) ?? const <dynamic>[];

    return RefundRequestModel(
      id: (json['id'] as num).toInt(),
      number: (json['name'] ?? '').toString(),
      orderId: (json['sale_order_id'] as num).toInt(),
      orderName: (json['sale_order_name'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      totalRequestedAmount:
          (json['total_requested_amount'] as num?)?.toDouble() ?? 0.0,
      stateDisplay: (json['state_display'] ?? '').toString(),
      rejectionReason: (json['rejection_reason'] ?? '').toString(),
      refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: _parseRefundDate(json['create_date']),
      approvedDate: _parseRefundDate(json['approved_date']),
      processedDate: _parseRefundDate(json['processed_date']),
      lines: rawLines
          .whereType<Map<String, dynamic>>()
          .map(RefundLineModel.fromJson)
          .toList(),
      refundInvoiceName: (json['refund_invoice_name'] ?? '').toString(),
      returnPickingName: (json['return_picking_name'] ?? '').toString(),
    );
  }

  /// Maps refund request details payload from /ecom/sale/getRefundRequestDetails
  factory RefundRequestModel.fromDetailsJson(Map<String, dynamic> json) {
    final List<dynamic> rawLines =
        (json['refund_lines'] as List<dynamic>?) ?? const <dynamic>[];

    return RefundRequestModel(
      id: (json['id'] as num).toInt(),
      number: (json['name'] ?? '').toString(),
      orderId: (json['sale_order_id'] as num).toInt(),
      orderName: (json['sale_order_name'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      totalRequestedAmount:
          (json['total_requested_amount'] as num?)?.toDouble() ?? 0.0,
      stateDisplay: (json['state_display'] ?? '').toString(),
      rejectionReason: (json['rejection_reason'] ?? '').toString(),
      refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: _parseRefundDate(json['create_date']),
      approvedDate: _parseRefundDate(json['approved_date']),
      processedDate: _parseRefundDate(json['processed_date']),
      lines: rawLines
          .whereType<Map<String, dynamic>>()
          .map(RefundLineModel.fromJson)
          .toList(),
      refundInvoiceName: (json['refund_invoice_name'] ?? '').toString(),
      returnPickingName: (json['return_picking_name'] ?? '').toString(),
    );
  }
}

class RefundLineModel extends RefundLine {
  const RefundLineModel({
    required super.productId,
    required super.productName,
    required super.imageUrl,
    required super.orderedQty,
    required super.refundQty,
    required super.unitPrice,
    required super.subtotal,
  });

  factory RefundLineModel.fromJson(Map<String, dynamic> json) {
    final String rawImage = (json['product_image'] ?? '').toString();

    return RefundLineModel(
      productId: (json['product_id'] as num).toInt(),
      productName: (json['product_name'] ?? '').toString(),
      imageUrl: _resolveRefundImageUrl(rawImage),
      orderedQty: (json['ordered_qty'] as num?)?.toDouble() ?? 0.0,
      refundQty: (json['refund_qty'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['price_unit'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['price_subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

DateTime? _parseRefundDate(dynamic value) {
  if (value == null) return null;
  final raw = value.toString();
  if (raw.isEmpty) return null;
  final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized);
}

String _resolveRefundImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';

  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }

  final base = AppConstants.baseUrl;
  final cleanBase =
      base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  final cleanPath = path.startsWith('/') ? path : '/$path';
  return '$cleanBase$cleanPath';
}


