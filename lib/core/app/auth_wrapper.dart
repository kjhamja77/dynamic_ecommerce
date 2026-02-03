import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart' as di;
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import 'dart:async';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _decided = false;
  bool _hasToken = false;
  Timer? _tokenCheckTimer;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    debugPrint('AuthWrapper:initState');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('AuthWrapper:postFrame → start fast token gate');
      await _checkTokenFastGate();
      if (_hasToken) {
        debugPrint('AuthWrapper:postFrame → token exists → dispatch CheckAuthStatus');
        context.read<AuthBloc>().add(CheckAuthStatus());
      } else {
        debugPrint('AuthWrapper:postFrame → no token → skip CheckAuthStatus');
      }
      
      // Start periodic token checking to detect token expiration
      _startTokenCheckTimer();
    });
  }

  @override
  void dispose() {
    _tokenCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to auth state changes to avoid showing splash when already authenticated
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && !_hasToken) {
      debugPrint('AuthWrapper:didChangeDependencies → already authenticated, updating state');
      setState(() {
        _hasToken = true;
        _decided = true;
      });
    }
  }

  Future<void> _checkTokenFastGate() async {
    try {
      final storage = di.sl<FlutterSecureStorage>();
      final token = await storage.read(key: AppConstants.tokenKey);
      
      // Enhanced debug prints to show token details
      debugPrint('🔐 AuthWrapper:_checkTokenFastGate');
      debugPrint('   📱 Token Key: ${AppConstants.tokenKey}');
      debugPrint('   🔑 Token Value: ${token ?? 'NULL'}');
      debugPrint('   📏 Token Length: ${token?.length ?? 0}');
      debugPrint('   ✅ Token Valid: ${token != null && token.isNotEmpty}');
      
      if (!mounted) return;
      setState(() {
        _hasToken = token != null && token.isNotEmpty;
        _decided = true;
      });
      debugPrint('   🎯 Final Decision: decided=$_decided, hasToken=$_hasToken');
      debugPrint('   🏠 Next: Will show ${_hasToken ? 'HomePage' : 'LoginPage'}');
    } on PlatformException catch (e) {
      // Handle decryption errors (corrupted secure storage data)
      if (e.code == 'read' && e.message?.contains('BAD_DECRYPT') == true) {
        debugPrint('⚠️ AuthWrapper:_checkTokenFastGate → Corrupted secure storage detected, clearing...');
        try {
          final storage = di.sl<FlutterSecureStorage>();
          // Clear all secure storage to remove corrupted data
          await storage.deleteAll();
          debugPrint('✅ AuthWrapper:_checkTokenFastGate → Secure storage cleared successfully');
        } catch (clearError) {
          debugPrint('❌ AuthWrapper:_checkTokenFastGate → Failed to clear storage: $clearError');
        }
      } else {
        debugPrint('❌ AuthWrapper:_checkTokenFastGate PlatformException → $e');
      }
      if (!mounted) return;
      setState(() {
        _hasToken = false;
        _decided = true;
      });
      debugPrint('   🎯 Error Decision: decided=$_decided, hasToken=$_hasToken');
    } catch (e) {
      debugPrint('❌ AuthWrapper:_checkTokenFastGate ERROR → $e');
      if (!mounted) return;
      setState(() {
        _hasToken = false;
        _decided = true;
      });
      debugPrint('   🎯 Error Decision: decided=$_decided, hasToken=$_hasToken');
    }
  }

  Future<void> _recheckTokenOnUnauthenticated(String reason) async {
    final storage = di.sl<FlutterSecureStorage>();
    final token = await storage.read(key: AppConstants.tokenKey);
    debugPrint('AuthWrapper:_recheckTokenOnUnauthenticated($reason) → token = ${token != null && token.isNotEmpty ? token : 'NULL/EMPTY'}');
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      setState(() => _hasToken = false);
      debugPrint('AuthWrapper:_recheckTokenOnUnauthenticated → set hasToken=false');
    } else {
      setState(() => _hasToken = true);
      debugPrint('AuthWrapper:_recheckTokenOnUnauthenticated → set hasToken=true (keeping Home)');
    }
  }

  /// Start a timer to periodically check if token still exists
  void _startTokenCheckTimer() {
    _tokenCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      try {
        final token = await _storage.read(key: AppConstants.tokenKey);
        final hasTokenNow = token != null && token.isNotEmpty;
        
        // If we had a token but now we don't, navigate to login
        if (_hasToken && !hasTokenNow) {
          debugPrint('AuthWrapper:_startTokenCheckTimer → Token was removed, navigating to login');
          if (mounted) {
            setState(() {
              _hasToken = false;
            });
          }
        }
      } on PlatformException catch (e) {
        // Silently handle decryption errors in timer (already handled in _checkTokenFastGate)
        if (e.code == 'read' && e.message?.contains('BAD_DECRYPT') == true) {
          debugPrint('⚠️ AuthWrapper:_startTokenCheckTimer → Corrupted storage detected (ignoring)');
          if (mounted && _hasToken) {
            setState(() {
              _hasToken = false;
            });
          }
        }
      } catch (e) {
        // Ignore other errors in periodic check
        debugPrint('⚠️ AuthWrapper:_startTokenCheckTimer → Error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ AuthWrapper:build');
    debugPrint('   📊 State: decided=$_decided, hasToken=$_hasToken');
    debugPrint('   🎯 Will show: ${!_decided ? 'Loading' : (_hasToken ? 'HomePage' : 'LoginPage')}');
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        debugPrint('AuthWrapper:BlocListener → state: $state');
        if (state is Authenticated) {
          if (!mounted) return;
          setState(() => _hasToken = true);
          debugPrint('AuthWrapper:BlocListener → Authenticated → set hasToken=true');
        } else if (state is Unauthenticated) {
          await _recheckTokenOnUnauthenticated('Unauthenticated');
        } else if (state is AuthError) {
          await _recheckTokenOnUnauthenticated('AuthError');
        } else if (state is AuthLoading) {
          debugPrint('AuthWrapper:BlocListener → AuthLoading');
        }
      },
      child: Builder(
        builder: (context) {
          if (!_decided) {
            debugPrint('AuthWrapper:build → not decided yet → showing slim loader');
            return Scaffold(
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    SizedBox(
                      height: 2,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                    Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ),
            );
          }

          if (_hasToken) {
            debugPrint('AuthWrapper:build → hasToken=true → returning HomePage');
            return const HomePage();
          }

          debugPrint('AuthWrapper:build → hasToken=false → navigating to sign-in');
          // Navigate to sign-in page instead of showing login page directly
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/sign-in');
          });
          // Return a loading widget while navigating
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}


