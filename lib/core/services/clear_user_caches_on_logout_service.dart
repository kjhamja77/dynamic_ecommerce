import 'package:flutter/foundation.dart';

import '../../features/addresses/data/datasources/address_local_data_source.dart' as Addr;
import '../../features/cart/data/datasources/cart_local_data_source.dart';
import '../../features/filters/data/datasources/filter_remote_data_source.dart';
import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/orders/data/datasources/order_local_data_source.dart';
import '../../features/payment_method/data/datasources/payment_method_local_data_source.dart';

/// Clears all user- and session-specific caches when the user logs out,
/// so the next user (or guest) does not see the previous user's data.
///
/// Called from [AuthRepositoryImpl.logout]. Covers: cart, orders, home
/// page cache, addresses, payment methods, and in-memory filter attributes cache.
class ClearUserCachesOnLogoutService {
  final CartLocalDataSource _cartLocal;
  final OrderLocalDataSource _orderLocal;
  final HomeLocalDataSource _homeLocal;
  final Addr.AddressLocalDataSource _addressLocal;
  final PaymentMethodLocalDataSource _paymentMethodLocal;
  final FilterRemoteDataSource _filterRemote;

  ClearUserCachesOnLogoutService({
    required CartLocalDataSource cartLocal,
    required OrderLocalDataSource orderLocal,
    required HomeLocalDataSource homeLocal,
    required Addr.AddressLocalDataSource addressLocal,
    required PaymentMethodLocalDataSource paymentMethodLocal,
    required FilterRemoteDataSource filterRemote,
  })  : _cartLocal = cartLocal,
        _orderLocal = orderLocal,
        _homeLocal = homeLocal,
        _addressLocal = addressLocal,
        _paymentMethodLocal = paymentMethodLocal,
        _filterRemote = filterRemote;

  /// Clears cart, orders, home, addresses, payment methods, and filter cache.
  /// Swallows per-cache errors so one failure does not block the rest.
  Future<void> clearAll() async {
    await _clearSafely('cart', () => _cartLocal.clearCart());
    await _clearSafely('orders', () => _orderLocal.clearOrders());
    await _clearSafely('home', () => _homeLocal.clearAllCachesForLogout());
    await _clearSafely('addresses', () => _addressLocal.clearAll());
    await _clearSafely('payment methods', () => _paymentMethodLocal.clearAll());
    try {
      _filterRemote.clearAttributesCache();
    } catch (e) {
      debugPrint('ClearUserCachesOnLogoutService: failed to clear filter cache: $e');
    }
  }

  Future<void> _clearSafely(String name, Future<void> Function() clear) async {
    try {
      await clear();
    } catch (e) {
      debugPrint('ClearUserCachesOnLogoutService: failed to clear $name: $e');
    }
  }
}
