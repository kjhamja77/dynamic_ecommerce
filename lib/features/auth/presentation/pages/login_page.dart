import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/entities/user.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/auth_button.dart';
import '../constants/auth_color_constants.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import '../../../auth/presentation/bloc/biometric_bloc.dart';
import '../../../auth/presentation/bloc/biometric_event.dart';
import '../../../auth/presentation/bloc/biometric_state.dart';
import '../../../auth/domain/entities/biometric_settings.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../pages/number_verification_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/domain/entities/cart_item.dart';

// Replace these via --dart-define at build time or paste your IDs directly
// Example: flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=xxxx.apps.googleusercontent.com \
//                          --dart-define=GOOGLE_IOS_CLIENT_ID=yyyy.apps.googleusercontent.com
const String _kGoogleWebClientId = String.fromEnvironment(
  'GOOGLE_WEB_CLIENT_ID',
  defaultValue: '124510041370-msm6j9ulanj7ho1mecf0bs9i46eu0r09.apps.googleusercontent.com',
);
const String _kGoogleIosClientId = String.fromEnvironment(
  'GOOGLE_IOS_CLIENT_ID',
  defaultValue: '124510041370-4bun2k4m0hue26j3sv7jjar0egbejd9o.apps.googleusercontent.com',
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isPhoneLogin = false;
  final _phoneFieldKey = GlobalKey<PhoneInputFieldState>();
  BiometricSettings? _lastBiometricSettings;
  bool _hideGuestCta = false;
  List<CartItem>? _guestCartSnapshot;
  
  Future<String?> _getGoogleIdToken() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: <String>['email'],
        // Android uses Web client ID to mint server-verified ID tokens
        serverClientId: _kGoogleWebClientId,
        // iOS needs the iOS client ID; safe to include on both platforms
        clientId: _kGoogleIosClientId,
      );

      // Ensure previous sessions are signed out to force new token if needed
      try { await googleSignIn.signOut(); } catch (_) {}

      final account = await googleSignIn.signIn();
      if (account == null) return null; // user cancelled

      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      // Surface a friendly error; leave actual error to logs if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Check biometric availability when the page loads
    context.read<BiometricBloc>().add(CheckBiometricAvailability());
    context.read<BiometricBloc>().add(GetBiometricSettings());
    _checkIfGuest();
    _snapshotGuestCart();
  }

  void _snapshotGuestCart() {
    try {
      final cartState = context.read<CartBloc>().state;
      if (cartState is CartLoaded && cartState.cartItems.isNotEmpty) {
        _guestCartSnapshot = List<CartItem>.from(cartState.cartItems);
      }
    } catch (_) {}
  }

  Future<void> _checkIfGuest() async {
    try {
      final storage = di.sl<FlutterSecureStorage>();
      final cached = await storage.read(key: AppConstants.userKey);
      final isGuest = (cached ?? '').toLowerCase().contains('guest: true');
      if (mounted) {
        setState(() {
          _hideGuestCta = isGuest;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // kept for future real login handling via bloc

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: GestureDetector(
        onTap: () {
          // Unfocus all text fields when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is Authenticated) {
            // On successful login (non-guest), merge guest cart into user cart
            if (!state.user.isGuest) {
              final cartBloc = context.read<CartBloc>();
              // Initial refresh to get the current user cart
              cartBloc.add(const RefreshCart());
              Future.delayed(const Duration(milliseconds: 300), () async {
                final snapshot = _guestCartSnapshot;
                if (snapshot != null && snapshot.isNotEmpty) {
                  // Add all guest items; backend should handle dedup/quantity increments
                  for (final item in snapshot) {
                    cartBloc.add(AddItemToCart(cartItem: item));
                  }
                  // Final refresh to reflect merged cart
                  await Future.delayed(const Duration(milliseconds: 300));
                  cartBloc.add(const RefreshCart());
                }
                // Navigate to main app and clear the stack
                NavigationService.pushNamedAndRemoveUntil('/main', arguments: null);
              });
            } else {
              // Guest sessions should also enter the main app shell.
              // AuthWrapper will detect the freshly stored token and show HomePage.
              NavigationService.pushNamedAndRemoveUntil('/main', arguments: null);
            }
          } else if (state is EmailVerificationRequired) {
            // Show email verification dialog (no navigation from login)
            _showEmailVerificationDialog(context, state.email, state.message);
          } else if (state is MobileNumberMissing) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is MobileVerificationRequired) {
            Navigator.of(context).pushNamed(
              '/verify-mobile',
              arguments: NumberVerificationArgs(
                userId: state.userId,
                phoneMasked: state.phoneMasked,
              ),
            ).then((result) {
              // Handle mobile verification result
              if (result is User) {
                // Mobile verification successful, user is now authenticated
                // Update currency provider with user's currency data
                final currencyProvider = context.read<CurrencyProvider>();
                if (result.currency != null && result.currencyId != null) {
                  currencyProvider.updateCurrency(result.currency!, result.currencyId!);
                }
                // The AuthWrapper will handle navigation to HomePage
              }
            });
          }
          // Authenticated navigation handled above (cart merge + guest routing).
        },
        child: BlocListener<BiometricBloc, BiometricState>(
          listener: (context, state) {
            if (state is BiometricAuthenticationSuccess) {
              // After biometric success, mark user as authenticated so AuthWrapper routes to Home
              context.read<AuthBloc>().add(BiometricAuthenticated(
                user: User(
                  id: 'bio-1',
                  email: 'biometric@user',
                  firstName: AppLocalizations.of(context)!.biometric,
                  lastName: AppLocalizations.of(context)!.user,
                  phoneNumber: null,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ));
            } else if (state is BiometricAuthenticationFailure) {
              AppSnackBar.show(
                context,
                message: '${AppLocalizations.of(context)!.biometricAuthenticationFailed}: ${state.message}',
                type: AppSnackBarType.error,
              );
            } else if (state is BiometricSettingsLoaded) {
              _lastBiometricSettings = state.settings;
            } else if (state is BiometricSettingsUpdated) {
              _lastBiometricSettings = state.settings;
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  
                  // Logo and Title
                  Center(
                    child: Column(
                      children: [
                        // App icon
                        Image.asset(
                          'assets/images/logo.png',
                          width: 96,
                          height: 96,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context)!.welcomeBack,
                          style: AppFonts.getTextStyle(fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.signInToContinueShopping,
                          style: AppFonts.getTextStyle(fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Email/Phone Toggle
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPhoneLogin = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: !_isPhoneLogin
                                      ? AuthColorConstants.primaryColor
                                      : colorScheme.outline.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.email,
                              textAlign: TextAlign.center,
                              style: AppFonts.getTextStyle(fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !_isPhoneLogin
                                    ? AuthColorConstants.primaryColor
                                    : colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPhoneLogin = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _isPhoneLogin
                                      ? AuthColorConstants.primaryColor
                                      : colorScheme.outline.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.phone,
                              textAlign: TextAlign.center,
                              style: AppFonts.getTextStyle(fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _isPhoneLogin
                                    ? AuthColorConstants.primaryColor
                                    : colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Email/Phone Field
                  if (!_isPhoneLogin)
                    AuthTextField(
                      controller: _emailController,
                      labelText: AppLocalizations.of(context)!.email,
                      hintText: AppLocalizations.of(context)!.enterYourEmail,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.pleaseEnterYourEmail;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                        }
                        return null;
                      },
                    )
                  else
                    PhoneInputField(
                      key: _phoneFieldKey,
                      controller: _phoneController,
                      labelText: AppLocalizations.of(context)!.phoneNumber,
                      hintText: AppLocalizations.of(context)!.enterYourPhoneNumber,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.pleaseEnterYourPhoneNumber;
                        }
                        if (!RegExp(r'^[\+]?[1-9][\d]{0,15}$').hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
                          return AppLocalizations.of(context)!.pleaseEnterValidPhoneNumber;
                        }
                        return null;
                      },
                    ),
                  
                  const SizedBox(height: 10),
                  
                  // Password Field
                  AuthTextField(
                    controller: _passwordController,
                    labelText: AppLocalizations.of(context)!.password,
                    hintText: AppLocalizations.of(context)!.enterYourPassword,
                    prefixIcon: Icons.lock_outlined,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterYourPassword;
                      }
                      if (value.length < 6) {
                        return AppLocalizations.of(context)!.passwordMustBeAtLeast6Characters;
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.pushAuth(
                          BlocProvider.value(
                            value: context.read<AuthBloc>(),
                            child: const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.forgotPassword,
                        style: AppFonts.getTextStyle(color: AuthColorConstants.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Login Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AuthButton(
                        onPressed: state is AuthLoading
                            ? null
                              : () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  String loginIdentifier;
                                  if (_isPhoneLogin) {
                                    // For phone login, use full phone (country code + number)
                                    final fullPhone = _phoneFieldKey.currentState?.fullPhoneNumber;
                                    loginIdentifier = (fullPhone ?? _phoneController.text.trim()).trim();
                                  } else {
                                    // For email login, use the email as usual
                                    loginIdentifier = _emailController.text.trim();
                                  }
                                  
                                  context.read<AuthBloc>().add(LoginRequested(
                                        email: loginIdentifier, // This will be phone number for phone login
                                        password: _passwordController.text.trim(),
                                      ));
                                }
                              },
                        text: state is AuthLoading ? AppLocalizations.of(context)!.signingIn : AppLocalizations.of(context)!.signIn,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: colorScheme.outline.withValues(alpha: 0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context)!.or,
                          style: AppFonts.getTextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: colorScheme.outline.withValues(alpha: 0.3))),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Continue as Guest
                  if (!_hideGuestCta)
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(const GuestLoginRequested());
                      },
                      icon: Icon(
                        Icons.person_outline,
                        color: colorScheme.onSurface,
                        size: 22,
                      ),
                      label: Text(
                        AppLocalizations.of(context)!.continueAsGuest,
                        style: AppFonts.getTextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                        foregroundColor: colorScheme.onSurface,
                        backgroundColor: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Social Login Buttons
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: () async {
                  //           final idToken = await _getGoogleIdToken();
                  //           if (!mounted || idToken == null || idToken.isEmpty) return;
                  //           context.read<AuthBloc>().add(GoogleLoginRequested(idToken: idToken));
                  //         },
                  //         icon: Image.asset(
                  //           'assets/images/google.png',
                  //           width: 24,
                  //           height: 24,
                  //         ),
                  //         label: Text(
                  //           AppLocalizations.of(context)!.google,
                  //           style: AppFonts.getTextStyle(fontWeight: FontWeight.w500,
                  //             color: colorScheme.onSurface,
                  //           ),
                  //         ),
                  //         style: OutlinedButton.styleFrom(
                  //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  //           side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                  //           foregroundColor: colorScheme.onSurface,
                  //           backgroundColor: colorScheme.surface,
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: () {
                  //           // Handle Apple sign in
                  //         },
                  //         icon: Image.asset(
                  //           'assets/images/apple.png',
                  //           width: 24,
                  //           height: 24,
                  //         ),
                  //         label: Text(
                  //           AppLocalizations.of(context)!.apple,
                  //           style: AppFonts.getTextStyle(fontWeight: FontWeight.w500,
                  //             color: colorScheme.onSurface,
                  //           ),
                  //         ),
                  //         style: OutlinedButton.styleFrom(
                  //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  //           side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                  //           foregroundColor: colorScheme.onSurface,
                  //           backgroundColor: colorScheme.surface,
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  
                  const SizedBox(height: 14),
                  
                  // Biometric Authentication Button / Prompt
                  // BlocBuilder<BiometricBloc, BiometricState>(
                  //   builder: (context, state) {
                  //     if (state is BiometricSettingsLoaded) {
                  //       _lastBiometricSettings = state.settings;
                  //       if (state.settings.isEnabled) {
                  //         return Column(
                  //           children: [
                  //             OutlinedButton.icon(
                  //               onPressed: () {
                  //                 context.read<BiometricBloc>().add(AuthenticateWithBiometric());
                  //               },
                  //               icon: Icon(
                  //                 state.settings.biometricType == BiometricType.fingerprint
                  //                     ? Icons.fingerprint
                  //                     : Icons.face,
                  //                 size: 20,
                  //                 color: colorScheme.onSurface,
                  //               ),
                  //               label: Text(
                  //                 state.settings.biometricType == BiometricType.fingerprint
                  //                   ? AppLocalizations.of(context)!.signInWithFingerprint
                  //                   : AppLocalizations.of(context)!.signInWithFaceId,
                  //                 style: AppFonts.getTextStyle(fontWeight: FontWeight.w500,
                  //                   color: colorScheme.onSurface,
                  //                 ),
                  //               ),
                  //               style: OutlinedButton.styleFrom(
                  //                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  //                 side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                  //                 foregroundColor: colorScheme.onSurface,
                  //                 backgroundColor: colorScheme.surface,
                  //                 shape: RoundedRectangleBorder(
                  //                   borderRadius: BorderRadius.circular(12),
                  //                 ),
                  //               ),
                  //             ),
                  //             const SizedBox(height: 12),
                  //           ],
                  //         );
                  //       }
                  //     }
                  //     // While loading, keep showing the last known state (button stays visible)
                  //     if (state is BiometricLoading && _lastBiometricSettings != null) {
                  //       final s = _lastBiometricSettings!;
                  //       if (s.isEnabled) {
                  //         return Column(
                  //           children: [
                  //             OutlinedButton.icon(
                  //               onPressed: null,
                  //               icon: SizedBox(
                  //                 width: 20,
                  //                 height: 20,
                  //                 child: CircularProgressIndicator(
                  //                   strokeWidth: 2,
                  //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                  //                 ),
                  //               ),
                  //               label: Text(
                  //                 AppLocalizations.of(context)!.authenticating,
                  //                 style: AppFonts.getTextStyle(
                  //                   fontWeight: FontWeight.w500,
                  //                   color: colorScheme.onSurface.withValues(alpha: 0.6),
                  //                 ),
                  //               ),
                  //               style: OutlinedButton.styleFrom(
                  //                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  //                 side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                  //               ),
                  //             ),
                  //             const SizedBox(height: 16),
                  //           ],
                  //         );
                  //       }
                  //     }
                  //     return const SizedBox.shrink();
                  //   },
                  // ),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dontHaveAnAccount,
                        style: AppFonts.getTextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.pushAuth(
                            const RegisterPage(),
                          );
                        },
                                                  child: Text(
                            AppLocalizations.of(context)!.signUp,
                            style: AppFonts.getTextStyle(color: AuthColorConstants.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
        ),
      ),
    );
  }

  void _showEmailVerificationDialog(
    BuildContext context,
    String email,
    String message,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final dialogTheme = Theme.of(context);
        final dialogColorScheme = dialogTheme.colorScheme;
        final dialogIsDark = dialogTheme.brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: dialogColorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AuthColorConstants.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread,
                  color: AuthColorConstants.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.emailVerificationRequired,
                style: AppFonts.getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: dialogColorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.emailNotVerifiedMessage,
                style: AppFonts.getTextStyle(
                  fontSize: 14,
                  color: dialogColorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AuthColorConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AuthColorConstants.primaryColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: AuthColorConstants.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        email,
                        style: AppFonts.getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: dialogColorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: AppFonts.getTextStyle(
                  color: dialogColorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement resend verification email functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.verificationEmailSent),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AuthColorConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.resendEmail,
              style: AppFonts.getTextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      )
        ;
      },
    );
  }
}
