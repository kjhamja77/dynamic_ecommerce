import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'page_transitions.dart';
import '../constants/app_constants.dart';
import '../di/injection_container.dart' as di;
import '../../l10n/app_localizations.dart';

/// Navigation service to provide consistent animated navigation throughout the app
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current navigator state
  static NavigatorState? get currentState => navigatorKey.currentState;

  /// Get the current context
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Push with slide from right animation (most common)
  static Future<T?> pushSlideFromRight<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }  ) {
    return currentState?.pushSlideFromRight<T>(
      page,
      settings: settings,
      duration: duration,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    ) ?? Future.value(null);
  }

  /// Push with slide from bottom animation (for modals)
  static Future<T?> pushSlideFromBottom<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }  ) {
    return currentState?.pushSlideFromBottom<T>(
      page,
      settings: settings,
      duration: duration,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    ) ?? Future.value(null);
  }

  /// Push with fade animation (for subtle transitions)
  static Future<T?> pushFade<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }  ) {
    return currentState?.pushFade<T>(
      page,
      settings: settings,
      duration: duration,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    ) ?? Future.value(null);
  }

  /// Push with scale animation (for important pages)
  static Future<T?> pushScale<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }  ) {
    return currentState?.pushScale<T>(
      page,
      settings: settings,
      duration: duration,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    ) ?? Future.value(null);
  }

  /// Push with slide and fade animation (for smooth transitions)
  static Future<T?> pushSlideAndFade<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
    Offset slideOffset = const Offset(1.0, 0.0),
  }  ) {
    return currentState?.pushSlideAndFade<T>(
      page,
      settings: settings,
      duration: duration,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      slideOffset: slideOffset,
    ) ?? Future.value(null);
  }

  /// Push with zoom animation (for product details)
  static Future<T?> pushZoom<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }  ) {
    return currentState?.pushZoom<T>(
      page,
      settings: settings,
      duration: duration,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    ) ?? Future.value(null);
  }

  /// Replace current page with slide from right
  static Future<T?> pushReplacementSlideFromRight<T extends Object?, TO extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }  ) {
    return currentState?.pushReplacementSlideFromRight<T, TO>(
      page,
      settings: settings,
      duration: duration,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    ) ?? Future.value(null);
  }

  /// Push named route with animation
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
    RouteSettings? settings,
  }  ) {
    return currentState?.pushNamed<T>(routeName, arguments: arguments) ?? Future.value(null);
  }

  /// Push named route and remove all previous routes
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
    RoutePredicate? predicate,
  }  ) {
    return currentState?.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    ) ?? Future.value(null);
  }

  /// Pop current page
  static void pop<T extends Object?>([T? result]) {
    currentState?.pop<T>(result);
  }

  /// Pop until condition is met
  static void popUntil(RoutePredicate predicate) {
    currentState?.popUntil(predicate);
  }

  /// Pop to root
  static void popToRoot() {
    currentState?.popUntil((route) => route.isFirst);
  }

  /// Can pop current page
  static bool canPop() {
    return currentState?.canPop() ?? false;
  }
}

