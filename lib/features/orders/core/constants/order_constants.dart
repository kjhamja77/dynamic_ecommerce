import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order.dart';

class OrderConstants {
  // App theme colors
  static const Color primaryColor = Color(0xFFF36729); // App primary orange
  static const Color primaryColorLight = Color(0xFFF89A63); // Lighter variant
  static const Color primaryColorDark = Color(0xFFD4521A); // Darker variant
  
  // Semantic colors tuned to blend with the orange theme
  static const Color successColor = Color(0xFF1D994C); // Dark green for completed/delivered
  static const Color errorColor = Color(0xFFD52E2E); // Red for errors/cancelled
  static const Color warningColor = Color(0xFFF1CC32); // Warm yellow for confirmed / pending approval
  static const Color infoColor = Color(0xFF2563EB); // Blue for info / shipped
  static const Color neutralColor = Color(0xFF9CA3AF); // Softer grey for pending/neutral

  // Status colors - semantic and visually distinct
  static const Map<String, Color> statusColors = {
    // Core order lifecycle (order_status from API)
    'pending': neutralColor,          // Awaiting confirmation (grey)
    'confirmed': warningColor,        // Confirmed (yellow)
    'processing': primaryColor,       // In preparation / being packed
    'shipped': infoColor,             // In transit
    'delivered': successColor,        // Successfully delivered (completed)
    'completed': successColor,        // Some backends use "Completed"
    'cancelled': errorColor,
    'canceled': errorColor,
    'returned': neutralColor,
    // Refund-related business statuses from API (order_status)
    'refund - pending': warningColor,              // Waiting on approval
    'refund - pending approval': warningColor,     // Explicit pending-approval label
    'refund - processing': primaryColor,           // Being handled
    'refund - processed': successColor,            // Finished
    'refund - approved': successColor,
    'refund - completed': successColor,
    'refund - cancelled': errorColor,
    'refund - canceled': errorColor,
  };

  // Payment status colors - using app theme
  static const Map<String, Color> paymentStatusColors = {
    'pending': warningColor,
    'paid': successColor,
    'failed': errorColor,
    'refunded': neutralColor,
  };

  // Delivery state colors - using app theme
  static const Map<String, Color> deliveryStateColors = {
    'notStarted': neutralColor,
    'preparing': warningColor,
    'readyToShip': primaryColor,
    'inTransit': infoColor,
    'outForDelivery': primaryColorLight,
    'delivered': successColor,
    'deliveryFailed': errorColor,
    'returned': neutralColor,
    // API delivery status colors
    'new': neutralColor,
    'scheduled': infoColor,
    'collecting': primaryColor,
    'collected': infoColor,
    'in-transit': infoColor,
    'on-hold': warningColor,
    'out-for-delivery': primaryColor,
    'partially-delivered': successColor,
    'returned-warehouse': neutralColor,
    'returning-origin': warningColor,
    'partially-returned': neutralColor,
    'postponed': warningColor,
  };

  // Status icons
  static const Map<String, IconData> statusIcons = {
    'pending': Icons.schedule_outlined,
    'confirmed': Icons.check_circle_outlined,
    'processing': Icons.build_outlined,
    'shipped': Icons.local_shipping_outlined,
    'delivered': Icons.done_all_outlined,
    'cancelled': Icons.cancel_outlined,
    'returned': Icons.undo_outlined,
  };

  // Payment status icons
  static const Map<String, IconData> paymentStatusIcons = {
    'pending': Icons.schedule_outlined,
    'paid': Icons.check_circle_outlined,
    'failed': Icons.error_outline,
    'refunded': Icons.undo_outlined,
  };

  // Delivery state icons
  static const Map<String, IconData> deliveryStateIcons = {
    'notStarted': Icons.radio_button_unchecked,
    'preparing': Icons.inventory_2_outlined,
    'readyToShip': Icons.check_circle_outline,
    'inTransit': Icons.local_shipping_outlined,
    'outForDelivery': Icons.delivery_dining_outlined,
    'delivered': Icons.done_all_outlined,
    'deliveryFailed': Icons.error_outline,
    'returned': Icons.undo_outlined,
    // API delivery status icons
    'new': Icons.add_circle_outline,
    'scheduled': Icons.schedule_outlined,
    'collecting': Icons.directions_walk_outlined,
    'collected': Icons.check_circle_outline,
    'in-transit': Icons.local_shipping_outlined,
    'on-hold': Icons.pause_circle_outline,
    'out-for-delivery': Icons.delivery_dining_outlined,
    'partially-delivered': Icons.incomplete_circle_outlined,
    'returned-warehouse': Icons.warehouse_outlined,
    'returning-origin': Icons.keyboard_return_outlined,
    'partially-returned': Icons.history_outlined,
    'postponed': Icons.calendar_today_outlined,
  };

  static String localizedStatus(BuildContext context, OrderStatus status) {
    final loc = AppLocalizations.of(context)!;
    switch (status) {
      case OrderStatus.pending:
        return loc.pending;
      case OrderStatus.confirmed:
        return loc.confirmed;
      case OrderStatus.processing:
        return loc.processing;
      case OrderStatus.shipped:
        return loc.shipped;
      case OrderStatus.delivered:
        return loc.delivered;
      case OrderStatus.cancelled:
        return loc.cancelled;
      case OrderStatus.returned:
        return loc.returned;
    }
  }

