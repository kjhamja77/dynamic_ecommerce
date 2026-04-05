import 'order.dart';

/// Outcome of a successful remote cancel: updated [order] plus optional API text (any language).
class CancelOrderResult {
  final Order order;
  final String apiMessage;

  const CancelOrderResult({
    required this.order,
    required this.apiMessage,
  });
}
