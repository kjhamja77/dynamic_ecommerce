import 'dart:async';
import 'package:flutter/material.dart';
import 'connectivity_service.dart';
import '../navigation/navigation_service.dart';

class ConnectivityNavigationService {
  static final ConnectivityNavigationService _instance = ConnectivityNavigationService._internal();
  factory ConnectivityNavigationService() => _instance;
  ConnectivityNavigationService._internal();

  ConnectivityService? _connectivityService;
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  bool _isNavigating = false;
  String? _currentPage;
  Map<String, dynamic>? _pageData;

  /// Initialize the connectivity navigation service
  void initialize() {
    _connectivityService = ConnectivityService();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    if (_connectivityService == null) return;

    _connectivitySubscription = _connectivityService!.statusStream.listen(
      (status) {
        _handleConnectivityChange(status);
      },
      onError: (error) {
        print('❌ Connectivity navigation error: $error');
      },
    );
  }

  void _handleConnectivityChange(ConnectivityStatus status) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    switch (status) {
      case ConnectivityStatus.connected:
        _handleConnectionRestored(context);
        break;
      case ConnectivityStatus.disconnected:
        _handleConnectionLost(context);
        break;
      case ConnectivityStatus.unknown:
        // Do nothing for unknown status
        break;
    }
  }

  void _handleConnectionLost(BuildContext context) {
    if (_isNavigating) return;

    final currentRoute = ModalRoute.of(context)?.settings.name;
    
    // Don't navigate to offline page if already on offline page
    if (currentRoute == '/offline') return;

    // Don't navigate during certain critical flows
    if (_shouldSkipOfflineNavigation(currentRoute)) return;

    print('📵 Connection lost, navigating to offline page from: $currentRoute');
    
    _isNavigating = true;
    _currentPage = currentRoute;
    
    // Store current page data if needed
    _pageData = _getCurrentPageData(context);

    Navigator.of(context).pushReplacementNamed(
      '/offline',
      arguments: {
        'fromPage': _currentPage,
        'pageData': _pageData,
      },
    ).then((_) {
      _isNavigating = false;
    });
  }

  void _handleConnectionRestored(BuildContext context) {
    if (_isNavigating) return;

    final currentRoute = ModalRoute.of(context)?.settings.name;
    
    // Only handle if we're currently on the offline page
    if (currentRoute == '/offline') {
      print('🌐 Connection restored, navigating back to: $_currentPage');
      
      _isNavigating = true;
      
      final targetPage = _currentPage ?? '/main';
      
      Navigator.of(context).pushReplacementNamed(targetPage).then((_) {
        _isNavigating = false;
        _currentPage = null;
        _pageData = null;
      });
    }
  }

  bool _shouldSkipOfflineNavigation(String? currentRoute) {
    // Skip offline navigation for certain routes
    const skipRoutes = [
      '/', // Splash screen
      '/language-selection',
      '/offline', // Already on offline page
    ];
    
    return skipRoutes.contains(currentRoute);
  }

  Map<String, dynamic>? _getCurrentPageData(BuildContext context) {
    // Get current page data that might be needed when returning
    final route = ModalRoute.of(context);
    if (route?.settings.arguments != null) {
      return {'arguments': route!.settings.arguments};
    }
    return null;
  }

  /// Manually trigger offline navigation (useful for testing)
  void navigateToOfflinePage(BuildContext context, {String? fromPage, Map<String, dynamic>? pageData}) {
    if (_isNavigating) return;

    _isNavigating = true;
    _currentPage = fromPage ?? ModalRoute.of(context)?.settings.name;
    _pageData = pageData;

    Navigator.of(context).pushReplacementNamed(
      '/offline',
      arguments: {
        'fromPage': _currentPage,
        'pageData': _pageData,
      },
    ).then((_) {
      _isNavigating = false;
    });
  }

  /// Check if currently navigating
  bool get isNavigating => _isNavigating;

  /// Get current page being tracked
  String? get currentPage => _currentPage;

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityService = null;
  }
}

/// Extension to add status stream to ConnectivityService
extension ConnectivityServiceStatusStream on ConnectivityService {
  Stream<ConnectivityStatus> get statusStream async* {
    yield status;
    await for (final _ in Stream.periodic(Duration(milliseconds: 500))) {
      yield status;
    }
  }
}
