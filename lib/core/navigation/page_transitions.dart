import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Custom page route transitions for professional navigation animations
class PageTransitions {
  /// Slide from right to left (most common for forward navigation)
  static Route<T> slideFromRight<T extends Object?>({
    required Widget page,
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: duration ?? AppConstants.mediumAnimation,
      reverseTransitionDuration: duration ?? AppConstants.mediumAnimation,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Slide from left to right (for back navigation)
  static Route<T> slideFromLeft<T extends Object?>({
    required Widget page,
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: duration ?? AppConstants.mediumAnimation,
      reverseTransitionDuration: duration ?? AppConstants.mediumAnimation,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Slide from bottom to top (for modals and bottom sheets)
  static Route<T> slideFromBottom<T extends Object?>({
    required Widget page,
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: duration ?? AppConstants.mediumAnimation,
      reverseTransitionDuration: duration ?? AppConstants.mediumAnimation,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Fade transition (for subtle page changes)
  static Route<T> fadeTransition<T extends Object?>({
    required Widget page,
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: duration ?? AppConstants.mediumAnimation,
      reverseTransitionDuration: duration ?? AppConstants.mediumAnimation,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;

        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: curve)),
          child: child,
        );
      },
    );
  }

  /// Scale transition (for product details and important pages)
  static Route<T> scaleTransition<T extends Object?>({
    required Widget page,
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: duration ?? AppConstants.mediumAnimation,
      reverseTransitionDuration: duration ?? AppConstants.mediumAnimation,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeOutBack;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Combined slide and fade (for smooth, modern feel)
  static Route<T> slideAndFade<T extends Object?>({
    required Widget page,
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
    Offset slideOffset = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: duration ?? AppConstants.mediumAnimation,
      reverseTransitionDuration: duration ?? AppConstants.mediumAnimation,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        // Slide animation
        var slideTween = Tween(begin: slideOffset, end: Offset.zero).chain(
          CurveTween(curve: curve),
        );

        // Fade animation
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Hero-like transition with custom curve (for special pages)
  static Route<T> heroTransition<T extends Object?>({
    required Widget page,
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: duration ?? AppConstants.longAnimation,
      reverseTransitionDuration: duration ?? AppConstants.mediumAnimation,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        // Scale animation
        var scaleTween = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        // Fade animation
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Zoom transition (for product details)
  static Route<T> zoomTransition<T extends Object?>({
    required Widget page,
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: duration ?? AppConstants.mediumAnimation,
      reverseTransitionDuration: duration ?? AppConstants.shortAnimation,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

/// Extension to make navigation easier with animations
extension AnimatedNavigation on NavigatorState {
  /// Push with slide from right animation
  Future<T?> pushSlideFromRight<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return push<T>(
      PageTransitions.slideFromRight<T>(
        page: page,
        settings: settings,
        duration: duration,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Push with slide from bottom animation
  Future<T?> pushSlideFromBottom<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return push<T>(
      PageTransitions.slideFromBottom<T>(
        page: page,
        settings: settings,
        duration: duration,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Push with fade animation
  Future<T?> pushFade<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return push<T>(
      PageTransitions.fadeTransition<T>(
        page: page,
        settings: settings,
        duration: duration,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Push with scale animation
  Future<T?> pushScale<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return push<T>(
      PageTransitions.scaleTransition<T>(
        page: page,
        settings: settings,
        duration: duration,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Push with slide and fade animation
  Future<T?> pushSlideAndFade<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
    Offset slideOffset = const Offset(1.0, 0.0),
  }) {
    return push<T>(
      PageTransitions.slideAndFade<T>(
        page: page,
        settings: settings,
        duration: duration,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        slideOffset: slideOffset,
      ),
    );
  }

  /// Push with zoom animation
  Future<T?> pushZoom<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return push<T>(
      PageTransitions.zoomTransition<T>(
        page: page,
        settings: settings,
        duration: duration,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Replace with slide from right animation
  Future<T?> pushReplacementSlideFromRight<T extends Object?, TO extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return pushReplacement<T, TO>(
      PageTransitions.slideFromRight<T>(
        page: page,
        settings: settings,
        duration: duration,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Push and remove until with slide animation
  Future<T?> pushNamedAndRemoveUntilSlide<T extends Object?>(
    String routeName, {
    Object? arguments,
    RouteSettings? settings,
    Duration? duration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
