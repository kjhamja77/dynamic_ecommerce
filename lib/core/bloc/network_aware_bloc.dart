import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// Base class for BLoCs that need to handle network connectivity
abstract class NetworkAwareBloc<Event, State> extends Bloc<Event, State> {
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;

  NetworkAwareBloc(State initialState) : super(initialState) {
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.statusStream.listen(
      (status) {
        onConnectivityChanged(status);
      },
      onError: (error) {
        print('❌ Connectivity stream error: $error');
      },
    );
  }

  /// Called when connectivity status changes
  /// Override this method in your BLoC to handle connectivity changes
  void onConnectivityChanged(ConnectivityStatus status) {
    print('🌐 Network status changed: $status');
  }

  /// Check if currently connected to internet
  bool get isConnected => _connectivityService.isConnected;

  /// Check connectivity status
  ConnectivityStatus get connectivityStatus => _connectivityService.status;

  /// Execute a network operation with retry logic
  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    bool Function(Exception)? shouldRetry,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        // Check connectivity before attempting
        if (!isConnected) {
          throw NetworkException('No internet connection');
        }

        final result = await operation();
        return result;
      } catch (e) {
        attempts++;
        print('❌ Network operation failed (attempt $attempts/$maxRetries): $e');
        
        // Check if we should retry
        if (attempts >= maxRetries) {
          print('❌ Max retries reached, giving up');
          rethrow;
        }

        // Check custom retry condition
        if (shouldRetry != null && !shouldRetry(e is Exception ? e : Exception(e.toString()))) {
          print('❌ Custom retry condition failed');
          rethrow;
        }

        // Wait before retrying
        if (attempts < maxRetries) {
          print('⏳ Waiting ${retryDelay.inSeconds}s before retry...');
          await Future.delayed(retryDelay);
        }
      }
    }
    
    throw NetworkException('Max retries exceeded');
  }

  /// Get a connectivity-aware error message
  String getErrorMessage(Exception error) {
    if (!isConnected) {
      return 'No internet connection. Please check your network and try again.';
    }
    
    if (error is NetworkException) {
      return error.message;
    }
    
    return 'An error occurred. Please try again.';
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}

/// Custom exception for network-related errors
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Extension to add connectivity stream to ConnectivityService
extension ConnectivityServiceStream on ConnectivityService {
  Stream<ConnectivityStatus> get statusStream async* {
    yield status;
    await for (final _ in Stream.periodic(Duration(seconds: 1))) {
      yield status;
    }
  }
}

/// Mixin for widgets that need connectivity awareness
mixin ConnectivityAwareMixin<T extends StatefulWidget> on State<T> {
  ConnectivityService? _connectivityService;
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;

  ConnectivityStatus get connectivityStatus => _currentStatus;
  bool get isConnected => _currentStatus == ConnectivityStatus.connected;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    _connectivityService = ConnectivityService();
    _currentStatus = _connectivityService!.status;
    
    _connectivitySubscription = _connectivityService!.statusStream.listen(
      (status) {
        if (mounted) {
          setState(() {
            _currentStatus = status;
          });
          onConnectivityChanged(status);
        }
      },
    );
  }

  /// Called when connectivity status changes
  /// Override this method to handle connectivity changes in your widget
  void onConnectivityChanged(ConnectivityStatus status) {}

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
