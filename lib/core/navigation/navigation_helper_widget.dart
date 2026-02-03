import 'package:flutter/material.dart';
import '../../../../../core/services/haptic_service.dart';
import 'navigation_service.dart';

/// Helper widget that provides easy access to navigation animations
class NavigationHelper {
  /// Navigate to product details with zoom animation
  static Future<T?> toProductDetails<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toProductDetails<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to cart with slide from bottom
  static Future<T?> toCart<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toCart<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to checkout with slide and fade
  static Future<T?> toCheckout<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toCheckout<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to profile with slide from right
  static Future<T?> toProfile<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toProfile<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to favorites with slide from right
  static Future<T?> toFavorites<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toFavorites<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to search with slide from right
  static Future<T?> toSearch<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toSearch<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to catalog with slide and fade
  static Future<T?> toCatalog<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toCatalog<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to auth pages with slide from right
  static Future<T?> toAuth<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toAuth<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to modal/dialog pages with slide from bottom
  static Future<T?> toModal<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toModal<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to payment pages with slide and fade
  static Future<T?> toPayment<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toPayment<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to address pages with slide from right
  static Future<T?> toAddress<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toAddress<T>(
      page,
      settings: settings,
    );
  }

  /// Navigate to orders with slide from right
  static Future<T?> toOrders<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageNavigationAnimations.toOrders<T>(
      page,
      settings: settings,
    );
  }
}

/// Animated navigation button that provides consistent navigation animations
class AnimatedNavigationButton extends StatelessWidget {
  final Widget child;
  final Widget? destination;
  final String? routeName;
  final Object? arguments;
  final NavigationAnimationType animationType;
  final VoidCallback? onTap;
  final Duration? duration;

  const AnimatedNavigationButton({
    super.key,
    required this.child,
    this.destination,
    this.routeName,
    this.arguments,
    this.animationType = NavigationAnimationType.slideFromRight,
    this.onTap,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
          await HapticService.buttonClick();
          if (onTap != null) {
          onTap!();
          return;
        }

        if (destination != null) {
          _navigateWithAnimation(context, destination!);
        } else if (routeName != null) {
          Navigator.pushNamed(context, routeName!, arguments: arguments);
        }
      },
      child: child,
    );
  }

  void _navigateWithAnimation(BuildContext context, Widget destination) {
    switch (animationType) {
      case NavigationAnimationType.slideFromRight:
        NavigationService.pushSlideFromRight(destination);
        break;
      case NavigationAnimationType.slideFromBottom:
        NavigationService.pushSlideFromBottom(destination);
        break;
      case NavigationAnimationType.slideFromLeft:
        NavigationService.pushSlideFromRight(destination);
        break;
      case NavigationAnimationType.fade:
        NavigationService.pushFade(destination);
        break;
      case NavigationAnimationType.scale:
        NavigationService.pushScale(destination);
        break;
      case NavigationAnimationType.slideAndFade:
        NavigationService.pushSlideAndFade(destination);
        break;
      case NavigationAnimationType.zoom:
        NavigationService.pushZoom(destination);
        break;
      case NavigationAnimationType.productDetails:
        context.pushProductDetails(destination);
        break;
      case NavigationAnimationType.cart:
        context.pushCart(destination);
        break;
      case NavigationAnimationType.checkout:
        context.pushCheckout(destination);
        break;
      case NavigationAnimationType.profile:
        context.pushProfile(destination);
        break;
      case NavigationAnimationType.favorites:
        context.pushFavorites(destination);
        break;
      case NavigationAnimationType.search:
        context.pushSearch(destination);
        break;
      case NavigationAnimationType.catalog:
        context.pushCatalog(destination);
        break;
      case NavigationAnimationType.auth:
        context.pushAuth(destination);
        break;
      case NavigationAnimationType.modal:
        context.pushModal(destination);
        break;
      case NavigationAnimationType.payment:
        context.pushPayment(destination);
        break;
      case NavigationAnimationType.address:
        context.pushAddress(destination);
        break;
      case NavigationAnimationType.orders:
        context.pushOrders(destination);
        break;
    }
  }
}

/// Enum for different navigation animation types
enum NavigationAnimationType {
  slideFromRight,
  slideFromBottom,
  slideFromLeft,
  fade,
  scale,
  slideAndFade,
  zoom,
  productDetails,
  cart,
  checkout,
  profile,
  favorites,
  search,
  catalog,
  auth,
  modal,
  payment,
  address,
  orders,
}

/// Extension to add navigation methods to any widget
extension WidgetNavigationExtension on Widget {
  /// Wrap widget with animated navigation
  Widget withNavigation({
    Widget? destination,
    String? routeName,
    Object? arguments,
    NavigationAnimationType animationType = NavigationAnimationType.slideFromRight,
    VoidCallback? onTap,
    Duration? duration,
  }) {
    return AnimatedNavigationButton(
      destination: destination,
      routeName: routeName,
      arguments: arguments,
      animationType: animationType,
      onTap: onTap,
      duration: duration,
      child: this,
    );
  }
}