/// Navigation animations for specific page types
class PageNavigationAnimations {
  /// Navigate to product details with zoom animation
  static Future<T?> toProductDetails<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return NavigationService.pushZoom<T>(
      page,
      settings: settings,
      duration: AppConstants.mediumAnimation,
    );
  }

  /// Navigate to cart with slide from bottom
  static Future<T?> toCart<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return NavigationService.pushSlideFromBottom<T>(
      page,
      settings: settings,
      duration: AppConstants.mediumAnimation,
    );
  }

  /// Navigate to checkout with slide and fade
  static Future<T?> toCheckout<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return guardGuestAndNavigate<T>(
      featureName: 'Checkout',
      navigate: () => NavigationService.pushSlideAndFade<T>(
        page,
        settings: settings,
        duration: AppConstants.mediumAnimation,
        slideOffset: const Offset(1.0, 0.0),
      ),
    );
  }

  /// Navigate to profile/settings with slide from right
  static Future<T?> toProfile<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return guardGuestAndNavigate<T>(
      featureName: 'Profile',
      navigate: () => NavigationService.pushSlideFromRight<T>(
        page,
        settings: settings,
        duration: AppConstants.mediumAnimation,
      ),
    );
  }

  /// Navigate to favorites with slide from right
  static Future<T?> toFavorites<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return NavigationService.pushSlideFromRight<T>(
      page,
      settings: settings,
      duration: AppConstants.mediumAnimation,
    );
  }

  /// Navigate to search with slide from right
  static Future<T?> toSearch<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return NavigationService.pushSlideFromRight<T>(
      page,
      settings: settings,
      duration: AppConstants.mediumAnimation,
    );
  }

  /// Navigate to catalog with slide and fade
  static Future<T?> toCatalog<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return NavigationService.pushSlideAndFade<T>(
      page,
      settings: settings,
      duration: AppConstants.mediumAnimation,
      slideOffset: const Offset(1.0, 0.0),
    );
  }

  /// Navigate to auth pages with slide from right
  static Future<T?> toAuth<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return NavigationService.pushSlideFromRight<T>(
      page,
      settings: settings,
      duration: AppConstants.mediumAnimation,
    );
  }

  /// Navigate to onboarding with slide from bottom
  static Future<T?> toOnboarding<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return NavigationService.pushSlideFromBottom<T>(
      page,
      settings: settings,
      duration: const Duration(milliseconds: 500),
    );
  }

  /// Navigate to modal/dialog pages with slide from bottom
  static Future<T?> toModal<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return NavigationService.pushSlideFromBottom<T>(
      page,
      settings: settings,
      duration: AppConstants.mediumAnimation,
      fullscreenDialog: true,
    );
  }

  /// Navigate to payment pages with slide and fade
  static Future<T?> toPayment<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return NavigationService.pushSlideAndFade<T>(
      page,
      settings: settings,
      duration: AppConstants.mediumAnimation,
      slideOffset: const Offset(1.0, 0.0),
    );
  }

  /// Navigate to address pages with slide from right
  static Future<T?> toAddress<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return NavigationService.pushSlideFromRight<T>(
      page,
      settings: settings,
      duration: AppConstants.mediumAnimation,
    );
  }

  /// Navigate to orders with slide from right
  static Future<T?> toOrders<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return NavigationService.pushSlideFromRight<T>(
      page,
      settings: settings,
      duration: AppConstants.mediumAnimation,
    );
  }
}

Future<T?> guardGuestAndNavigate<T extends Object?>({
  required String featureName,
  required Future<T?> Function() navigate,
}) async {
  final ctx = NavigationService.currentContext;
  try {
    final storage = di.sl<FlutterSecureStorage>();
    final cached = await storage.read(key: AppConstants.userKey);
    final isGuest = (cached ?? '').toLowerCase().contains('guest: true');
    if (isGuest) {
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(ctx)?.signInToUnlockFeatures ?? 'Please sign in to continue')),
        );
      }
      return Future.value(null);
    }
  } catch (_) {}
  return navigate();
}

/// Extension to make navigation easier in widgets
extension NavigationExtension on BuildContext {
  /// Navigate to product details with zoom animation
  Future<T?> pushProductDetails<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toProductDetails<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to cart with slide from bottom
  Future<T?> pushCart<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toCart<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to checkout with slide and fade
  Future<T?> pushCheckout<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toCheckout<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to profile with slide from right
  Future<T?> pushProfile<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toProfile<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to favorites with slide from right
  Future<T?> pushFavorites<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toFavorites<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to search with slide from right
  Future<T?> pushSearch<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toSearch<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to catalog with slide and fade
  Future<T?> pushCatalog<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toCatalog<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to auth pages with slide from right
  Future<T?> pushAuth<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toAuth<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to modal with slide from bottom
  Future<T?> pushModal<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toModal<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to payment with slide and fade
  Future<T?> pushPayment<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toPayment<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to address with slide from right
  Future<T?> pushAddress<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toAddress<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to orders with slide from right
  Future<T?> pushOrders<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toOrders<T>(
      page,
      settings: settings,
    );
  }

  /// Pop with animation
  void popAnimated<T extends Object?>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  /// Pop until condition with animation
  void popUntilAnimated(RoutePredicate predicate) {
    Navigator.of(this).popUntil(predicate);
  }

  /// Pop to root with animation
  void popToRootAnimated() {
    Navigator.of(this).popUntil((route) => route.isFirst);
  }
}
