import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:collection';
import '../constants/app_constants.dart';
import '../constants/endpoints.dart';
import '../services/language_service.dart';
import '../services/auth_service.dart';

/// Simple FIFO request queue to avoid overwhelming the server/device.
/// This makes API calls run smoothly one-by-one (maxConcurrent = 1).
class _RequestQueue {
  final int maxConcurrent;
  int _active = 0;
  final Queue<Future<void> Function()> _pending = Queue();

  _RequestQueue({required this.maxConcurrent});

  Future<T> schedule<T>(Future<T> Function() task) {
    final completer = Completer<T>();

    _pending.add(() async {
      try {
        final result = await task();
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });

    _pump();
    return completer.future;
  }

  void _pump() {
    while (_active < maxConcurrent && _pending.isNotEmpty) {
      final job = _pending.removeFirst();
      _active += 1;
      () async {
        try {
          await job();
        } finally {
          _active -= 1;
          _pump();
        }
      }();
    }
  }
}

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;
  // One-by-one request execution to keep the app smooth under load.
  static final _RequestQueue _queue = _RequestQueue(maxConcurrent: 1);

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl + AppConstants.apiVersion,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Track request start time for performance logging
          options.extra['_startAt'] = DateTime.now();

          // Safely read token with error handling for corrupted storage
          String? token;
          try {
            token = await _storage.read(key: AppConstants.tokenKey);
          } on PlatformException catch (e) {
            if (e.code == 'read' && e.message?.contains('BAD_DECRYPT') == true) {
              debugPrint('⚠️ ApiClient:onRequest → Corrupted secure storage detected (token read failed)');
              // Clear corrupted storage
              try {
                await _storage.deleteAll();
                debugPrint('✅ ApiClient:onRequest → Secure storage cleared');
              } catch (_) {}
            } else {
              debugPrint('⚠️ ApiClient:onRequest → Error reading token: $e');
            }
          } catch (e) {
            debugPrint('⚠️ ApiClient:onRequest → Unexpected error reading token: $e');
          }
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('ApiClient:onRequest → using token present');
          } else {
            debugPrint('ApiClient:onRequest → no token');
          }
          
          // Add session ID as cookie if available (for Odoo compatibility)
          String? sessionId;
          try {
            sessionId = await _storage.read(key: AppConstants.sessionIdKey);
          } on PlatformException catch (e) {
            if (e.code == 'read' && e.message?.contains('BAD_DECRYPT') == true) {
              debugPrint('⚠️ ApiClient:onRequest → Corrupted secure storage detected (sessionId read failed)');
            } else {
              debugPrint('⚠️ ApiClient:onRequest → Error reading sessionId: $e');
            }
          } catch (e) {
            debugPrint('⚠️ ApiClient:onRequest → Unexpected error reading sessionId: $e');
          }
          
          if (sessionId != null && sessionId.isNotEmpty) {
            options.headers['Cookie'] = 'session_id=$sessionId';
            debugPrint('ApiClient:onRequest → using session_id present');
          }
          
          // Attach Accept-Language from LanguageService if available
          final apiLang = await LanguageService().getApiLanguageCode();
          if (apiLang != null && apiLang.isNotEmpty) {
            options.headers['Accept-Language'] = apiLang;
            debugPrint('🌐 ApiClient:onRequest → Added Accept-Language header: $apiLang for ${options.path}');
          } else {
            debugPrint('⚠️ ApiClient:onRequest → No Accept-Language header (apiLang is null or empty) for ${options.path}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          // Log request duration
          final startAt = response.requestOptions.extra['_startAt'];
          final int? ms = startAt is DateTime
              ? DateTime.now().difference(startAt).inMilliseconds
              : null;
          debugPrint(
            '⏱️ API ${response.requestOptions.method} ${response.requestOptions.path} '
            '→ ${response.statusCode} in ${ms ?? -1}ms',
          );

          // Extract session ID from response cookies or headers
          try {
            bool sessionIdFound = false;
            
            // Check all Set-Cookie headers (there might be multiple)
            final setCookieHeaders = response.headers.map['set-cookie'];
            if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
              debugPrint('ApiClient:onResponse → Found ${setCookieHeaders.length} Set-Cookie header(s)');
              for (final cookieHeader in setCookieHeaders) {
                debugPrint('ApiClient:onResponse → Checking cookie header: ${cookieHeader.substring(0, cookieHeader.length > 50 ? 50 : cookieHeader.length)}...');
                // Extract session_id from cookies (format: session_id=xxx; path=/; ...)
                final sessionIdMatch = RegExp(r'session_id=([^;]+)').firstMatch(cookieHeader);
                if (sessionIdMatch != null) {
                  final sessionId = sessionIdMatch.group(1);
                  if (sessionId != null && sessionId.isNotEmpty) {
                    await _storage.write(key: AppConstants.sessionIdKey, value: sessionId);
                    debugPrint('ApiClient:onResponse → ✅ saved session_id from cookies: ${sessionId.substring(0, sessionId.length > 10 ? 10 : sessionId.length)}...');
                    sessionIdFound = true;
                    break; // Found session_id, no need to check more
                  }
                }
              }
            } else {
              debugPrint('ApiClient:onResponse → No Set-Cookie headers found');
            }
            
            // Also check response data for session_id (some APIs return it in the response)
            if (!sessionIdFound && response.data is Map) {
              final data = response.data as Map;
              debugPrint('ApiClient:onResponse → Checking response data for session_id...');
              
              // Check in result.data if it's an RPC envelope
              if (data.containsKey('result') && data['result'] is Map) {
                final result = data['result'] as Map;
                if (result.containsKey('data') && result['data'] is Map) {
                  final resultData = result['data'] as Map;
                  if (resultData.containsKey('session_id')) {
                    final sessionId = resultData['session_id']?.toString();
                    if (sessionId != null && sessionId.isNotEmpty) {
                      await _storage.write(key: AppConstants.sessionIdKey, value: sessionId);
                      debugPrint('ApiClient:onResponse → ✅ saved session_id from result.data: ${sessionId.substring(0, sessionId.length > 10 ? 10 : sessionId.length)}...');
                      sessionIdFound = true;
                    }
                  }
                }
              }
              // Check directly in response data
              if (!sessionIdFound && data.containsKey('session_id')) {
                final sessionId = data['session_id']?.toString();
                if (sessionId != null && sessionId.isNotEmpty) {
                  await _storage.write(key: AppConstants.sessionIdKey, value: sessionId);
                  debugPrint('ApiClient:onResponse → ✅ saved session_id from response data: ${sessionId.substring(0, sessionId.length > 10 ? 10 : sessionId.length)}...');
                  sessionIdFound = true;
                }
              }
            }
            
            if (!sessionIdFound) {
              debugPrint('ApiClient:onResponse → ⚠️ No session_id found in response');
            }
          } catch (e) {
            debugPrint('ApiClient:onResponse → ❌ Error extracting session_id: $e');
          }
          
          handler.next(response);
        },
        onError: (error, handler) async {
          // Log request duration (even on failure/timeout)
          final startAt = error.requestOptions.extra['_startAt'];
          final int? ms = startAt is DateTime
              ? DateTime.now().difference(startAt).inMilliseconds
              : null;
          debugPrint(
            '⏱️ API ${error.requestOptions.method} ${error.requestOptions.path} '
            '→ ERROR (${error.type}) in ${ms ?? -1}ms',
          );

          if (error.response?.statusCode == 401) {
            debugPrint('ApiClient:onError 401 Unauthorized → Token expired or invalid');
            
            // Check if this is a token-related error
            final responseData = error.response?.data;
            if (responseData is Map && responseData['result'] is Map) {
              final result = responseData['result'] as Map;
              final message = result['message']?.toString().toLowerCase() ?? '';
              
              // Check for token expiration/invalid token messages
              if (message.contains('token') && 
                  (message.contains('expired') || 
                   message.contains('invalid') || 
                   message.contains('unauthorized'))) {
                
                debugPrint('ApiClient:onError → Token expiration detected, clearing token');
                
                // Clear the token and trigger logout
                await AuthService().handleTokenExpiration();
                
                // The AuthWrapper will automatically detect token removal and navigate to login
                debugPrint('ApiClient:onError → Token cleared, AuthWrapper will handle navigation');
              }
            }
          }
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      // IMPORTANT:
      // Logging full request/response bodies can heavily impact performance on real devices
      // (UI jank, skipped frames) especially when many requests happen at once.
      // Keep logs lightweight even in debug.
      LogInterceptor(
        request: kDebugMode,
        requestBody: false,
        responseBody: false,
        responseHeader: false,
      ),
    );
  }

  Dio get dio => _dio;

  /// Queued raw HTTP request (NO RPC params wrapping).
  /// Use this for endpoints that expect plain query params/body (e.g. orderHistory?page=...).
  Future<Response<dynamic>> requestRaw(
    String path, {
    required String method,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
  }) {
    return _queue.schedule(() {
      return _dio.request(
        path,
        queryParameters: queryParameters,
        data: data,
        options: (options ?? Options(method: method.toUpperCase())),
      );
    });
  }

  Future<Response<dynamic>> requestRpc(
    String path, {
    String method = 'POST',
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    final data = Endpoints.withParams(params ?? <String, dynamic>{});
    // Serialize requests to avoid spikes/timeouts when multiple screens load at once.
    return _queue.schedule(() {
      switch (method.toUpperCase()) {
        case 'GET':
          return _dio.get(path, queryParameters: data, options: options);
        case 'POST':
          return _dio.post(path, data: data, options: options);
        case 'PUT':
          return _dio.put(path, data: data, options: options);
        case 'DELETE':
          return _dio.delete(path, data: data, options: options);
        default:
          return _dio.request(
            path,
            data: data,
            options: (options ?? Options(method: method.toUpperCase())),
          );
      }
    });
  }

  ({String status, String? message, dynamic data}) parseRpcEnvelope(dynamic body) {
    if (body is Map && body['result'] is Map) {
      final result = body['result'] as Map;
      final status = (result['status'] ?? '').toString();
      final message = result['message']?.toString();
      final data = result['data'];
      return (status: status, message: message, data: data);
    }
    return (status: 'ok', message: null, data: body);
  }

  Future<void> saveToken(String? token) async {
    if (token == null || token.isEmpty) {
      debugPrint('ApiClient:saveToken → skipped (null/empty)');
      return;
    }
    await _storage.write(key: AppConstants.tokenKey, value: token);
    debugPrint('ApiClient:saveToken → wrote token to ${AppConstants.tokenKey}');
  }

  Future<void> clearToken() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
      await _storage.delete(key: AppConstants.sessionIdKey);
      debugPrint('ApiClient:clearToken → token and session_id cleared successfully');
    } catch (e) {
      debugPrint('❌ ApiClient:clearToken → Error clearing token: $e');
    }
  }

  Future<void> saveSessionId(String? sessionId) async {
    if (sessionId == null || sessionId.isEmpty) {
      debugPrint('ApiClient:saveSessionId → skipped (null/empty)');
      return;
    }
    await _storage.write(key: AppConstants.sessionIdKey, value: sessionId);
    debugPrint('ApiClient:saveSessionId → wrote session_id to ${AppConstants.sessionIdKey}');
  }

  Future<String?> getSessionId() async {
    try {
      return await _storage.read(key: AppConstants.sessionIdKey);
    } on PlatformException catch (e) {
      if (e.code == 'read' && e.message?.contains('BAD_DECRYPT') == true) {
        debugPrint('⚠️ ApiClient:getSessionId → Corrupted secure storage detected');
        // Clear corrupted storage
        try {
          await _storage.deleteAll();
          debugPrint('✅ ApiClient:getSessionId → Secure storage cleared');
        } catch (_) {}
      } else {
        debugPrint('❌ ApiClient:getSessionId → PlatformException: $e');
      }
      return null;
    } catch (e) {
      debugPrint('❌ ApiClient:getSessionId → Error getting session_id: $e');
      return null;
    }
  }
}
