import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../l10n/app_localizations.dart';

enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  ConnectivityStatus _status = ConnectivityStatus.unknown;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  ConnectivityStatus get status => _status;
  bool get isConnected => _status == ConnectivityStatus.connected;
  bool get isDisconnected => _status == ConnectivityStatus.disconnected;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    // Check initial connectivity status
    await _checkConnectivity();
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) => _onConnectivityChanged([result]),
      onError: (error) {
        debugPrint('Connectivity error: $error');
        _updateStatus(ConnectivityStatus.unknown);
      },
    );
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatus(_mapConnectivityResult([result]));
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _updateStatus(ConnectivityStatus.unknown);
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> result) {
    _updateStatus(_mapConnectivityResult(result));
  }

  /// Update connectivity status and notify listeners
  void _updateStatus(ConnectivityStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      debugPrint('🌐 Connectivity changed: $_status');
      notifyListeners();
    }
  }

  /// Map connectivity result to our status enum
  ConnectivityStatus _mapConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return ConnectivityStatus.unknown;
    }
    
    // If any connection type is available, we consider it connected
    final hasConnection = results.any((result) => 
      result != ConnectivityResult.none
    );
    
    return hasConnection ? ConnectivityStatus.connected : ConnectivityStatus.disconnected;
  }

  /// Check if we have internet connectivity (not just network connection)
  Future<bool> hasInternetConnection() async {
    try {
      // This is a simple check - in production you might want to ping a reliable server
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking internet connection: $e');
      return false;
    }
  }

  /// Get detailed connectivity information
  Future<ConnectivityResult> getConnectivityResult() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('Error getting connectivity result: $e');
      return ConnectivityResult.none;
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Get user-friendly connectivity status message
  /// If BuildContext is provided, returns localized message
  String getStatusMessage([BuildContext? context]) {
    if (context != null) {
      final localizations = AppLocalizations.of(context);
      if (localizations != null) {
        switch (_status) {
          case ConnectivityStatus.connected:
            return localizations.connectedToInternet;
          case ConnectivityStatus.disconnected:
            return localizations.noInternetConnection;
          case ConnectivityStatus.unknown:
            return localizations.checkingConnection;
        }
      }
    }
    // Fallback to English if no context provided
    switch (_status) {
      case ConnectivityStatus.connected:
        return 'Connected to internet';
      case ConnectivityStatus.disconnected:
        return 'No internet connection';
      case ConnectivityStatus.unknown:
        return 'Checking connection...';
    }
  }

  /// Get connectivity icon
  String getStatusIcon() {
    switch (_status) {
      case ConnectivityStatus.connected:
        return '🌐';
      case ConnectivityStatus.disconnected:
        return '📵';
      case ConnectivityStatus.unknown:
        return '⏳';
    }
  }
}