  static String localizedPaymentStatus(BuildContext context, PaymentStatus status) {
    final loc = AppLocalizations.of(context)!;
    switch (status) {
      case PaymentStatus.pending:
        return loc.pending;
      case PaymentStatus.paid:
        return loc.paid;
      case PaymentStatus.failed:
        return loc.failed;
      case PaymentStatus.refunded:
        return loc.refunded;
    }
  }

  static String localizedDeliveryState(BuildContext context, DeliveryState state) {
    final loc = AppLocalizations.of(context)!;
    switch (state) {
      case DeliveryState.notStarted:
        return loc.notStarted;
      case DeliveryState.preparing:
        return loc.preparing;
      case DeliveryState.readyToShip:
        return loc.readyToShip;
      case DeliveryState.inTransit:
        return loc.inTransit;
      case DeliveryState.outForDelivery:
        return loc.outForDelivery;
      case DeliveryState.delivered:
        return loc.delivered;
      case DeliveryState.deliveryFailed:
        return loc.deliveryFailed;
      case DeliveryState.returned:
        return loc.returned;
    }
  }

  /// Gets localized delivery status string from API status
  static String localizedDeliveryStatusString(BuildContext context, String? status) {
    if (status == null || status.isEmpty) return '';
    
    final loc = AppLocalizations.of(context)!;
    final normalizedStatus = status.toLowerCase().trim();
    
    switch (normalizedStatus) {
      case 'new':
        return loc.deliveryStatusNew;
      case 'scheduled':
        return loc.deliveryStatusScheduled;
      case 'collecting':
        return loc.deliveryStatusCollecting;
      case 'collected':
        return loc.deliveryStatusCollected;
      case 'in-transit':
        return loc.deliveryStatusInTransit;
      case 'on-hold':
        return loc.deliveryStatusOnHold;
      case 'out-for-delivery':
        return loc.deliveryStatusOutForDelivery;
      case 'delivered':
        return loc.delivered;
      case 'partially-delivered':
        return loc.deliveryStatusPartiallyDelivered;
      case 'returned-warehouse':
        return loc.deliveryStatusReturnedWarehouse;
      case 'returning-origin':
        return loc.deliveryStatusReturningOrigin;
      case 'returned':
        return loc.returned;
      case 'partially-returned':
        return loc.deliveryStatusPartiallyReturned;
      case 'postponed':
        return loc.deliveryStatusPostponed;
      default:
        // Fallback: convert snake_case or kebab-case to Title Case
        return status
            .split(RegExp(r'[_\-\s]+'))
            .map((word) => word.isEmpty
                ? ''
                : word[0].toUpperCase() + word.substring(1).toLowerCase())
            .join(' ');
    }
  }

  /// Gets color for delivery status string
  static Color getDeliveryStatusColor(String? status) {
    if (status == null || status.isEmpty) return neutralColor;
    
    final normalizedStatus = status.toLowerCase().trim();
    return deliveryStateColors[normalizedStatus] ?? neutralColor;
  }

  /// Gets icon for delivery status string
  static IconData getDeliveryStatusIcon(String? status) {
    if (status == null || status.isEmpty) return Icons.info_outline;
    
    final normalizedStatus = status.toLowerCase().trim();
    return deliveryStateIcons[normalizedStatus] ?? Icons.info_outline;
  }

  /// Maps API delivery status string to DeliveryState enum
  static DeliveryState? mapApiStatusToDeliveryState(String? status) {
    if (status == null || status.isEmpty) return null;
    
    final normalizedStatus = status.toLowerCase().trim();
    
    switch (normalizedStatus) {
      case 'new':
      case 'pending':
        return DeliveryState.notStarted;
      case 'scheduled':
      case 'preparing':
      case 'processing':
      case 'prepared':
        return DeliveryState.preparing;
      case 'collecting':
      case 'collected':
      case 'ready_to_ship':
      case 'ready':
      case 'ready to ship':
        return DeliveryState.readyToShip;
      case 'in-transit':
      case 'in_transit':
      case 'in transit':
      case 'shipped':
      case 'shipping':
        return DeliveryState.inTransit;
      case 'out-for-delivery':
      case 'out_for_delivery':
      case 'out for delivery':
      case 'on_the_way':
      case 'on the way':
        return DeliveryState.outForDelivery;
      case 'delivered':
      case 'completed':
        return DeliveryState.delivered;
      case 'partially-delivered':
      case 'partially_delivered':
        return DeliveryState.delivered; // Map to delivered as it's a variant
      case 'failed':
      case 'delivery_failed':
      case 'delivery failed':
      case 'on-hold':
        return DeliveryState.deliveryFailed;
      case 'returned':
      case 'return':
      case 'returned-warehouse':
      case 'returning-origin':
      case 'partially-returned':
        return DeliveryState.returned;
      case 'postponed':
        return DeliveryState.notStarted; // Map to not started
      default:
        return DeliveryState.notStarted;
    }
  }
}
